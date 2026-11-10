#!/usr/bin/env python3
"""Figma'dan indirilen ham asset'leri (.design/raw) uygulamaya hazırlar.

- Saydam PNG'ler alfa sınırına kırpılır (Figma bunları yüzde ofsetlerle
  kırpıyordu) ve en fazla 3x ekran boyuna küçültülür.
- Arka planlar JPEG'e çevrilir (saydamlık yok, boyut küçülür).
- SVG ikonlar olduğu gibi kopyalanır.

Kullanım: python3 scripts/prepare_assets.py
Ardından: python3 scripts/soften_facade.py (cepheyi geri plana iter) ve
python3 scripts/add_skyline.py (gökyüzüne uzak şehir silüeti).
"""
from pathlib import Path
import shutil

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / ".design" / "raw"
IMAGES = ROOT / "assets" / "images"
ICONS = ROOT / "assets" / "icons"

# ham dosya -> (çıktı adı, hedef en büyük kenar px)
SPRITES = {
    "logo.png": ("img_logo.png", 1050),
    "yumi_calm.png": ("img_yumi_calm.png", 830),
    "yumi_happy.png": ("img_yumi_happy.png", 700),
    "yumi_korkmus.png": ("img_yumi_scared.png", 570),
    "yumi_shield.png": ("img_yumi_shield.png", 1000),
    "yumi_sleep.png": ("img_yumi_sleep.png", 620),
    "yumi_bandajli.png": ("img_yumi_bandaged.png", 740),
    "kirik_yumurta.png": ("img_broken_egg.png", 630),
    "balkon.png": ("img_balcony.png", 1290),
    "camasir_ipi.png": ("img_clothesline.png", 1290),
    "hiz_cizgileri.png": ("img_speed_lines.png", 1024),
    "kurdele.png": ("img_ribbon.png", 1000),
    "halka.png": ("img_ring.png", 340),
}

# Hız çizgileri tüm ekranı kaplar: kırpılmaz.
NO_TRIM = {"hiz_cizgileri.png"}

BACKGROUNDS = {
    "bg_gokyuzu.png": "img_bg_sky.jpg",
    "bg_ana_sayfa.png": "img_bg_rooftop.jpg",
    "bg_oyun_baslangic.png": "img_bg_game_start.jpg",
}

# 3D ikonlar (mağaza, ayarlar, ...) assets/images/icons altında:
# .design/raw/icons_3d_sheet.png ızgarasından kesildi (yeniden ölçekleme yok).
ICON_FILES = {
    "ic_chevron.svg": "ic_chevron.svg",
    "ic_video_off.svg": "ic_video_off.svg",
}


def trim(img: Image.Image) -> Image.Image:
    bbox = img.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    return img.crop(bbox) if bbox else img


def fit(img: Image.Image, longest: int) -> Image.Image:
    scale = longest / max(img.size)
    if scale >= 1:
        return img
    size = (round(img.width * scale), round(img.height * scale))
    return img.resize(size, Image.LANCZOS)


# Oyun cephesi: başlangıç görselindeki pencere sırası 217 px'de tekrar eder.
# Bu periyotta dikişsiz bir şerit kesilir; başlangıç sahnesi de şeridin
# başladığı yerin bir periyot altında biter (GameConfig.introImageHeight).
FACADE_PERIOD = 217
FACADE_TILE_TOP = 271


def make_facade_tile() -> None:
    src = Image.open(RAW / "bg_oyun_baslangic.png").convert("RGB")
    tile = src.crop((0, FACADE_TILE_TOP, src.width, FACADE_TILE_TOP + FACADE_PERIOD))
    tile.save(IMAGES / "img_bg_facade.jpg", quality=88, optimize=True)
    print(f"{'img_bg_facade.jpg':28s} {tile.size}")


def main() -> None:
    IMAGES.mkdir(parents=True, exist_ok=True)
    ICONS.mkdir(parents=True, exist_ok=True)
    for src, (dst, longest) in SPRITES.items():
        img = Image.open(RAW / src).convert("RGBA")
        if src not in NO_TRIM:
            img = trim(img)
        img = fit(img, longest)
        img.save(IMAGES / dst, optimize=True)
        print(f"{dst:28s} {img.size}")
    for src, dst in BACKGROUNDS.items():
        img = Image.open(RAW / src).convert("RGB")
        img.save(IMAGES / dst, quality=86, optimize=True, progressive=True)
        print(f"{dst:28s} {img.size}")
    make_facade_tile()
    for src, dst in ICON_FILES.items():
        shutil.copyfile(RAW / src, ICONS / dst)


if __name__ == "__main__":
    main()
