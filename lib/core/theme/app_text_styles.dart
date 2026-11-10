import 'package:eggbrella/generated/fonts.gen.dart';
import 'package:flutter/material.dart';

/// Tipografi token'ları (Figma: Baloo 2). Renk verilmez; widget tarafında
/// `.copyWith(color: ColorName.x)`.
abstract final class AppTextStyles {
  /// HUD/Floor: "78. kat".
  static const TextStyle hudFloor = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  /// HUD/Coins sayısı.
  static const TextStyle hudCoins = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 26 / 22,
  );

  /// Ana sayfa "OYNA".
  static const TextStyle playButton = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
  );

  /// Oyun sonu "TEKRAR OYNA".
  static const TextStyle largeButton = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 32 / 28,
  );

  /// Button/Primary ve Button/Secondary.
  static const TextStyle button = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  /// Button/Text.
  static const TextStyle textButton = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  /// Label/Banner (kart başlığı).
  static const TextStyle banner = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  /// Kart başlığı: "Yumi biraz kestiriyor…".
  static const TextStyle cardHeadline = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 26 / 20,
  );

  /// Klip kartı başlığı.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 28 / 22,
  );

  /// Kart açıklaması.
  static const TextStyle cardBody = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
  );

  /// "Rekor: 147. kat", ipucu satırları, koruma rozeti.
  static const TextStyle pill = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24 / 18,
  );

  /// "Başlamak için dokun".
  static const TextStyle tapToStart = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 25 / 22,
  );

  /// Ayar satırı etiketi.
  static const TextStyle rowLabel = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  /// Ayar satırı değeri ("Türkçe").
  static const TextStyle rowValue = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  /// Segmented kontrol.
  static const TextStyle segment = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 21 / 16,
  );

  /// Geri sayım halkası içi "5".
  static const TextStyle countdownRing = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 60,
    fontWeight: FontWeight.w800,
    height: 64 / 60,
  );

  /// Devam öncesi büyük sayaç "2".
  static const TextStyle countdownBig = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 170,
    fontWeight: FontWeight.w800,
    height: 1,
  );

  /// Oyun sonu "Skorun".
  static const TextStyle scoreLabel = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 28 / 24,
  );

  /// Oyun sonu "152. kat".
  static const TextStyle score = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 64,
    fontWeight: FontWeight.w800,
    height: 70 / 64,
  );

  /// Kurdele üzerindeki "Yeni rekor!".
  static const TextStyle ribbon = TextStyle(
    fontFamily: FontFamily.baloo2,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 36 / 32,
  );

  /// Marka açılışı "flywork" (Cal Sans).
  static const TextStyle brand = TextStyle(
    fontFamily: FontFamily.calSans,
    fontSize: 64,
    height: 52 / 64,
    letterSpacing: -3.2,
  );
}
