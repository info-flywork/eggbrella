#!/usr/bin/env python3
"""Yumi skin assetleri: her Yumi görselini iki katmana ayırır ve renklendirir.

Katmanlar (aynı tuval boyutu, piksel olarak ayrık; üst üste çizilince orijinal):
  umbrella = şemsiye kubbesi (kırmızı + beyaz dilimler)
  egg      = geri kalan her şey (yumurta, yüz, eldiven, sap)

Skinler katmanları yeniden renklendirir; gölgeler korunur, böylece her yumurta
skini her şemsiye skiniyle çalışır ve oyundaki çapa noktaları değişmez.

Çıktı:
  assets/skins/egg/<skin>/<pose>.png
  assets/skins/umbrella/<skin>/<pose>.png
  .design/skins_preview.png (kontrol için)

Kullanım: python3 scripts/make_skins.py
"""

from __future__ import annotations

import colorsys
import math
import random
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "images"
OUT = ROOT / "assets" / "skins"
PREVIEW = ROOT / ".design" / "skins_preview.png"

POSES = {
    "calm": "img_yumi_calm.png",
    "happy": "img_yumi_happy.png",
    "scared": "img_yumi_scared.png",
    "shield": "img_yumi_shield.png",
    "sleep": "img_yumi_sleep.png",
    "bandaged": "img_yumi_bandaged.png",
    "broken": "img_broken_egg.png",
}


# --- Renk yardımcıları --------------------------------------------------------


def rgb(hex_: str) -> np.ndarray:
    hex_ = hex_.lstrip("#")
    return np.array([int(hex_[i : i + 2], 16) / 255 for i in (0, 2, 4)])


def hsv(a: np.ndarray):
    c = a[..., :3] / 255.0
    mx, mn = c.max(-1), c.min(-1)
    d = mx - mn
    safe = np.where(d > 1e-6, d, 1)
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    h = np.where(
        mx == r, ((g - b) / safe) % 6, np.where(mx == g, (b - r) / safe + 2, (r - g) / safe + 4)
    ) / 6.0
    h = np.where(d > 1e-6, h, 0)
    s = np.where(mx > 0, d / np.where(mx > 0, mx, 1), 0)
    return h, s, mx


def luma(a: np.ndarray) -> np.ndarray:
    c = a[..., :3] / 255.0
    return c[..., 0] * 0.299 + c[..., 1] * 0.587 + c[..., 2] * 0.114


def smooth(x, lo, hi):
    t = np.clip((x - lo) / (hi - lo), 0, 1)
    return t * t * (3 - 2 * t)


# --- Maske yardımcıları -------------------------------------------------------


def components(mask: np.ndarray) -> list[np.ndarray]:
    """4-komşu bağlı bileşenler (büyükten küçüğe), her biri (N, 2) y,x."""
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    out = []
    ys, xs = np.nonzero(mask)
    for y0, x0 in zip(ys, xs):
        if seen[y0, x0]:
            continue
        q = deque([(y0, x0)])
        seen[y0, x0] = True
        pts = []
        while q:
            y, x = q.popleft()
            pts.append((y, x))
            for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                    seen[ny, nx] = True
                    q.append((ny, nx))
        out.append(np.array(pts))
    out.sort(key=len, reverse=True)
    return out


def hull_mask(points: np.ndarray, shape) -> np.ndarray:
    """Noktaların dışbükey zarfı, doldurulmuş maske."""
    pts = sorted({(int(x), int(y)) for y, x in points})
    if len(pts) < 3:
        return np.zeros(shape, dtype=bool)

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower, upper = [], []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    poly = lower[:-1] + upper[:-1]
    img = Image.new("L", (shape[1], shape[0]), 0)
    ImageDraw.Draw(img).polygon(poly, fill=255, outline=255)
    return np.array(img) > 0


def dilate(mask: np.ndarray, r: int) -> np.ndarray:
    img = Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(2 * r + 1))
    return np.array(img) > 0


def _solid(c: np.ndarray, shape) -> bool:
    """Dolu parça mı (kalkan halkası gibi içi boş şekiller değil)."""
    if len(c) < 30:
        return False
    return len(c) / max(1, hull_mask(c, shape).sum()) > 0.35


# --- Katmanlara ayırma -------------------------------------------------------


