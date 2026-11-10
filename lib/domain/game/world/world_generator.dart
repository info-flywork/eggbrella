import 'dart:math' as math;
import 'dart:ui';

import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/world/world_objects.dart';

/// Kamera aşağı indikçe engel sıraları ve altınlar üretir. Aynı [seed] aynı
/// binayı üretir (testler için).
class WorldGenerator {
  WorldGenerator({int? seed}) : _random = math.Random(seed);

  final math.Random _random;
  int _nextId = 0;
  double _nextRowY = GameConfig.firstRowY;
  ObstacleKind? _lastKind;

  /// [untilY] dünya koordinatına kadar yeni sıralar üretir.
  void fill({
    required double untilY,
    required List<Obstacle> obstacles,
    required List<Coin> coins,
  }) {
    while (_nextRowY < untilY) {
      final floor = (_nextRowY / GameConfig.floorHeight).floor();
      final d = GameConfig.difficulty(floor);
      final obstacle = _obstacle(_nextRowY, floor, d);
      obstacles.add(obstacle);
      final spacing =
          GameConfig.lerp(
            GameConfig.rowSpacingMax,
            GameConfig.rowSpacingMin,
            d,
          ) +
          _random.nextDouble() * 60;
      _coinRun(
        top: obstacle.rect.bottom + 70,
        bottom: _nextRowY + spacing - 60,
        coins: coins,
      );
      _nextRowY += spacing;
    }
  }

  /// Devam sonrası: yumurtanın hemen altı boş kalsın.
  void skipAhead(double y) => _nextRowY = math.max(_nextRowY, y);

  Obstacle _obstacle(double y, int floor, double d) {
    final kind = _pickKind(floor);
    _lastKind = kind;
    if (kind == ObstacleKind.pigeon) return _pigeon(y, d);

    final gap =
        GameConfig.lerp(GameConfig.gapMax, GameConfig.gapMin, d) +
        _random.nextDouble() * 20;
    // Açıklık en uçtayken bile iki parça da görünsün.
    final amplitude = math.max(
      0.0,
      GameConfig.worldWidth / 2 - gap / 2 - GameConfig.minPartWidth,
    );
    final period =
        GameConfig.lerp(
          GameConfig.swingPeriodMax,
          GameConfig.swingPeriodMin,
          d,
        ) *
        (0.85 + _random.nextDouble() * 0.3);
    final height = switch (kind) {
      ObstacleKind.balcony => 104.0,
      ObstacleKind.clothesline => 118.0,
      ObstacleKind.awning || ObstacleKind.pigeon => 64.0,
    };
    return Obstacle(
      id: _nextId++,
      kind: kind,
      rect: Rect.fromLTWH(0, y, GameConfig.worldWidth, height),
      gapWidth: gap,
      swingAmplitude: amplitude,
      swingSpeed: 2 * math.pi / period,
      swingPhase: _random.nextDouble() * 2 * math.pi,
    );
  }

  Obstacle _pigeon(double y, double d) {
    const width = 112.0;
    const height = 84.0;
    final fromLeft = _random.nextBool();
    final speed = GameConfig.lerp(120, 210, d);
    return Obstacle(
      id: _nextId++,
      kind: ObstacleKind.pigeon,
      rect: Rect.fromLTWH(
        fromLeft ? -width : GameConfig.worldWidth,
        y,
        width,
        height,
      ),
      velocityX: fromLeft ? speed : -speed,
    );
  }

  ObstacleKind _pickKind(int floor) {
    final weights = <ObstacleKind, double>{
      ObstacleKind.balcony: 4,
      ObstacleKind.clothesline: 3,
      if (floor >= 4) ObstacleKind.awning: 2,
      if (floor >= 8) ObstacleKind.pigeon: 1.5,
    };
    // Aynı türün üst üste gelmesini azalt.
    if (_lastKind != null && weights.containsKey(_lastKind)) {
      weights[_lastKind!] = weights[_lastKind]! * 0.4;
    }
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }
    return ObstacleKind.balcony;
  }

  /// Sıralar arasında, yumurtanın yolunda zikzak altınlar (Figma: 36 birim
  /// yatay, 68 birim dikey aralık).
  void _coinRun({
    required double top,
    required double bottom,
    required List<Coin> coins,
  }) {
    if (bottom - top < 80 || _random.nextDouble() < 0.3) return;
    final count = math.min(4, ((bottom - top) / 68).floor());
    if (count < 2) return;
    for (var i = 0; i < count; i++) {
      coins.add(
        Coin(
          id: _nextId++,
          center: Offset(GameConfig.eggX + (i.isEven ? -18 : 18), top + i * 68),
        ),
      );
    }
  }
}
