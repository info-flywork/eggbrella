#!/usr/bin/env python3
"""Gökyüzü arka planlarına uzak şehir silüeti ekler.

Ham görsel (.design/raw) -> silüetli JPEG (assets/images). Silüet yalnızca
ufuk çizgisinin üstündeki mavi gök piksellerine çizilir; su deposu, saksı,
bank, anten ve beyaz bulutlar önde kalır. İki katman: uzak (soluk) ve yakın
(biraz koyu), havadan perspektif hissi için gök rengiyle karıştırılır.

Kullanım: python3 scripts/add_skyline.py   (prepare_assets.py'den sonra)
"""

from __future__ import annotations

import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / ".design" / "raw"
IMAGES = ROOT / "assets" / "images"

# ham dosya -> (çıktı, ufuk çizgisi y px; None = görselin altı,
#               bina silüetinin başladığı y px; None = yok)
TARGETS = {
    "bg_ana_sayfa.png": ("img_bg_rooftop.jpg", 862, None),
    "bg_gokyuzu.png": ("img_bg_sky.jpg", None, None),
}

# Oyundaki bina silüetiyle aynı (SceneRenderer._silhouette, 1-99. kat):
# renk = koyu + (açık - koyu) * (0.08 + 0.7 * parlaklık)
SIL_DARK = np.array([0.16, 0.20, 0.36])
SIL_LIGHT = np.array([0.30, 0.36, 0.58])

FAR = (np.array([96, 128, 186]), 0.42)
NEAR = (np.array([70, 96, 156]), 0.62)


def _skyline(width: int, base: int, seed: int, h_min: int, h_max: int) -> Image.Image:
    """Ufuk çizgisine oturan bina silüeti maskesi (2x çizilip küçültülür)."""
    ss = 2
    img = Image.new("L", (width * ss, (base + 10) * ss), 0)
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed)
    x = -rnd.randint(0, 40)
    while x < width:
        w = rnd.randint(42, 118)
        h = rnd.randint(h_min, h_max)
        top = base - h
        d.rectangle([x * ss, top * ss, (x + w) * ss, (base + 10) * ss], fill=255)
        kind = rnd.random()
        if kind < 0.3:
            # basamaklı tepe
            iw = int(w * rnd.uniform(0.45, 0.7))
            ih = rnd.randint(14, 40)
            ix = x + (w - iw) // 2
            d.rectangle([ix * ss, (top - ih) * ss, (ix + iw) * ss, top * ss], fill=255)
            if rnd.random() < 0.6:
                ax = ix + iw // 2
                d.rectangle(
                    [(ax - 1) * ss, (top - ih - rnd.randint(18, 40)) * ss, (ax + 1) * ss, (top - ih) * ss],
                    fill=255,
                )
        elif kind < 0.5:
            # anten
            ax = x + rnd.randint(8, max(9, w - 8))
            d.rectangle([(ax - 1) * ss, (top - rnd.randint(20, 48)) * ss, (ax + 1) * ss, top * ss], fill=255)
        elif kind < 0.65:
            # çatı su deposu
            tw = rnd.randint(14, 22)
            tx = x + rnd.randint(4, max(5, w - tw - 4))
            d.rectangle([tx * ss, (top - 26) * ss, (tx + tw) * ss, (top - 10) * ss], fill=255)
            d.polygon(
                [(tx * ss, (top - 26) * ss), ((tx + tw // 2) * ss, (top - 34) * ss), ((tx + tw) * ss, (top - 26) * ss)],
                fill=255,
            )
            d.rectangle([(tx + 2) * ss, (top - 10) * ss, (tx + 4) * ss, top * ss], fill=255)
            d.rectangle([(tx + tw - 4) * ss, (top - 10) * ss, (tx + tw - 2) * ss, top * ss], fill=255)
        elif kind < 0.75:
            # eğik çatı
            d.polygon(
                [(x * ss, top * ss), ((x + w) * ss, top * ss), ((x + w // 2) * ss, (top - rnd.randint(16, 34)) * ss)],
                fill=255,
            )
        x += w + rnd.randint(-6, 10)
    return img.resize((width, base + 10), Image.LANCZOS)


def add_skyline(
    src: Path, dst: Path, horizon: int | None, building_top: int | None, seed: int
) -> None:
    img = Image.open(src).convert("RGB")
    a = np.array(img).astype(float)
    h, w = a.shape[:2]
    base = horizon if horizon is not None else h
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    v = a.max(-1) / 255
    # gök: mavi baskın, açık renk; nesneler ve bulutlar dışarıda kalır
    sky = np.clip((b - r - 4) / 14, 0, 1) * np.clip((v - 0.5) / 0.1, 0, 1)
    rows = np.arange(h)[:, None]
    sky = np.where(rows < base, sky, 0)
    sky = np.array(Image.fromarray((sky * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.6))) / 255

    scale = w / 1024
    layers = [
        (_skyline(w, base, seed, int(120 * scale), int(250 * scale)), FAR),
        (_skyline(w, base, seed + 7, int(60 * scale), int(160 * scale)), NEAR),
    ]
    out = a.copy()
    for mask_img, (color, strength) in layers:
        m = np.zeros((h, w))
        mm = np.array(mask_img) / 255
        m[: min(h, mm.shape[0]), :] = mm[: min(h, mm.shape[0]), :]
        k = (m * sky * strength)[..., None]
        out = out * (1 - k) + color[None, None, :] * k
    if building_top is not None:
        # Çatının taş kenarının altı: oyundaki gibi tek renk bina silüeti.
        part = out[building_top:] / 255
        lum = part @ np.array([0.299, 0.587, 0.114])
        t = (0.08 + 0.7 * lum)[..., None]
        out[building_top:] = (SIL_DARK + (SIL_LIGHT - SIL_DARK) * t) * 255
    Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(
        dst, quality=86, optimize=True, progressive=True
    )
    print(dst.name, img.size)


def main() -> None:
    for i, (src, (dst, horizon, building)) in enumerate(TARGETS.items()):
        add_skyline(RAW / src, IMAGES / dst, horizon, building, seed=21 + i)


if __name__ == "__main__":
    main()
