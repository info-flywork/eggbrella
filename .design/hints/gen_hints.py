"""İpucu görselleri (SVG): basılı tut + açık şemsiye, bırak + kapalı şemsiye.

Figma'daki kaynak PNG'ler 148 px olduğu için bulanıktı; vektör her yoğunlukta
keskin. flutter_svg filtre desteklemez, gölge kullanılmaz.
Çıktı: assets/icons/ic_hint_{hold,release}.svg — python3 .design/hints/gen_hints.py
"""
import math
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "assets" / "icons"

DEFS = """
<defs>
  <linearGradient id="skin" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#FFD9BF"/><stop offset="0.55" stop-color="#F7B48C"/>
    <stop offset="1" stop-color="#E58D63"/>
  </linearGradient>
  <linearGradient id="finger" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#FFD9BF"/><stop offset="0.6" stop-color="#F6AE85"/>
    <stop offset="1" stop-color="#E08559"/>
  </linearGradient>
  <radialGradient id="shine" cx="0.35" cy="0.3" r="0.5">
    <stop offset="0" stop-color="#FFFFFF" stop-opacity="0.75"/>
    <stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="red" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FF5A4E"/><stop offset="1" stop-color="#D3261E"/>
  </linearGradient>
  <linearGradient id="white" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#F1E4DC"/>
  </linearGradient>
  <linearGradient id="wood" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#B8693A"/><stop offset="0.5" stop-color="#9A522A"/>
    <stop offset="1" stop-color="#7A3E1E"/>
  </linearGradient>
  <linearGradient id="blue" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#4FA3FF"/><stop offset="1" stop-color="#1F6FD6"/>
  </linearGradient>
  <linearGradient id="furl" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#FF6B5F"/><stop offset="0.55" stop-color="#E23A30"/>
    <stop offset="1" stop-color="#B71F18"/>
  </linearGradient>
</defs>"""


def hand(tx: float, ty: float, scale: float = 1) -> str:
    """Aşağıyı gösteren el; parmak ucu (tx, ty)."""
    x, y = tx - 64 * scale, ty - 118 * scale  # çizimde parmak ucu 64,118
    return f"""
<g transform="translate({x:.1f} {y:.1f}) scale({scale})">
  <!-- bilek / avuç -->
  <path d="M8 6 C26 -2 70 -2 82 14 C92 28 88 52 78 62 C66 74 34 76 20 66 C6 56 0 22 8 6 Z"
        fill="url(#skin)"/>
  <!-- kıvrık parmaklar -->
  <ellipse cx="74" cy="44" rx="11" ry="13" fill="url(#skin)"/>
  <ellipse cx="80" cy="30" rx="10" ry="11" fill="url(#skin)"/>
  <path d="M68 36 C72 40 72 48 68 54" stroke="#D97C52" stroke-width="2" fill="none"
        stroke-linecap="round" opacity="0.55"/>
  <path d="M72 22 C77 25 78 32 75 37" stroke="#D97C52" stroke-width="2" fill="none"
        stroke-linecap="round" opacity="0.55"/>
  <!-- işaret parmağı -->
  <path d="M50 52 C50 44 66 42 70 52 L72 108 C72 122 56 122 56 108 Z" fill="url(#finger)"/>
  <ellipse cx="64" cy="112" rx="5" ry="3.5" fill="#FFE6D6" opacity="0.8"/>
  <path d="M57 78 C61 80 66 80 70 78" stroke="#D97C52" stroke-width="1.8" fill="none"
        stroke-linecap="round" opacity="0.5"/>
  <!-- başparmak -->
  <path d="M26 40 C30 30 52 32 56 44 C58 52 50 58 40 56 C30 54 24 48 26 40 Z" fill="url(#skin)"/>
  <path d="M30 44 C36 50 46 51 52 47" stroke="#D97C52" stroke-width="2" fill="none"
        stroke-linecap="round" opacity="0.45"/>
  <ellipse cx="36" cy="22" rx="24" ry="14" fill="url(#shine)"/>
</g>"""