def split(a: np.ndarray, rim_light: bool = True):
    """(umbrella_mask, canopy_red, canopy_white, shell_weight, shell_bbox)."""
    h, s, v = hsv(a)
    alpha = a[..., 3] > 30
    red = alpha & ((h < 0.045) | (h > 0.94)) & (s > 0.45) & (v > 0.25)
    comps = components(red)
    # Gövde: en büyük krem bileşenin zarfı. Yanak ve ağız gövdenin içinde
    # kalır; kubbenin dilimleri (beyazlarla ayrık parçalar) gövdenin dışında.
    cream0 = alpha & (h > 0.03) & (h < 0.17) & (s > 0.06) & (s < 0.6) & (v > 0.45)
    cream_comps = components(cream0)
    body0 = np.zeros(red.shape, dtype=bool)
    solid0 = [c for c in cream_comps if _solid(c, red.shape)]
    for c in solid0[:3]:
        if len(c) >= len(solid0[0]) * 0.25:
            body0 |= hull_mask(c, red.shape)
    big = []
    for c in comps:
        if len(c) < 30:
            continue
        # Yanak / ağız tamamen gövdenin içindedir; kubbe parçalarının en az
        # %30'u gövdenin dışına taşar.
        outside = 1 - body0[c[:, 0], c[:, 1]].mean()
        if outside > 0.3:
            big.append(c)
    # Küçük kırmızımsı kırıntılar (koyu sap, gölge) yalnızca büyük kubbe
    # parçalarının kutusu içindeyse sayılır; yoksa zarf ele kadar uzar.
    if big:
        core = [c for c in big if len(c) >= len(big[0]) * 0.02]
        allc = np.concatenate(core)
        (cy0, cx0), (cy1, cx1) = allc.min(0), allc.max(0)
        my, mx = (cy1 - cy0) * 0.05, (cx1 - cx0) * 0.05
        big = [
            c for c in big
            if len(c) >= len(big[0]) * 0.02
            or (cy0 - my <= c[:, 0].mean() <= cy1 + my and cx0 - mx <= c[:, 1].mean() <= cx1 + mx)
        ]
    canopy = np.zeros(red.shape, dtype=bool)
    if big:
        canopy = hull_mask(np.concatenate(big), red.shape)
        canopy = dilate(canopy, 2) & alpha

    cream = alpha & (h > 0.03) & (h < 0.17) & (s > 0.06) & (s < 0.6) & (v > 0.45)
    shell_comps = components(cream & ~canopy) if cream.any() else []
    body = np.zeros(red.shape, dtype=bool)
    solid = [c for c in shell_comps if _solid(c, red.shape)]
    for c in solid[:3]:
        if len(c) >= len(solid[0]) * 0.15:
            body |= hull_mask(c, red.shape)

    whiteish = (s < 0.35) & (v > 0.55)
    red_shade = ((h < 0.06) | (h > 0.92)) & (s > 0.3)
    in_both = canopy & body
    umbrella = (canopy & ~body) | (in_both & (red_shade | (whiteish & (s < 0.12))))

    canopy_red = umbrella & red_shade
    red_dist = np.minimum(h, 1 - h)
    canopy_white = umbrella & (v > 0.4) & ~red_shade & ((s < 0.35) | (red_dist < 0.13))
    canopy_white |= umbrella & (red_dist < 0.13) & (s <= 0.6) & (v > 0.5)

    egg_layer = alpha & ~umbrella
    # Kabuk ağırlığı: krem tonlar 1, beyaz (eldiven, parlama), koyu (göz),
    # doygun (yanak, ağız, sarı, sap) 0.
    w = (
        smooth(h, 0.02, 0.05) * (1 - smooth(h, 0.15, 0.19))
        * smooth(s, 0.05, 0.12) * (1 - smooth(s, 0.5, 0.62))
        * smooth(v, 0.42, 0.55)
    )
    # Kenar ışığı: gökyüzünden yansıyan mavimsi açık tonlar (gövde içinde)
    # kısmen boyanır; yoksa renkli kabukta krem bir hilal kalır.
    rim = smooth(h, 0.45, 0.52) * (1 - smooth(h, 0.78, 0.85)) * (1 - smooth(s, 0.3, 0.4))
    rim *= smooth(v, 0.6, 0.75) * (1 - smooth(v, 0.9, 0.97))
    if rim_light and body.any():
        ys, xs = np.nonzero(body)
        band = max(3, int((xs.max() - xs.min()) * 0.05))
        edge = body & dilate(~body, band)
        w = np.maximum(w, np.where(edge, rim * 0.7, 0))
    # Eldiven: beyazımsı (krem olmayan) bileşenlerden gövdenin dışına taşanlar;
    # kenar ışığı kuralı onları boyamasın.
    white = egg_layer & (s < 0.25) & (v > 0.55) & ~((h > 0.03) & (h < 0.17) & (s > 0.06))
    glove = np.zeros_like(white)
    for c in components(white):
        if len(c) < 20:
            continue
        if 1 - body[c[:, 0], c[:, 1]].mean() >= 0.2:
            glove[c[:, 0], c[:, 1]] = True
    glove = dilate(glove, 1)
    w = np.where(egg_layer & dilate(body, 3) & ~glove, w, 0)
    ys, xs = np.nonzero(w > 0.5)
    bbox = (xs.min(), ys.min(), xs.max(), ys.max()) if len(xs) else (0, 0, 1, 1)
    return umbrella, canopy_red, canopy_white, w, bbox


