# Eggbrella API sözleşmesi

Taban adres: `https://eggbrella.fly-work.com` (`--dart-define=BASE_URL=...` ile değişir).
Tüm cevaplar `{ "status": "success" | "error", "message": "ok" | <hata_kodu>, "data": {...} | null }`.
Alanlar snake_case. Kimlik: `Authorization: Bearer <access_token>`; 401'de uygulama
`/auth/refresh` ile yeniler (`ExpiredTokenInterceptor`).

## Oturum

`POST /auth/device` `{ device_id, platform?, app_version? }`
→ `{ access_token, refresh_token, user: { id } }`

`POST /auth/refresh` `{ refresh_token }` → `{ access_token, refresh_token }`

## Oyuncu (`PlayerProgress`)

```json
{ "coins": 130, "best_floor": 42, "games_played": 3, "continue_price": 50 }
```

`GET /player/progress` → PlayerProgress

`POST /player/game-over`
`{ client_event_id, floor, coins_collected, continues_used, duration_ms }` → PlayerProgress
(idempotent; kat ve coin makul sınırlara kırpılır)

`POST /player/continue` `{ client_event_id, amount }` → PlayerProgress
`amount` = devam bedelinin kayıtlı bakiyeden ödenen kısmı (1..50). Yetmezse 409 `insufficient_coins`.

`DELETE /player` → `{ deleted: true }`

## Klip

`POST /clips` — gövde ham MP4 (`Content-Type: video/mp4`, ≤ 15 MB) → `{ url }` (Bunny CDN, 201)

## Uygulama tarafı

- `PlayerRepository` önce `SharedPreferences`'a yazar, olayları kuyruğa (`pending_events`) koyar ve
  sırayla gönderir. Ağ hatasında kuyruk bekler; sunucu 4xx ile reddederse olay atılır.
- Kuyruk boşken sunucu durumu benimsenir (coin sunucudan; rekor ve oyun sayısında büyük olan).
- `--dart-define=OFFLINE=true` ile hiç istek atılmaz.
