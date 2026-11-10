import 'dart:math' as math;
import 'dart:ui';

import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/world/world_generator.dart';
import 'package:eggbrella/domain/game/world/world_objects.dart';
import 'package:eggbrella/domain/game/world/world_snapshot.dart';

/// Bir karede olan, ekranın / bloc'un tepki vereceği şeyler.
sealed class WorldEvent {
  const WorldEvent();
}

final class CoinCollected extends WorldEvent {
  const CoinCollected();
}

final class AwningBounced extends WorldEvent {
  const AwningBounced();
}

final class FloorReached extends WorldEvent {
  const FloorReached(this.floor);

  final int floor;
}

final class EggCrashed extends WorldEvent {
  const EggCrashed(this.kind);

  final ObstacleKind kind;
}

/// Düşüş simülasyonu. Saf Dart: zamanlayıcı ya da widget bilmez; ekran her
/// karede [update] çağırır.
class FallWorld {
  FallWorld({int? seed}) : _generator = WorldGenerator(seed: seed) {
    // Figma oyun-baslangic: Yumi'nin altında zikzak ilk altınlar.
    for (var i = 0; i < 4; i++) {
      _coins.add(
        Coin(id: -1 - i, center: Offset(i.isEven ? 197 : 233, 324 + i * 68.0)),
      );
    }
    _fill();
  }

  final WorldGenerator _generator;
  final List<Obstacle> _obstacles = [];
  final List<Coin> _coins = [];

  /// Ekranın tasarım birimi cinsinden yüksekliği (görünür dünya).
  double viewHeight = 932;

  double _eggY = GameConfig.eggScreenY;
  double _vy = 0;

  /// Dünya saati: engel sıralarının sallanması buna bağlıdır (yalnızca oyun
  /// akarken ilerler).
  double _time = 0;

  /// Kırıldıktan sonra geçen süre (kırılma animasyonu); canlıyken 0.
  double _deadFor = 0;
  bool _open = true;
  bool _alive = true;
  double _shield = 0;
  double _happy = 0;

  /// İfade geçişleri (0..1): sprite'lar arasında ani değişim yerine akıcı
  /// çapraz geçiş. [_openBlend] 1 = şemsiye açık, [_happyBlend] 1 = mutlu.
  double _openBlend = 1;
  double _happyBlend = 0;

  /// Coin alınca yumurtanın esneyip toparlanması (sönümlü yay). Art arda
  /// coinlerde vuruşlar üst üste biner, titreme yerine akıcı kalır.
  double _bounce = 0;
  double _bounceV = 0;
  int _coinsCollected = 0;
  int _floor = 0;

  int get floor => _floor;
  int get coinsCollected => _coinsCollected;
  bool get isAlive => _alive;
  bool get isUmbrellaOpen => _open;
  double get shieldLeft => _shield;
  double get cameraY => _eggY - GameConfig.eggScreenY;
  double get speed => _vy;

  /// [dt] saniye ilerletir. [umbrellaOpen] oyuncunun girdisidir.
  List<WorldEvent> update(double dt, {required bool umbrellaOpen}) {
    if (!_alive) return const [];
    final events = <WorldEvent>[];
    final step = math.min(dt, 1 / 30);
    _open = umbrellaOpen;
    final d = GameConfig.difficulty(_floor);

    // Dikey hız: hedefe yumuşak yaklaşım.
    final target = _open
        ? GameConfig.lerp(GameConfig.slowSpeedBase, GameConfig.slowSpeedMax, d)
        : GameConfig.lerp(GameConfig.fastSpeedBase, GameConfig.fastSpeedMax, d);
    if (_vy < target) {
      _vy = math.min(target, _vy + GameConfig.accelerate * step);
    } else {
      _vy = math.max(target, _vy - GameConfig.brake * step);
    }
    final previousBottom = _eggY + GameConfig.eggRadius;
    _eggY += _vy * step;

    _time += step;
    _shield = math.max(0, _shield - step);
    _happy = math.max(0, _happy - step);
    _animateExpression(step);

    _moveObstacles(step);
    _collectCoins(events);
    _collide(events, previousBottom);

    final floor = math.max(
      0,
      ((_eggY - GameConfig.eggScreenY) / GameConfig.floorHeight).floor(),
    );
    if (floor != _floor) {
      _floor = floor;
      events.add(FloorReached(floor));
    }
    _fill();
    return events;
  }

  /// Kırıldıktan sonra yalnızca kırılma animasyonunun saati ilerler.
  void advanceDead(double dt) {
    if (!_alive) _deadFor += dt;
  }