# --- Skinler ------------------------------------------------------------------

# Yumurta skinleri: kabuk rengi (kremin yerini alır) + isteğe bağlı desen.
EGG_SKINS = {
    "classic": None,
    "golden": dict(color="#F6C343", gloss=0.35),
    "chocolate": dict(color="#8A5634"),
    "mint": dict(color="#A8E6CF"),
    "dino": dict(color="#9BD06A", spots="#5E9E3A"),
    "galaxy": dict(color="#5B4BB7", stars=True),
    "bubblegum": dict(color="#FFB3D1", spots="#FFF0F6", spot_size=0.55),
}

# Şemsiye skinleri: kırmızı dilim rengi, beyaz dilim rengi (None = beyaz kalır).
UMBRELLA_SKINS = {
    "classic": None,
    "ocean": dict(main="#2F7FE0", alt=None),
    "lime": dict(main="#4CC24A", alt="#F4FFD9"),
    "grape": dict(main="#8B4FD8", alt="#F1E6FF"),
    "sunny": dict(main="#FFB020", alt="#FFF4C2"),
    "midnight": dict(main="#1F2A55", alt="#F2C94C"),
    "rainbow": dict(main="rainbow", alt=None),
}

CREAM_REF = 0.86  # krem kabuğun tipik parlaklığı
RED_REF = 0.42  # kırmızı dilimin tipik parlaklığı (luma)


def recolor_egg(a: np.ndarray, weight: np.ndarray, bbox, skin: dict, seed: int) -> np.ndarray:
    out = a.astype(float).copy()
    lum = luma(a)
    shade = np.clip(lum / CREAM_REF, 0, 1.25)[..., None]
    target = rgb(skin["color"])[None, None, :]
    col = np.clip(target * shade, 0, 1)
    gloss = skin.get("gloss", 0)
    if gloss:
        hi = smooth(lum, 0.82, 0.97)[..., None]
        col = col * (1 - hi * gloss) + hi * gloss
    x0, y0, x1, y1 = bbox
    bw, bh = max(1, x1 - x0), max(1, y1 - y0)
    yy, xx = np.mgrid[0 : a.shape[0], 0 : a.shape[1]]
    u, vv = (xx - x0) / bw, (yy - y0) / bh  # kabuğa göre konum (pozlar arası tutarlı)
    if "spots" in skin:
        rnd = random.Random(seed)
        spot = np.zeros(a.shape[:2])
        for _ in range(9):
            cu, cv = rnd.uniform(0.08, 0.92), rnd.uniform(0.05, 0.95)
            r = rnd.uniform(0.05, 0.09) * skin.get("spot_size", 1)
            d = np.hypot((u - cu) * bw / bh, vv - cv)
            spot = np.maximum(spot, 1 - smooth(d, r * 0.8, r))
        sc = rgb(skin["spots"])[None, None, :] * np.clip(shade, 0, 1.1)
        col = col * (1 - spot[..., None] * 0.85) + np.clip(sc, 0, 1) * spot[..., None] * 0.85
    if skin.get("stars"):
        # Galaksi: üstten alta mor-lacivert geçiş + küçük yıldızlar.
        grad = np.clip(vv, 0, 1)[..., None]
        top, bottom = rgb("#7B5BE0"), rgb("#2A2F7A")
        col = np.clip((top * (1 - grad) + bottom * grad) * shade * 1.05, 0, 1)
        rnd = random.Random(seed)
        star = np.zeros(a.shape[:2])
        for _ in range(26):
            cu, cv = rnd.uniform(0.05, 0.95), rnd.uniform(0.05, 0.95)
            r = rnd.uniform(0.008, 0.02)
            d = np.hypot((u - cu) * bw / bh, vv - cv)
            star = np.maximum(star, 1 - smooth(d, r * 0.3, r))
        col = col * (1 - star[..., None]) + star[..., None]
    w = weight[..., None]
    out[..., :3] = out[..., :3] * (1 - w) + col * 255 * w
    return out


