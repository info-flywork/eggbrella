import 'dart:math' as math;
import 'dart:ui';

import 'package:eggbrella/domain/game/game_config.dart';
import 'package:equatable/equatable.dart';

/// Engel türleri (Figma: balkon, çamaşır ipi, tente, güvercin).
enum ObstacleKind { balcony, clothesline, awning, pigeon }

/// Dünyadaki bir engel. Konumlar dünya birimindedir (y aşağı doğru artar).
///
/// Balkon, ip ve tente **sıra** engelidir: aynı yükseklikte hem solda hem
/// sağda bir parça vardır, aradaki açıklık sağa sola periyodik sallanır.
/// Yumurta hep ortadan düştüğü için açıklık ortaya geldiğinde geçilir.
/// Güvercin ise yatay uçar.
final class Obstacle extends Equatable {
  const Obstacle({
    required this.id,
    required this.kind,
    required this.rect,
    this.velocityX = 0,
    this.gapWidth = 0,
    this.swingAmplitude = 0,
    this.swingSpeed = 0,
    this.swingPhase = 0,
  });

  final int id;
  final ObstacleKind kind;

  /// Sıra engelinde tam genişlik bant; güvercinde kuşun kutusu.
  final Rect rect;

  /// Güvercin yatay hızı (birim/sn).
  final double velocityX;

  /// Sıra engelinde iki parça arasındaki açıklık.
  final double gapWidth;

  /// Açıklık merkezinin ortadan en fazla sapması.
  final double swingAmplitude;

  /// Sallanma açısal hızı (radyan/sn).
  final double swingSpeed;
  final double swingPhase;

  bool get isRow => kind != ObstacleKind.pigeon;

  /// [time] anında açıklığın merkezi.
  double gapCenterAt(double time) =>
      GameConfig.worldWidth / 2 +
      swingAmplitude * math.sin(swingSpeed * time + swingPhase);

  /// [time] anında sol ve sağ parça.
  (Rect left, Rect right) partsAt(double time) {
    final center = gapCenterAt(time);
    return (
      Rect.fromLTRB(0, rect.top, center - gapWidth / 2, rect.bottom),
      Rect.fromLTRB(
        center + gapWidth / 2,
        rect.top,
        GameConfig.worldWidth,
        rect.bottom,
      ),
    );
  }

  /// Çarpışma kutuları: görselin boş üst / alt kenarları hariç.
  List<Rect> hitBoxesAt(double time) {
    if (!isRow) return [rect.deflate(rect.shortestSide * 0.18)];
    final (left, right) = partsAt(time);
    return [_trim(left), _trim(right)];
  }

  Rect _trim(Rect part) => switch (kind) {
    // Korkuluk + zemin: görselin alt %70'i.
    ObstacleKind.balcony => Rect.fromLTRB(
      part.left,
      part.top + part.height * 0.25,
      part.right,
      part.bottom - part.height * 0.08,
    ),
    // İp ve asılı çamaşırlar.
    ObstacleKind.clothesline => Rect.fromLTRB(
      part.left,
      part.top + part.height * 0.12,
      part.right,
      part.bottom - part.height * 0.12,
    ),
    // Tentenin üst yüzeyi.
    ObstacleKind.awning => Rect.fromLTRB(
      part.left,
      part.top,
      part.right,
      part.top + part.height * 0.55,
    ),
    ObstacleKind.pigeon => part,
  };

  Obstacle movedBy(double dx) => Obstacle(
    id: id,
    kind: kind,
    rect: rect.translate(dx, 0),
    velocityX: velocityX,
    gapWidth: gapWidth,
    swingAmplitude: swingAmplitude,
    swingSpeed: swingSpeed,
    swingPhase: swingPhase,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    rect,
    velocityX,
    gapWidth,
    swingAmplitude,
    swingSpeed,
    swingPhase,
  ];
}

/// Toplanabilir altın.
final class Coin extends Equatable {
  const Coin({required this.id, required this.center});

  final int id;
  final Offset center;

  @override
  List<Object?> get props => [id, center];
}
