#!/usr/bin/env python3
"""Düşülen cepheyi geri plana iter (havadan perspektif).

Cephe ekranın en canlı ve keskin katmanıydı; engeller, coinler ve Yumi onunla
yarışıyordu. Burada ham başlangıç görselinden (bg_oyun_baslangic.png)
başlangıç görseli ve dikişsiz cephe şeridi yeniden üretilir; renk doygunluğu
ve kontrast düşürülür, gök rengi bir pus eklenir ve çok hafif yumuşatılır.
Tuğla / pencere tanınır kalır, ön plan öne çıkar.

Kullanım: python3 scripts/soften_facade.py   (prepare_assets.py'den sonra)
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / ".design" / "raw"
IMAGES = ROOT / "assets" / "images"

# prepare_assets.py ile aynı şerit.
FACADE_PERIOD = 217
FACADE_TILE_TOP = 271

# Gök pusu rengi (oyun / ana sayfa göğüyle uyumlu açık mavi).
HAZE = np.array([196, 222, 242], dtype=float)


def soften(
    img: Image.Image,
    *,
    saturation: float = 0.75,
    contrast: float = 0.85,
    haze: float = 0.16,
    blur: float = 0.6,
    wrap: bool = False,
    pivot: np.ndarray | None = None,
) -> Image.Image:
    a = np.array(img.convert("RGB")).astype(float)
    lum = (a[..., 0] * 0.299 + a[..., 1] * 0.587 + a[..., 2] * 0.114)[..., None]
    a = lum + (a - lum) * saturation  # doygunluk
    # Kontrast ortak bir değer etrafında (başlangıç görseli ve şerit aynı
    # tonda kalsın, birleştikleri yerde fark olmasın).
    mean = pivot if pivot is not None else a.mean(axis=(0, 1), keepdims=True)
    a = mean + (a - mean) * contrast  # kontrast
    a = a * (1 - haze) + HAZE * haze  # pus
    out = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))
    if blur > 0:
        if wrap:
            # Dikişsiz şerit: dikeyde sarmalayarak yumuşat.
            w, h = out.size
            tall = Image.new("RGB", (w, h * 3))
            for i in range(3):
                tall.paste(out, (0, i * h))
            out = tall.filter(ImageFilter.GaussianBlur(blur)).crop((0, h, w, 2 * h))
        else:
            out = out.filter(ImageFilter.GaussianBlur(blur))
    return out


def main(**kw) -> None:
    src = Image.open(RAW / "bg_oyun_baslangic.png").convert("RGB")
    a = np.array(src).astype(float)
    lum = (a[..., 0] * 0.299 + a[..., 1] * 0.587 + a[..., 2] * 0.114)[..., None]
    sat = kw.get("saturation", 0.75)
    pivot = (lum + (a - lum) * sat).mean(axis=(0, 1), keepdims=True)
    kw["pivot"] = pivot
    soften(src, **kw).save(
        IMAGES / "img_bg_game_start.jpg", quality=86, optimize=True, progressive=True
    )
    tile = src.crop((0, FACADE_TILE_TOP, src.width, FACADE_TILE_TOP + FACADE_PERIOD))
    soften(tile, wrap=True, **kw).save(IMAGES / "img_bg_facade.jpg", quality=88, optimize=True)
    print("img_bg_game_start.jpg, img_bg_facade.jpg yumuşatıldı")


if __name__ == "__main__":
    main()
