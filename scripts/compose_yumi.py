#!/usr/bin/env python3
"""Yumi pozlarını Figma'daki yüksek çözünürlüklü parçalardan yeniden kurar.

Figma ekranlarındaki sakin / mutlu / kalkanlı Yumi görselleri küçük (≈220 px)
dışa aktarılmıştı ve oyunda bulanık görünüyordu. Bileşenler sayfasında aynı
karakterin 1024 px parçaları var (`.design/raw/hires/`): boş yumurta, yüz
ifadeleri, açık şemsiye, eldivenler. Bu betik pozları eski görsellerle aynı
yerleşimde (aynı tuval oranı, aynı çapa noktaları) ama 3 kat çözünürlükte
birleştirir; oyundaki boyut / çapa sabitleri değişmez.

Çıktı: assets/images/img_yumi_{calm,happy,shield}.png
Sonra: python3 scripts/make_skins.py

Kullanım: python3 scripts/compose_yumi.py [--compare]
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
HI = ROOT / ".design" / "raw" / "hires"
OUT = ROOT / "assets" / "images"
K = 3  # eski piksel -> yeni piksel

# Yüz sayfası (faces.png, 1536x1024): 3x2 ızgara.
FACES = {
    "calm": (40, 140, 480, 400),
    "happy": (550, 140, 990, 420),
    "scared": (1060, 140, 1495, 420),
    "determined": (40, 640, 480, 880),
    "dizzy": (550, 630, 990, 880),
    "sleepy": (1060, 690, 1495, 885),
}
# Eldiven sayfası (gloves.png): yumruk, açık el.
GLOVES = {
    "fist": (120, 85, 430, 470),
    "open": (1030, 15, 1510, 485),
    "wave": (1030, 15, 1510, 485),
}


def load(name: str) -> Image.Image:
    return Image.open(HI / name).convert("RGBA")


def trim(img: Image.Image) -> Image.Image:
    return img.crop(img.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox())


def paste(canvas: Image.Image, img: Image.Image, box, angle: float = 0, mirror=False):
    """img'yi (x0, y0, x1, y1) kutusuna sığdırıp (gerekirse döndürüp) yapıştırır."""
    if mirror:
        img = img.transpose(Image.FLIP_LEFT_RIGHT)
    x0, y0, x1, y1 = [int(round(v)) for v in box]
    img = img.resize((max(1, x1 - x0), max(1, y1 - y0)), Image.LANCZOS)
    if angle:
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        img = img.rotate(angle, resample=Image.BICUBIC, expand=True)
        x0, y0 = int(cx - img.width / 2), int(cy - img.height / 2)
    layer = Image.new("RGBA", canvas.size)
    layer.paste(img, (x0, y0))
    canvas.alpha_composite(layer)


def umbrella(canvas, left, top, canopy_w, angle=0.0):
    """Açık şemsiye: tepe sol-üst (eski px) ve kubbe genişliği ile."""
    u = load("umbrella_open.png")
    bx0, by0, bx1, by1 = 45, 98, 977, 934
    s = canopy_w * K / (bx1 - bx0)
    u = u.crop((bx0, by0, bx1, by1))
    w, h = u.width * s, u.height * s
    x0, y0 = left * K, top * K
    paste(canvas, u, (x0, y0, x0 + w, y0 + h), angle)


def egg(canvas, box):
    e = load("egg.png").crop((183, 86, 838, 945))
    paste(canvas, e, [v * K for v in box])


def face(canvas, kind, box, angle=0.0):
    f = trim(load("faces.png").crop(FACES[kind]))
    paste(canvas, f, [v * K for v in box], angle)


def glove(canvas, kind, box, angle=0.0, mirror=False):
    g = trim(load("gloves.png").crop(GLOVES[kind]))
    paste(canvas, g, [v * K for v in box], angle, mirror)


def shield_ring(canvas, center, radius, width):
    """Kalkan baloncuğu: sarı, parlak, hafif saydam halka (eskisiyle aynı yer)."""
    cx, cy = center[0] * K, center[1] * K
    r, wd = radius * K, width * K
    size = canvas.size
    yy, xx = np.mgrid[0 : size[1], 0 : size[0]]
    d = np.hypot(xx - cx, yy - cy)
    t = np.clip(1 - np.abs(d - r) / (wd / 2), 0, 1)
    ring = t ** 0.6
    ang = np.arctan2(yy - cy, xx - cx)
    light = 0.5 + 0.5 * np.cos(ang + math.pi * 0.75)  # sol üstten ışık
    rgb = np.stack(
        [
            255 * np.ones_like(d),
            205 + 40 * light,
            40 + 150 * light * t,
        ],
        -1,
    )
    inner = np.clip(1 - d / r, 0, 1) * 0.10  # içte hafif sarı parıltı
    alpha = np.clip(ring * (0.55 + 0.4 * light) + inner * (d < r), 0, 1)
    arr = np.dstack([rgb, alpha * 255]).astype(np.uint8)
    layer = Image.fromarray(arr, "RGBA").filter(ImageFilter.GaussianBlur(1.2))
    # Parlama lekesi.
    hl = Image.new("RGBA", size)
    ImageDraw.Draw(hl).ellipse(
        (cx - r * 0.78, cy - r * 0.80, cx - r * 0.45, cy - r * 0.55),
        fill=(255, 255, 255, 150),
    )
    layer.alpha_composite(hl.filter(ImageFilter.GaussianBlur(6)))
    canvas.alpha_composite(layer)


def calm():
    c = Image.new("RGBA", (218 * K, 264 * K))
    umbrella(c, left=46, top=6, canopy_w=171)
    egg(c, (0, 97, 140, 264))
    face(c, "calm", (22, 160, 118, 206))
    glove(c, "fist", (114, 112, 142, 145), angle=-8)
    return c


def happy():
    c = Image.new("RGBA", (251 * K, 294 * K))
    umbrella(c, left=40, top=9, canopy_w=210, angle=-6)
    egg(c, (0, 127, 149, 294))
    face(c, "happy", (20, 186, 128, 240))
    glove(c, "fist", (128, 128, 160, 165), angle=-10)
    return c


def shield():
    c = Image.new("RGBA", (309 * K, 316 * K))
    umbrella(c, left=104, top=12, canopy_w=175)
    egg(c, (75, 89, 228, 258))
    face(c, "determined", (98, 150, 205, 196))
    glove(c, "fist", (200, 112, 232, 148), angle=-8)
    shield_ring(c, center=(154.5, 158), radius=146, width=18)
    return c


POSES = {"calm": calm, "happy": happy, "shield": shield}


def main():
    compare = "--compare" in sys.argv
    sheets = []
    for name, build in POSES.items():
        img = build()
        if compare:
            old = Image.open(OUT / f"img_yumi_{name}.png").convert("RGBA").resize(img.size)
            pair = Image.new("RGBA", (img.width * 2 + 20, img.height), (80, 140, 210, 255))
            pair.alpha_composite(old, (0, 0))
            pair.alpha_composite(img, (img.width + 20, 0))
            sheets.append(pair)
        else:
            img.save(OUT / f"img_yumi_{name}.png", optimize=True)
            print(name, img.size)
    if compare:
        h = sum(s.height for s in sheets)
        w = max(s.width for s in sheets)
        out = Image.new("RGBA", (w, h), (80, 140, 210, 255))
        y = 0
        for s in sheets:
            out.alpha_composite(s, (0, y))
            y += s.height
        out.thumbnail((1400, 2400))
        out.save(ROOT / ".design" / "compose_compare.png")
        print("compare:", ROOT / ".design" / "compose_compare.png")


if __name__ == "__main__":
    main()
