import 'package:eggbrella/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Boşluk token'ları (Figma auto-layout gap/padding değerleri).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  /// Figma kareleri 430x932; üst güvenli alan sonrası içerik 54'ten başlar.
  static const double screenTop = 54;
  static const double screenBottom = 34;
}

/// Köşe yarıçapı token'ları.
abstract final class AppRadius {
  static const double banner = 18;
  static const double hintCard = 16;
  static const double card = 24;
  static const double pill = 999;
}

/// Figma gölgeleri.
abstract final class AppShadows {
  /// Button/Primary: yumuşak gölge + 4px koyu yeşil "taban".
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: ColorName.colorShadowNavy18,
      offset: Offset(0, 8),
      blurRadius: 14,
    ),
    BoxShadow(color: ColorName.colorGreenDark, offset: Offset(0, 4)),
  ];

  /// Button/Secondary: 3px krem "taban".
  static const List<BoxShadow> secondaryButton = [
    BoxShadow(
      color: ColorName.colorShadowNavy12,
      offset: Offset(0, 6),
      blurRadius: 12,
    ),
    BoxShadow(color: ColorName.colorCreamLine, offset: Offset(0, 3)),
  ];

  /// Card/Modal drop shadow.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: ColorName.colorShadowNavy30,
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
  ];

  /// Krem hap (Rekor, Koruma, ipucu kartı).
  static const List<BoxShadow> pill = [
    BoxShadow(
      color: ColorName.colorShadowNavy30,
      offset: Offset(0, 10),
      blurRadius: 30,
    ),
  ];

  /// Beyaz yuvarlak ikon butonu.
  static const List<BoxShadow> iconButton = [
    BoxShadow(
      color: ColorName.colorShadowNavy25,
      offset: Offset(0, 3),
      blurRadius: 3,
    ),
  ];

  /// Label/Banner: 4px koyu sarı taban.
  static const List<BoxShadow> banner = [
    BoxShadow(color: ColorName.colorYellowDark, offset: Offset(0, 4)),
  ];

  /// HUD/Floor metin gölgesi.
  static const List<Shadow> floorText = [
    Shadow(color: ColorName.colorFloorTextShadow, offset: Offset(0, 3)),
  ];

  /// Sayaç "2" parıltısı.
  static const List<Shadow> countdownGlow = [
    Shadow(color: ColorName.colorCountdownGlow, blurRadius: 28),
  ];
}
