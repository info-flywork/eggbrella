abstract final class StringConstants {
  /// Varsayılan: canlı API. Yerel backend için
  /// `--dart-define-from-file=config/local_device.json`.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://eggbrella.fly-work.com',
  );

  /// true iken hiçbir istek atılmaz; ilerleme yalnızca cihazda tutulur
  /// (`--dart-define=OFFLINE=true`). Ağ yoksa uygulama zaten çevrimdışı
  /// çalışmaya devam eder.
  static const bool offline = bool.fromEnvironment('OFFLINE');

  /// RevenueCat public SDK anahtarları (gizli değildir; uygulamaya gömülmesi
  /// RevenueCat'in öngördüğü kullanımdır). Boş verilirse
  /// (`--dart-define=REVENUECAT_APPLE_KEY=`) satın alma sahte modda çalışır.
  static const String revenueCatAppleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'appl_UYXUJRVjEoWcbrIPJTbppAHKVJf',
  );
  static const String revenueCatGoogleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: 'goog_MlneaKSUvoPdUiUHGehEFzuhioC',
  );

  /// Yasal sayfalar (fly-work.com/eggbrella/...).
  static const String legalBaseUrl = 'https://fly-work.com/eggbrella';
  static const String privacyPolicyUrl = '$legalBaseUrl/privacy-policy/';
}
