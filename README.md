# Eggbrella

Şemsiyeli yumurta **Yumi** ile binadan aşağı süzülme oyunu (Flutter, iOS + Android).
Figma: `WRKvOcvsBOzx3djzG8qK5R` (EggBrella — 17 kare + geliştirici notları).
Backend: `../eggbrella-backend` (Express + MySQL + Bunny CDN), sözleşme `docs/API_CONTRACT.md`.

## Oynanış

- Yumi hep ekranın ortasından düşer; şemsiye yalnızca hızı değiştirir.
- **Basılı tut**: şemsiye açık, yavaş düşüş. **Bırak**: şemsiye kapalı, hızlı düşüş.
- Ayarlar > Kontrol: "Dokun aç-kapa" modunda her dokunuş şemsiyeyi açar / kapatır.
- Engel sıraları (balkon, çamaşır ipi, tente) aynı anda solda ve sağda durur; aradaki açıklık
  periyodik olarak sağa sola sallanır. Açıklık ortaya geldiğinde geçmek için hızını ayarla.
  Tenteye yavaş düşersen sekersin, hızlı düşersen kırılırsın. Güvercinler yatay uçar.
- Kat sayacı skordur; ortadaki altınlar toplanır.
- Kırılınca 5 sn içinde **50 coin** ile aynı kattan devam (3-2-1 sayaç + 2 sn koruma).
- Bölgeler: 100. kattan sonra cam ofis, 200. kattan sonra neon tonu (renk filtresi).
- Oyun sonunda son 8 saniye MP4 klip olarak üretilir ve sistem paylaşım sayfasıyla paylaşılır;
  ağ varsa klip Bunny CDN'e yüklenip bağlantısı da metne eklenir.

## Yasal sayfalar

`legal_site/` — fly-work.com/eggbrella/{about,privacy-policy,terms,cookies,csae}/
(Arrow Shift şablonu; Eggbrella paleti + Yumi markası; TR/EN, çerez yok).

```bash
python3 legal_site/build.py
```

Uygulama linkleri: `StringConstants.privacyPolicyUrl` / `termsUrl`.

## Çalıştırma

```bash
flutter pub get
./scripts/build_runner.sh                                   # json + flutter_gen + çeviri anahtarları
flutter run                                                 # canlı API
flutter run --dart-define-from-file=config/offline.json    # ağsız
```

## Yapı (arrow_shift ile aynı katmanlar)

```
lib/
  core/        di, init, network (dio + interceptor'lar), router, theme, widgets (Figma bileşenleri),
               sound (efekt + müzik), haptics, render (sahne ressamı + sprite'lar), clip (yerel kodlayıcı köprüsü)
  data/model/  json_serializable modeller (PlayerProgress, Token, User, ...)
  domain/      auth, player (yerel-önce + olay kuyruğu), settings, clip,
               game/ (FallWorld simülasyonu, WorldGenerator, GameReplay)
  presentation/ splash, home, game, result, settings — her biri bloc/ + view/{mixin,widgets}
ios/Runner/AppDelegate.swift                  klip kodlayıcı (AVAssetWriter)
android/.../MainActivity.kt                   klip kodlayıcı (MediaCodec + MediaMuxer)
scripts/   prepare_assets.py (Figma ham asset → assets/), generate_sounds.py, make_app_icon.py
.design/raw/  Figma'dan indirilen ham görseller
```

## Figma → uygulama

| Figma karesi | Uygulamada |
|---|---|
| 01-01-splash (typewriter), acilis | `splash` (`/`) — marka yazısı, sonra logo + yükleme |
| ana-sayfa | `home` |
| oyun-baslangic, ipucu (ilk 3 oyun) | `game` hazır / ipucu aşaması |
| oyun-acik, oyun-kapali | `game` oyun aşaması (canlı çizim) |
| kirilma, devam-teklifi, sayac | `game` kırılma / teklif / sayaç aşamaları |
| duraklatma, cikis-onayi | `game` üzerinde kartlar |
| oyun-sonu, yeni-rekor (konfeti) | `result` |
| klip-hazirlaniyor, klip-hata | `result` üzerinde kartlar |
| paylasim | sistem paylaşım sayfası (share_plus) |
| ayarlar | `settings` (saydam katman) |

## Testler

```bash
flutter analyze && flutter test     # FallWorld, GameReplay, PlayerRepository, GameBloc
```
