#!/usr/bin/env python3
"""Uygulama ikonu: asset_sources/app_icon/source.jpg → PNG çıktılar.

Çıktı: asset_sources/app_icon/{app_icon,android_foreground}.png
Sonra: dart run flutter_launcher_icons
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "asset_sources" / "app_icon"
SOURCE = OUT / "source.jpg"
SIZE = 1024


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    if not SOURCE.exists():
        raise SystemExit(f"kaynak yok: {SOURCE}")

    src = Image.open(SOURCE).convert("RGBA")
    if src.size != (SIZE, SIZE):
        src = src.resize((SIZE, SIZE), Image.LANCZOS)

    src.convert("RGB").save(OUT / "app_icon.png", optimize=True)
    # Adaptive ön plan: tam sahne; arka plan rengi gökyüzüyle uyumlu (#7FC4F2).
    src.save(OUT / "android_foreground.png", optimize=True)
    print("ikon yazıldı:", OUT)


if __name__ == "__main__":
    main()