  /// Devam: aynı kattan, koruma kalkanıyla ve yakın engeller temizlenerek.
  void revive() {
    _alive = true;
    _deadFor = 0;
    _vy = 0;
    _open = true;
    _shield = GameConfig.shieldSeconds;
    final clearUntil = _eggY + viewHeight * 0.6;
    _obstacles.removeWhere(
      (o) => o.rect.bottom > cameraY && o.rect.top < clearUntil,
    );
    _generator.skipAhead(clearUntil);
  }

  /// Duraklatma dönüşü sayacı: çarpışmasız kısa süre (engeller kalır).
  void grantShield() => _shield = GameConfig.shieldSeconds;

  /// [crashAge] verilirse kırılma animasyonu o anki gibi çizilir (klip).
  WorldSnapshot snapshot({double? crashAge}) => WorldSnapshot(
    cameraY: cameraY,
    eggX: GameConfig.eggX,
    time: _time,
    eggY: _eggY,
    umbrellaOpen: _open,
    scared: !_open && _vy > GameConfig.awningBreakSpeed,
    happy: _happy > 0,
    openBlend: _openBlend,
    happyBlend: _happyBlend,
    bounce: _bounce,
    shieldLeft: _shield,
    crashAge: _alive ? -1 : (crashAge ?? _deadFor),
    speed: _vy,
    floor: _floor,
    obstacles: List.unmodifiable(_obstacles),
    coins: List.unmodifiable(_coins),
  );

  /// İfadeleri hedefe sabit hızla yaklaştırır, yayı ilerletir.
  void _animateExpression(double step) {
    double approach(double v, double target, double perSecond) {
      final delta = perSecond * step;
      return v < target
          ? math.min(target, v + delta)
          : math.max(target, v - delta);
    }

    _openBlend = approach(_openBlend, _open ? 1 : 0, 1 / 0.14);
    _happyBlend = _happy > 0
        ? approach(_happyBlend, 1, 1 / 0.16)
        : approach(_happyBlend, 0, 1 / 0.35);
    // Yarı kapalı Euler: k=260, sönüm 16 (≈0.5 sn'de durulur).
    _bounceV += (-260 * _bounce - 16 * _bounceV) * step;
    _bounce = (_bounce + _bounceV * step).clamp(-0.16, 0.16);
  }

  void _moveObstacles(double step) {
    final activeBelow = cameraY + viewHeight + 120;
    for (var i = 0; i < _obstacles.length; i++) {
      final o = _obstacles[i];
      if (o.velocityX != 0 && o.rect.top < activeBelow) {
        _obstacles[i] = o.movedBy(o.velocityX * step);
      }
    }
    final top = cameraY - 200;
    _obstacles.removeWhere((o) => o.rect.bottom < top);
    _coins.removeWhere((c) => c.center.dy < top);
  }

  void _collectCoins(List<WorldEvent> events) {
    final egg = Offset(GameConfig.eggX, _eggY);
    _coins.removeWhere((c) {
      final hit = (c.center - egg).distance < GameConfig.coinPickupRadius;
      if (hit) {
        _coinsCollected++;
        _happy = 0.9;
        _bounceV = math.min(_bounceV + 1.8, 2.6);
        events.add(const CoinCollected());
      }
      return hit;
    });
  }

  /// Yalnızca yumurta gövdesi çarpar (şemsiye sadece hızı değiştirir).
  void _collide(List<WorldEvent> events, double previousBottom) {
    if (_shield > 0) return;
    final egg = Offset(GameConfig.eggX, _eggY);
    for (final o in _obstacles) {
      for (final box in o.hitBoxesAt(_time)) {
        if (box.width <= 0) continue;
        if (!_circleHitsRect(egg, GameConfig.eggRadius, box)) continue;
        // Tenteye yavaş düşen sekip açıklığı bekler; hızlı düşen kırılır.
        if (o.kind == ObstacleKind.awning &&
            previousBottom <= box.top + 14 &&
            _vy <= GameConfig.awningBreakSpeed) {
          _vy = GameConfig.awningBounceSpeed;
          _eggY = math.min(_eggY, box.top - GameConfig.eggRadius - 2);
          events.add(const AwningBounced());
          return;
        }
        _alive = false;
        events.add(EggCrashed(o.kind));
        return;
      }
    }
  }

  void _fill() => _generator.fill(
    untilY: cameraY + viewHeight * 2,
    obstacles: _obstacles,
    coins: _coins,
  );

  static bool _circleHitsRect(Offset c, double r, Rect rect) {
    final dx = c.dx - c.dx.clamp(rect.left, rect.right);
    final dy = c.dy - c.dy.clamp(rect.top, rect.bottom);
    return dx * dx + dy * dy < r * r;
  }
}