def open_umbrella(cx: float, top: float, width: float) -> str:
    apex = (cx, top)
    n = 8
    left = cx - width / 2
    pts = []
    for i in range(n + 1):
        t = i / n
        px = left + width * t
        py = top + width * 0.36 + math.sin(math.pi * t) * width * 0.05
        pts.append((px, py))
    out = ['<g>']
    for i in range(n):
        a, b = pts[i], pts[i + 1]
        ca = (apex[0] + (a[0] - apex[0]) * 1.02, apex[1] + (a[1] - apex[1]) * 0.12)
        cb = (apex[0] + (b[0] - apex[0]) * 1.02, apex[1] + (b[1] - apex[1]) * 0.12)
        mid = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2 - width * 0.045)
        fill = "url(#red)" if i % 2 == 0 else "url(#white)"
        out.append(
            f'<path d="M{apex[0]:.1f} {apex[1]:.1f} Q{ca[0]:.1f} {ca[1]:.1f} {a[0]:.1f} {a[1]:.1f} '
            f'Q{mid[0]:.1f} {mid[1]:.1f} {b[0]:.1f} {b[1]:.1f} '
            f'Q{cb[0]:.1f} {cb[1]:.1f} {apex[0]:.1f} {apex[1]:.1f} Z" fill="{fill}" '
            f'stroke="#B8231C" stroke-opacity="0.25" stroke-width="0.8"/>'
        )
    # parlama
    out.append(
        f'<path d="M{cx - width * 0.32:.1f} {top + width * 0.24:.1f} '
        f'Q{cx - width * 0.25:.1f} {top + width * 0.05:.1f} {cx - width * 0.05:.1f} {top + width * 0.03:.1f}" '
        f'stroke="#FFFFFF" stroke-opacity="0.65" stroke-width="{width * 0.03:.1f}" '
        f'stroke-linecap="round" fill="none"/>'
    )
    for p in pts:
        out.append(f'<circle cx="{p[0]:.1f}" cy="{p[1]:.1f}" r="{width * 0.017:.1f}" fill="#8A4622"/>')
    out.append(f'<circle cx="{cx:.1f}" cy="{top - 2:.1f}" r="{width * 0.025:.1f}" fill="#8A4622"/>')
    # sap + kanca
    sy = pts[n // 2][1] - 2
    by = top + width * 0.86
    w = width * 0.032
    out.append(
        f'<path d="M{cx:.1f} {sy:.1f} L{cx:.1f} {by:.1f} '
        f'Q{cx:.1f} {by + width * 0.09:.1f} {cx - width * 0.07:.1f} {by + width * 0.09:.1f} '
        f'Q{cx - width * 0.13:.1f} {by + width * 0.09:.1f} {cx - width * 0.13:.1f} {by + width * 0.02:.1f}" '
        f'stroke="url(#wood)" stroke-width="{w:.1f}" stroke-linecap="round" fill="none"/>'
    )
    out.append("</g>")
    return "\n".join(out)


def closed_umbrella(cx: float, top: float, height: float) -> str:
    w = height * 0.2
    body_top = top + height * 0.17
    tip = top + height
    out = ['<g>']
    # kanca (üstte, sağa açılan)
    out.append(
        f'<path d="M{cx:.1f} {body_top + 4:.1f} L{cx:.1f} {top + height * 0.08:.1f} '
        f'Q{cx:.1f} {top:.1f} {cx + w * 0.55:.1f} {top:.1f} '
        f'Q{cx + w * 1.1:.1f} {top:.1f} {cx + w * 1.1:.1f} {top + height * 0.08:.1f}" '
        f'stroke="url(#wood)" stroke-width="{w * 0.24:.1f}" stroke-linecap="round" fill="none"/>'
    )
    body = (
        f"M{cx - w * 0.2:.1f} {body_top:.1f} "
        f"C{cx - w * 0.75:.1f} {body_top + height * 0.12:.1f} {cx - w * 0.55:.1f} {tip - height * 0.3:.1f} {cx:.1f} {tip:.1f} "
        f"C{cx + w * 0.55:.1f} {tip - height * 0.3:.1f} {cx + w * 0.75:.1f} {body_top + height * 0.12:.1f} {cx + w * 0.2:.1f} {body_top:.1f} Z"
    )
    out.append(f'<clipPath id="furlclip"><path d="{body}"/></clipPath>')
    out.append(f'<path d="{body}" fill="url(#furl)"/>')
    # beyaz spiral dilimler
    out.append('<g clip-path="url(#furlclip)">')
    for k in range(4):
        y0 = body_top + height * (0.05 + k * 0.2)
        out.append(
            f'<path d="M{cx - w:.1f} {y0 + height * 0.14:.1f} L{cx + w:.1f} {y0:.1f} '
            f'L{cx + w:.1f} {y0 + height * 0.07:.1f} L{cx - w:.1f} {y0 + height * 0.21:.1f} Z" '
            f'fill="url(#white)" opacity="0.95"/>'
        )
    out.append(
        f'<rect x="{cx - w:.1f}" y="{body_top:.1f}" width="{w * 0.8:.1f}" height="{height:.1f}" '
        f'fill="#FFFFFF" opacity="0.18"/>'
    )
    out.append("</g>")
    # bağlama kayışı
    sy = body_top + height * 0.2
    out.append(
        f'<rect x="{cx - w * 0.52:.1f}" y="{sy:.1f}" width="{w * 1.04:.1f}" height="{height * 0.05:.1f}" '
        f'rx="{height * 0.02:.1f}" fill="#B71F18"/>'
    )
    out.append(f'<circle cx="{cx:.1f}" cy="{tip + 1:.1f}" r="{w * 0.12:.1f}" fill="#8A4622"/>')
    out.append("</g>")
    return "\n".join(out)


def ripple(cx, cy, rx):
    ry = rx * 0.28
    return f"""
<g>
  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry:.1f}" fill="url(#blue)"/>
  <ellipse cx="{cx}" cy="{cy - 1}" rx="{rx * 0.72:.1f}" ry="{ry * 0.7:.1f}" fill="#FFFFFF"/>
  <ellipse cx="{cx}" cy="{cy - 1}" rx="{rx * 0.48:.1f}" ry="{ry * 0.46:.1f}" fill="url(#blue)"/>
  <ellipse cx="{cx}" cy="{cy - 1}" rx="{rx * 0.2:.1f}" ry="{ry * 0.2:.1f}" fill="#FFFFFF"/>
</g>"""


def dashes(x, y):
    st = 'stroke="#2F86F0" stroke-width="4" stroke-linecap="round"'
    return f"""
<path d="M{x} {y} L{x + 2} {y + 12}" {st}/>
<path d="M{x + 16} {y + 22} L{x + 30} {y + 10}" {st}/>
<path d="M{x + 12} {y + 36} L{x + 26} {y + 38}" {st}/>"""


def svg(w, h, body):
    return (
        f'<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" fill="none" '
        f'xmlns="http://www.w3.org/2000/svg">{DEFS}{body}</svg>\n'
    )


hold = svg(296, 144, ripple(64, 128, 46) + hand(64, 124, 0.93) + dashes(96, 64) + open_umbrella(216, 12, 132))

arrow = """
<path d="M128 108 L128 56" stroke="#1E3F7A" stroke-width="7" stroke-linecap="round"/>
<path d="M114 70 L128 50 L142 70 Z" fill="#1E3F7A" stroke="#1E3F7A" stroke-width="4"
      stroke-linejoin="round"/>
<circle cx="56" cy="120" r="3" fill="#7EC4FF"/><circle cx="96" cy="126" r="2.5" fill="#7EC4FF"/>
<circle cx="40" cy="104" r="2" fill="#A9D8FF"/>"""
release = svg(220, 134, hand(60, 104, 0.8) + arrow + closed_umbrella(186, 8, 120))

OUT.mkdir(parents=True, exist_ok=True)
(OUT / "ic_hint_hold.svg").write_text(hold)
(OUT / "ic_hint_release.svg").write_text(release)
preview = Path(__file__).parent / "preview.html"
preview.write_text(
    "<html><body style='background:#FDF5E6;margin:20px'>"
    f"<div style='display:flex;gap:30px;align-items:center'>"
    f"<img src='../../assets/icons/ic_hint_hold.svg' width=592>"
    f"<img src='../../assets/icons/ic_hint_release.svg' width=440></div>"
    f"<div style='display:flex;gap:30px;align-items:center;margin-top:20px'>"
    f"<img src='../../assets/icons/ic_hint_hold.svg' width=96>"
    f"<img src='../../assets/images/img_hint_hold.png' width=96>"
    f"<img src='../../assets/icons/ic_hint_release.svg' width=96>"
    f"<img src='../../assets/images/img_hint_release.png' width=96></div></body></html>"
)
print("ok")
