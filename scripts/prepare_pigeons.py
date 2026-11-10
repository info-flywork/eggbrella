#!/usr/bin/env python3
"""Güvercin kanat karelerini gövdeye hizalar.

Kaynak: .design/raw/pigeon_{up,glide,down}.png (Figma Components)
Çıktı: assets/images/img_pigeon_{up,glide,down}.png — aynı tuval, gövde
merkezi sabit (~0.525, 0.621). scene_renderer._pigeonBody ile eşleşmeli.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / ".design" / "raw"
OUT = ROOT / "assets" / "images"
NAMES = ("up", "glide", "down")
LONGEST = 420


def body_centroid(rgba: np.ndarray) -> tuple[float, float]:
    mask = rgba[:, :, 3] > 40
    ys, xs = np.where(mask)
    y0, y1 = int(ys.min()), int(ys.max())
    x0, x1 = int(xs.min()), int(xs.max())
    band = np.zeros_like(mask)
    y_lo = y0 + int((y1 - y0) * 0.35)
    y_hi = y0 + int((y1 - y0) * 0.95)
    band[y_lo:y_hi, x0:x1] = mask[y_lo:y_hi, x0:x1]
    ys, xs = np.where(band)
    return float(xs.mean()), float(ys.mean())


def main() -> None:
    frames = {
        n: np.array(Image.open(RAW / f"pigeon_{n}.png").convert("RGBA"))
        for n in NAMES
    }
    ref_cx, ref_cy = body_centroid(frames["glide"])
    shifts = {
        n: (ref_cx - body_centroid(a)[0], ref_cy - body_centroid(a)[1])
        for n, a in frames.items()
    }

    pads: list[tuple[float, float, float, float]] = []
    for n, a in frames.items():
        dx, dy = shifts[n]
        ys, xs = np.where(a[:, :, 3] > 20)
        pads.append((xs.min() + dx, ys.min() + dy, xs.max() + dx, ys.max() + dy))
    min_x = min(p[0] for p in pads)
    min_y = min(p[1] for p in pads)
    max_x = max(p[2] for p in pads)
    max_y = max(p[3] for p in pads)
    width = int(np.ceil(max_x - min_x + 1))
    height = int(np.ceil(max_y - min_y + 1))
    scale = LONGEST / max(width, height)
    out_w, out_h = round(width * scale), round(height * scale)

    body_x = (ref_cx - min_x) / width
    body_y = (ref_cy - min_y) / height
    print(f"canvas {width}x{height} → {out_w}x{out_h}")
    print(f"body anchor ({body_x:.3f}, {body_y:.3f})")

    OUT.mkdir(parents=True, exist_ok=True)
    for n, a in frames.items():
        canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        dx, dy = shifts[n]
        x = int(round(-min_x + dx))
        y = int(round(-min_y + dy))
        img = Image.fromarray(a)
        canvas.paste(img, (x, y), img)
        canvas.resize((out_w, out_h), Image.LANCZOS).save(
            OUT / f"img_pigeon_{n}.png",
            optimize=True,
        )
        print("wrote", f"img_pigeon_{n}.png")


if __name__ == "__main__":
    main()
