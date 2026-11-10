"""Eggbrella yasal sayfaları (fly-work.com/eggbrella/...) üretir.

Çıktı: legal_site/eggbrella/{about,privacy-policy,terms,cookies,csae}/index.html
Her sayfa tek dosya (CSS/JS gömülü), Türkçe + İngilizce, çerez/depolama yok.
Çalıştır: python3 legal_site/build.py
"""

from pathlib import Path

from content import PAGES  # noqa: E402  (aynı klasör)

ROOT = Path(__file__).parent / "eggbrella"
YEAR = "2026"
UPDATED = {"tr": "Son güncelleme: 10 Kasım 2026", "en": "Last updated: November 10, 2026"}
NAV = [
    ("about", {"tr": "Hakkında", "en": "About"}),
    ("privacy-policy", {"tr": "Gizlilik", "en": "Privacy"}),
    ("terms", {"tr": "Kullanım Koşulları", "en": "Terms"}),
    ("cookies", {"tr": "Çerezler", "en": "Cookies"}),
    ("csae", {"tr": "Çocuk Güvenliği", "en": "Child Safety"}),
]

TEMPLATE = """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title_tr} · Eggbrella</title>
<meta name="description" content="{desc}">
<meta name="robots" content="index,follow">
<meta name="theme-color" content="#7FC4F2">
<style>
:root {{
  --navy: #1E2A4A; --navy-soft: #5A6380;
  --sky: #7FC4F2; --sky-deep: #4AA3DE; --sky-soft: #D6EEFB;
  --cream: #FFF7E6; --cream-line: #EADBC0;
  --green: #34B233; --brand: #03624C; --yellow: #FFC83D;
  --text: #1E2A4A; --muted: #5A6380; --line: #EADBC0; --bg: #FFF7E6;
  --card: #FFFFFF;
}}
* {{ box-sizing: border-box; }}
html {{ -webkit-text-size-adjust: 100%; }}
body {{
  margin: 0; background: var(--bg); color: var(--text);
  font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}}
header {{
  position: relative; overflow: hidden;
  background:
    radial-gradient(ellipse 90% 80% at 12% -10%, rgba(255,200,61,.35), transparent 55%),
    radial-gradient(ellipse 70% 60% at 92% 10%, rgba(52,178,51,.18), transparent 50%),
    linear-gradient(180deg, #A8D9F7 0%, var(--sky) 42%, #BFE3F8 78%, var(--cream) 100%);
  border-bottom: 1px solid var(--line);
}}
header::before, header::after {{
  content: ""; position: absolute; border-radius: 50%; pointer-events: none;
  background: rgba(255,255,255,.35); box-shadow: inset 0 -4px 0 rgba(30,42,74,.06);
}}
header::before {{ width: 56px; height: 40px; left: 8%; top: 58%; }}
header::after {{ width: 34px; height: 24px; right: 14%; top: 36%; opacity: .7; }}
.wrap {{ max-width: 820px; margin: 0 auto; padding: 0 20px; position: relative; }}
.top {{ display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 20px 0 8px; }}
.brand {{
  display: inline-flex; align-items: center; gap: 10px;
  font-weight: 800; font-size: 22px; letter-spacing: -.35px;
  text-decoration: none; color: var(--navy);
}}
.brand-mark {{
  width: 36px; height: 36px; border-radius: 50%;
  background: linear-gradient(180deg, #FFEDB0, var(--yellow));
  border: 2px solid rgba(30,42,74,.12);
  box-shadow: 0 4px 0 rgba(30,42,74,.12), inset 0 2px 0 rgba(255,255,255,.5);
  position: relative; flex: 0 0 auto;
}}
.brand-mark::before {{
  content: ""; position: absolute; left: 50%; top: -10px; transform: translateX(-50%);
  width: 28px; height: 14px; border-radius: 14px 14px 4px 4px;
  background: linear-gradient(180deg, var(--brand), #024836);
  box-shadow: 0 2px 0 rgba(30,42,74,.15);
}}
.brand-mark::after {{
  content: ""; position: absolute; left: 11px; top: 12px; width: 5px; height: 5px;
  border-radius: 50%; background: var(--navy); box-shadow: 9px 0 0 var(--navy);
}}
.brand em {{ font-style: normal; color: var(--brand); }}
.lang {{
  display: inline-flex; border: 1px solid rgba(30,42,74,.12); border-radius: 999px;
  overflow: hidden; background: rgba(255,255,255,.85); backdrop-filter: blur(6px);
}}
.lang button {{
  border: 0; background: transparent; padding: 6px 14px; font: inherit; font-size: 14px;
  cursor: pointer; color: var(--muted);
}}
.lang button[aria-pressed="true"] {{ background: var(--navy); color: #fff; }}
nav.pages {{ display: flex; flex-wrap: wrap; gap: 6px 16px; padding: 4px 0 18px; font-size: 14px; }}
nav.pages a {{ color: var(--navy-soft); text-decoration: none; }}
nav.pages a.active {{
  color: var(--navy); font-weight: 700;
  border-bottom: 3px solid var(--yellow); padding-bottom: 2px;
}}
main {{ padding: 28px 0 56px; }}
h1 {{ font-size: 30px; line-height: 1.2; margin: 0 0 6px; letter-spacing: -.4px; color: var(--navy); }}
.updated {{ color: var(--muted); font-size: 14px; margin: 0 0 24px; }}
h2 {{
  font-size: 20px; margin: 34px 0 8px; padding-top: 10px;
  border-top: 1px dashed var(--line); color: var(--navy);
}}
h3 {{ font-size: 16px; margin: 20px 0 4px; color: var(--brand); }}
p, li {{ color: #243152; }}
ul {{ padding-left: 22px; }}
li {{ margin: 4px 0; }}
a {{ color: var(--sky-deep); }}
a:hover {{ color: var(--brand); }}
.note {{
  background: linear-gradient(180deg, #fff, #F7FBFF);
  border: 1px solid #C9E5F7; border-radius: 18px; padding: 16px 18px; margin: 16px 0;
  box-shadow: 0 8px 0 rgba(30,42,74,.04);
}}
.warn {{
  background: linear-gradient(180deg, #FFFCF3, #FFF6DE);
  border: 1px solid #F0D48A; border-radius: 18px; padding: 16px 18px; margin: 16px 0;
}}
table {{ width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 15px; }}
th, td {{ text-align: left; vertical-align: top; padding: 10px 12px; border-bottom: 1px solid var(--line); }}
th {{ background: var(--sky-soft); font-weight: 700; color: var(--navy); }}
.table {{
  overflow-x: auto; border: 1px solid var(--line); border-radius: 16px;
  background: var(--card); box-shadow: 0 6px 0 rgba(30,42,74,.03);
}}
.table table {{ margin: 0; }}
.table th:first-child, .table td:first-child {{ padding-left: 14px; }}
footer {{
  border-top: 1px solid var(--line); color: var(--muted); font-size: 14px;
  padding: 22px 0 40px;
  background: linear-gradient(180deg, transparent, rgba(127,196,242,.12));
}}
[data-lang] {{ display: none; }}
html[lang="tr"] [data-lang="tr"], html[lang="en"] [data-lang="en"] {{ display: block; }}
@media (max-width: 560px) {{
  h1 {{ font-size: 25px; }}
  body {{ font-size: 15.5px; }}
  .brand {{ font-size: 19px; }}
}}
</style>
</head>
<body>
<header>
  <div class="wrap">
    <div class="top">
      <a class="brand" href="../about/"><span class="brand-mark" aria-hidden="true"></span>Egg<em>brella</em></a>
      <div class="lang" role="group" aria-label="Language">
        <button type="button" data-set="tr" aria-pressed="true">Türkçe</button>
        <button type="button" data-set="en" aria-pressed="false">English</button>
      </div>
    </div>
    <nav class="pages">{nav}</nav>
  </div>
</header>
<main class="wrap">
  <section data-lang="tr">
    <h1>{title_tr}</h1>
    <p class="updated">{updated_tr}</p>
{body_tr}
  </section>
  <section data-lang="en">
    <h1>{title_en}</h1>
    <p class="updated">{updated_en}</p>
{body_en}
  </section>
</main>
<footer>
  <div class="wrap">
    <span data-lang="tr">© {year} Eggbrella · Fly Work. Tüm hakları saklıdır. İletişim: <a href="mailto:support@fly-work.com">support@fly-work.com</a></span>
    <span data-lang="en">© {year} Eggbrella · Fly Work. All rights reserved. Contact: <a href="mailto:support@fly-work.com">support@fly-work.com</a></span>
  </div>
</footer>
<script>
/* Dil: ?lang=en / #en ya da tarayıcı dili. Çerez veya yerel depolama kullanılmaz. */
(function () {{
  var q = new URLSearchParams(location.search).get('lang') || location.hash.replace('#', '');
  var nav = (navigator.language || 'tr').slice(0, 2).toLowerCase();
  var lang = (q === 'tr' || q === 'en') ? q : (nav === 'tr' ? 'tr' : 'en');
  function set(l) {{
    document.documentElement.lang = l;
    document.querySelectorAll('.lang button').forEach(function (b) {{
      b.setAttribute('aria-pressed', String(b.dataset.set === l));
    }});
    document.querySelectorAll('nav.pages a').forEach(function (a) {{
      a.textContent = a.dataset[l];
      a.href = a.getAttribute('href').split('?')[0] + '?lang=' + l;
    }});
    var t = document.querySelector('section[data-lang="' + l + '"] h1');
    if (t) document.title = t.textContent + ' · Eggbrella';
  }}
  document.querySelectorAll('.lang button').forEach(function (b) {{
    b.addEventListener('click', function () {{ set(b.dataset.set); }});
  }});
  set(lang);
}})();
</script>
</body>
</html>
"""


def build():
    for slug, page in PAGES.items():
        active = ' class="active"'
        nav = "".join(
            f'<a href="../{s}/" data-tr="{t["tr"]}" data-en="{t["en"]}"'
            f'{active if s == slug else ""}>{t["tr"]}</a>'
            for s, t in NAV
        )
        html = TEMPLATE.format(
            title_tr=page["title"]["tr"],
            title_en=page["title"]["en"],
            desc=page["desc"],
            nav=nav,
            updated_tr=UPDATED["tr"],
            updated_en=UPDATED["en"],
            body_tr=page["body"]["tr"],
            body_en=page["body"]["en"],
            year=YEAR,
        )
        out = ROOT / slug / "index.html"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(html, encoding="utf-8")
        print("written", out)


if __name__ == "__main__":
    build()
