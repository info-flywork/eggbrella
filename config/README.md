# dart-define dosyaları

| Dosya | Kullanım |
|---|---|
| (yok) | Canlı API: `https://eggbrella.fly-work.com` |
| `offline.json` | Hiç istek atılmaz; ilerleme yalnızca cihazda |
| `local_device.json` | Yerel backend (IP'yi kendi makinenizle değiştirin) |

```bash
flutter run --dart-define-from-file=config/offline.json
```
