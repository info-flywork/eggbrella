#!/usr/bin/env python3
"""Eggbrella sesleri: assets/sounds/*.wav (44.1 kHz, 16 bit, mono).

Lisans gerektirmesin diye efektler ve müzik döngüsü burada sentezlenir.
Kullanım: python3 scripts/generate_sounds.py
"""

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / 'assets' / 'sounds'


def write(name, samples, level=0.8):
    peak = max(1e-9, max(abs(s) for s in samples))
    gain = level / peak
    with wave.open(str(OUT / f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, s * gain)) * 32767))
            for s in samples))


def tone(freq, dur, release, harmonics=((1, 1.0),), sweep=0.0, attack=0.004):
    n = int(RATE * dur)
    out, phase = [], 0.0
    for i in range(n):
        f = freq * (1 + sweep * i / n)
        phase += 2 * math.pi * f / RATE
        s = sum(a * math.sin(phase * h) for h, a in harmonics)
        t = i / RATE
        a = min(1.0, t / attack) if attack else 1.0
        out.append(s * a * math.exp(-t / release))
    return out


def mix(*tracks, length=None):
    n = length or max(int(RATE * off) + len(t) for t, off in tracks)
    out = [0.0] * n
    for t, off in tracks:
        start = int(RATE * off)
        for i, s in enumerate(t):
            if start + i < n:
                out[start + i] += s
    return out


def noise(dur, seed, cutoff_from, cutoff_to, shape_pow=2):
    rng = random.Random(seed)
    n = int(RATE * dur)
    out, lp = [], 0.0
    for i in range(n):
        x = i / n
        lp += (cutoff_from + (cutoff_to - cutoff_from) * x) * (rng.uniform(-1, 1) - lp)
        out.append(lp * math.sin(math.pi * x) ** shape_pow)
    return out


def coin():
    a = tone(988, 0.08, 0.05, harmonics=((1, 1), (2, 0.3)))
    b = tone(1319, 0.25, 0.09, harmonics=((1, 1), (2, 0.3)))
    return mix((a, 0), (b, 0.06))


def crack():
    """Kırılma: tok vuruş + çatırtı."""
    thud = tone(110, 0.3, 0.07, harmonics=((1, 1.0), (2, 0.4)), sweep=-0.5)
    rng = random.Random(7)
    crackle = []
    for i in range(int(RATE * 0.35)):
        burst = 1.0 if rng.random() < 0.03 else 0.0
        crackle.append(burst * rng.uniform(-1, 1) * math.exp(-i / (RATE * 0.12)))
    splat = noise(0.25, 3, 0.4, 0.05)
    return mix((thud, 0), (crackle, 0.0), (splat, 0.02))


def umbrella_open():
    return mix((noise(0.22, 11, 0.05, 0.3), 0), (tone(420, 0.2, 0.08, sweep=0.6), 0.02))


def umbrella_close():
    return mix((noise(0.18, 12, 0.3, 0.05), 0), (tone(620, 0.16, 0.06, sweep=-0.5), 0.0))


def beep():
    return tone(784, 0.18, 0.08, harmonics=((1, 1), (3, 0.15)))


def go():
    return mix((tone(1046, 0.35, 0.14, harmonics=((1, 1), (2, 0.25))), 0),
               (tone(1568, 0.3, 0.12), 0.03))


def fanfare():
    notes = [(523, 0), (659, 0.12), (784, 0.24), (1046, 0.36)]
    return mix(*[(tone(f, 0.5, 0.18, harmonics=((1, 1), (2, 0.3), (3, 0.1))), t)
                 for f, t in notes])


def tap():
    return tone(660, 0.06, 0.02)


NOTE = {n: 440 * 2 ** ((i - 9) / 12) for i, n in enumerate(
    ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'])}


def note_freq(name):
    octave = int(name[-1])
    return NOTE[name[:-1]] * 2 ** (octave - 4)


def music():
    """Neşeli 16 ölçülük döngü (C majör, 120 bpm). Uçlar sessiz başlar ve
    biter ki döngü dikişsiz olsun."""
    beat = 0.5
    melody = ('E5 G5 A5 G5 E5 D5 C5 D5 E5 E5 D5 C5 D5 E5 G5 G5 '
              'A5 G5 E5 D5 C5 D5 E5 G5 A5 A5 G5 E5 D5 D5 C5 C5').split()
    bass = 'C3 C3 A2 A2 F2 F2 G2 G2 C3 C3 A2 A2 F2 G2 C3 C3'.split()
    length = int(RATE * beat * len(melody))
    tracks = []
    for i, n in enumerate(melody):
        tracks.append((tone(note_freq(n), beat * 0.95, 0.22,
                            harmonics=((1, 0.6), (2, 0.2), (3, 0.08)), attack=0.01), i * beat))
    for i, n in enumerate(bass):
        tracks.append((tone(note_freq(n), beat * 1.9, 0.5,
                            harmonics=((1, 0.7), (2, 0.15)), attack=0.01), i * 2 * beat))
    for i in range(len(melody)):
        if i % 2 == 1:
            tracks.append(([s * 0.15 for s in noise(0.06, i, 0.6, 0.6, 1)], i * beat))
    out = mix(*tracks, length=length)
    fade = int(RATE * 0.02)
    for i in range(fade):
        out[i] *= i / fade
        out[-1 - i] *= i / fade
    return out


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    write('coin', coin())
    write('crack', crack())
    write('umbrella_open', umbrella_open(), level=0.5)
    write('umbrella_close', umbrella_close(), level=0.5)
    write('beep', beep())
    write('go', go())
    write('fanfare', fanfare())
    write('tap', tap(), level=0.5)
    write("music", music(), level=0.6)  # sonra: ffmpeg ile music.m4a
    print('sesler yazıldı:', sorted(p.name for p in OUT.glob('*.wav')))


if __name__ == '__main__':
    main()
