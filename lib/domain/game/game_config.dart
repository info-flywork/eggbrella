import 'dart:math' as math;

/// Oyun dünyasının sabitleri. Dünya Figma karesi genişliğinde (430) tasarım
/// birimiyle hesaplanır; ekrana `ekranGenişliği / 430` ölçeğiyle çizilir.
abstract final class GameConfig {
  /// Dünya genişliği (Figma karesi).
  static const double worldWidth = 430;

  /// Bir katın yüksekliği (tasarım birimi). Cephe görselinde ~4 kat / ekran.
  static const double floorHeight = 200;

  /// Yumurtanın ekrandaki sabit yüksekliği (gövde merkezi). Figma: Yumi
  /// 140..322 arası; gövde ~270.
  static const double eggScreenY = 270;

  /// Başlangıç görselinin (çatı kenarı) çizilen üst kısmı: altında
  /// dikişsiz cephe şeridi başlar (scripts/prepare_assets.py: 488 px / 2).
  static const double introImageHeight = 244;

  /// Cephe şeridinin yüksekliği (217 px / 2).
  static const double facadeTileHeight = 108.5;

  /// İlk engel sırası: başlangıç ekranı engelsiz görünsün.
  static const double firstRowY = 1190;

  // --- Hareket ---
  /// Şemsiye açıkken hedef düşüş hızı (birim/sn), zorlukla artar.
  static const double slowSpeedBase = 170;
  static const double slowSpeedMax = 250;

  /// Şemsiye kapalıyken hedef düşüş hızı.
  static const double fastSpeedBase = 640;
  static const double fastSpeedMax = 900;

  /// Hızlanma / yavaşlama ivmeleri.
  static const double accelerate = 1300;
  static const double brake = 2100;

  /// Yumurta hep ortadan düşer; şemsiye yalnızca hızı değiştirir.
  static const double eggX = worldWidth / 2;

  // --- Engel sıraları (solda + sağda parça, arada sallanan açıklık) ---
  /// Sıralar arası mesafe (zorlukla daralır).
  static const double rowSpacingMax = 400;
  static const double rowSpacingMin = 290;

  /// Açıklık genişliği (zorlukla daralır). Yumurta gövdesi ~72 birim.
  static const double gapMax = 210;
  static const double gapMin = 150;

  /// Sallanma periyodu (sn, zorlukla kısalır).
  static const double swingPeriodMax = 3.4;
  static const double swingPeriodMin = 1.9;

  /// Açıklık en uçtayken bile görünen en dar parça.
  static const double minPartWidth = 30;

  /// Tentede bu hızın üstünde düşmek kırar; altındaysa sekilir.
  static const double awningBreakSpeed = 420;
  static const double awningBounceSpeed = -260;

  // --- Çarpışma ---
  /// Gövde yarıçapı (görselden biraz küçük: affedici çarpışma).
  static const double eggRadius = 36;

  static const double coinRadius = 20;
  static const double coinPickupRadius = 48;

  // --- Akış ---
  /// Devam sonrası çarpışmasız süre (Figma: "Koruma: 2 sn").
  static const double shieldSeconds = 2;

  /// Klip uzunluğu (Figma: "Video · 8 sn") ve kare hızı.
  static const double clipSeconds = 8;
  static const int clipFps = 20;

  /// İlk kaç oyunda kontrol ipucu gösterilir.
  static const int hintGames = 3;

  /// 0..1 zorluk; ~180. katta tavana ulaşır.
  static double difficulty(int floor) => math.min(1, floor / 180);

  static double lerp(double a, double b, double t) => a + (b - a) * t;
}