def recolor_umbrella(a, red, white, skin: dict) -> np.ndarray:
    out = a.astype(float).copy()
    lum = luma(a)
    if skin["main"] == "rainbow":
        ys, xs = np.nonzero(red | white)
        cx, cy = xs.mean(), ys.min() + (ys.max() - ys.min()) * 0.15
        yy, xx = np.mgrid[0 : a.shape[0], 0 : a.shape[1]]
        ang = (np.arctan2(yy - cy, xx - cx) / (2 * math.pi)) % 1.0
        hue = (ang * 2.2) % 1.0
        main = np.stack(
            np.vectorize(lambda t: colorsys.hsv_to_rgb(t, 0.75, 0.98), otypes=[float] * 3)(hue),
            axis=-1,
        )
    else:
        main = rgb(skin["main"])[None, None, :]
    shade = np.clip(lum / RED_REF, 0, 1.6)[..., None]
    col = np.clip(main * shade, 0, 1) * 255
    # Kırmızılık ağırlığı (sürekli): dilimler arası geçiş ve kubbenin alt
    # yüzündeki pembemsi tonlar ikiye bölünmez, yumuşak karışır.
    h, s, v = hsv(a)
    red_dist = np.minimum(h, 1 - h)
    # Kırmızı dilimler çok doygun; gölgedeki beyaz dilimler şeftali tonuna
    # (s 0.3-0.5) kayar, onlar beyaz sayılır.
    # Kahverengi sap/uçlar koyu ve turuncuya yakın; kırmızı dilimler parlak.
    # Parlak piksellerde ton toleransı geniş (sarı parıltıyla turuncuya kayan
    # kırmızılar), koyu piksellerde dar (sap boyanmaz).
    tol = 0.03 + 0.05 * smooth(v, 0.5, 0.7)
    hue_red = 1 - smooth(red_dist - tol, -0.005, 0.01)
    wr = smooth(s, 0.48, 0.66) * hue_red
    area = (red | white)
    wr = np.where(area, wr, 0)
    # Kaynak görseldeki doku gürültüsü dilim geçişinde beneklenmesin.
    blurred = Image.fromarray((wr * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    wr = np.where(area, np.array(blurred) / 255.0, 0)[..., None]
    if skin.get("alt"):
        alt = rgb(skin["alt"])[None, None, :]
        wshade = np.clip(lum / 0.95, 0, 1.05)[..., None]
        base = np.clip(alt * wshade, 0, 1) * 255
        base = np.where(area[..., None], base, out[..., :3])
    else:
        base = out[..., :3]
    out[..., :3] = base * (1 - wr) + col * wr
    # Kahverengi sap / uç topları (doygun ama kırmızı değil) olduğu gibi kalır.
    keep = ((1 - hue_red) * smooth(s, 0.5, 0.65))[..., None]
    out[..., :3] = out[..., :3] * (1 - keep) + a[..., :3] * keep
    return out


def save(arr: np.ndarray, mask: np.ndarray, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    o = arr.copy()
    o[..., 3] = np.where(mask, o[..., 3], 0)
    o[..., :3] = np.where(mask[..., None], o[..., :3], 0)
    Image.fromarray(np.clip(o, 0, 255).astype(np.uint8)).save(path, optimize=True)


def main():
    previews = {}
    for pose, file in POSES.items():
        a = np.array(Image.open(SRC / file).convert("RGBA")).astype(float)
        # Kalkan baloncuğu ve kırık yumurtanın akı da mavimsi parlar; orada
        # kenar ışığı boyanmaz.
        umbrella, red, white, weight, bbox = split(a, rim_light=pose not in ("shield", "broken"))
        egg_mask = (a[..., 3] > 0) & ~umbrella
        for i, (sid, skin) in enumerate(EGG_SKINS.items()):
            arr = a if skin is None else recolor_egg(a, weight, bbox, skin, seed=11 + i)
            save(arr, egg_mask, OUT / "egg" / sid / f"{pose}.png")
        for sid, skin in UMBRELLA_SKINS.items():
            arr = a if skin is None else recolor_umbrella(a, red, white, skin)
            save(arr, umbrella, OUT / "umbrella" / sid / f"{pose}.png")
        previews[pose] = a.shape
        print(f"{pose}: umbrella {umbrella.sum()} px, shell bbox {bbox}")
    _preview()


def _preview():
    """Satırlar: yumurta skinleri (klasik şemsiye) + şemsiye skinleri."""
    cell = 150
    rows = [(e, "classic") for e in EGG_SKINS] + [("classic", u) for u in UMBRELLA_SKINS][1:]
    poses = list(POSES)
    sheet = Image.new("RGBA", (cell * len(poses), cell * len(rows)), (90, 150, 220, 255))
    for r, (e, u) in enumerate(rows):
        for c, pose in enumerate(poses):
            egg = Image.open(OUT / "egg" / e / f"{pose}.png")
            umb = Image.open(OUT / "umbrella" / u / f"{pose}.png")
            img = Image.alpha_composite(umb, egg)
            img.thumbnail((cell - 6, cell - 6))
            sheet.alpha_composite(img, (c * cell + 3, r * cell + 3))
    PREVIEW.parent.mkdir(exist_ok=True)
    sheet.save(PREVIEW)
    print("preview:", PREVIEW)


if __name__ == "__main__":
    main()
