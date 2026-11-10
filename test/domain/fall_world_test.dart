import 'dart:ui';

import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/replay/game_replay.dart';
import 'package:eggbrella/domain/game/world/fall_world.dart';
import 'package:eggbrella/domain/game/world/world_objects.dart';
import 'package:eggbrella/domain/game/world/world_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

/// [seconds] boyunca 60 fps ilerletir; olayları toplar.
List<WorldEvent> run(
  FallWorld world,
  double seconds, {
  required bool open,
}) {
  final events = <WorldEvent>[];
  for (var t = 0.0; t < seconds && world.isAlive; t += 1 / 60) {
    events.addAll(world.update(1 / 60, umbrellaOpen: open));
  }
  return events;
}

void main() {
  group('FallWorld', () {
    test('kapalı şemsiye açıktan çok daha hızlı düşer', () {
      final slow = FallWorld(seed: 1);
      final fast = FallWorld(seed: 1);
      // Çatıdan zıplayış yukarı hızla başlar; hızlar yerleşsin.
      for (var i = 0; i < 90; i++) {
        slow.update(1 / 60, umbrellaOpen: true);
        fast.update(1 / 60, umbrellaOpen: false);
      }
      expect(fast.speed, greaterThan(slow.speed * 2));
      expect(slow.speed, lessThanOrEqualTo(GameConfig.slowSpeedMax));
    });

    test('ifade değişimleri ani değil, akıcı geçer', () {
      final world = FallWorld(seed: 1)..update(1 / 60, umbrellaOpen: false);
      final blend = world.snapshot().openBlend;
      expect(blend, inExclusiveRange(0, 1));
      run(world, 0.3, open: false);
      expect(world.snapshot().openBlend, 0);
    });

    test('coin alınca yumurta mutlulaşır ve esner', () {
      final world = FallWorld(seed: 1);
      // İlk altına kadar düş, sonra kısa süre bekle.
      for (var i = 0; i < 600 && world.coinsCollected == 0; i++) {
        world.update(1 / 60, umbrellaOpen: true);
      }
      expect(world.coinsCollected, greaterThan(0));
      run(world, 0.15, open: true);
      final s = world.snapshot();
      expect(s.happyBlend, greaterThan(0));
      expect(s.bounce.abs(), lessThanOrEqualTo(0.16));
    });

    test('çatıda başlar, önce zıplar; kamera hiç geri gitmez', () {
      final world = FallWorld(seed: 5);
      final start = world.snapshot();
      expect(start.eggY, closeTo(GameConfig.roofEggY, 0.01));
      expect(start.cameraY, GameConfig.roofTop);
      world.update(1 / 60, umbrellaOpen: true);
      expect(world.snapshot().eggY, lessThan(start.eggY));
      var camera = world.cameraY;
      for (var i = 0; i < 180; i++) {
        world.update(1 / 60, umbrellaOpen: false);
        expect(world.cameraY, greaterThanOrEqualTo(camera));
        camera = world.cameraY;
      }
      // Geçiş bitince Yumi oyun konumunda (ekranda eggScreenY).
      final s = world.snapshot();
      expect(s.eggY - s.cameraY, closeTo(GameConfig.eggScreenY, 1));
    });

    test('kat sayacı düştükçe artar', () {
      final world = FallWorld(seed: 2);
      final events = run(world, 1.5, open: false);
      expect(world.floor, greaterThan(0));
      expect(events.whereType<FloorReached>(), isNotEmpty);
    });

    test('başlangıç altınları düz düşüşte toplanır', () {
      final world = FallWorld(seed: 3);
      expect(world.snapshot().coins.length, greaterThanOrEqualTo(4));
      final events = run(world, 1.6, open: false);
      expect(events.whereType<CoinCollected>(), isNotEmpty);
      expect(world.coinsCollected, greaterThan(0));
    });

    test('her tohumda engellere çarpılabilir ve kırılınca dünya durur', () {
      final world = FallWorld(seed: 4);
      final events = run(world, 60, open: false);
      expect(events.whereType<EggCrashed>(), hasLength(1));
      expect(world.isAlive, isFalse);
      // Kırıldığı yerde kalır; kırılma animasyonu saati ilerler.
      final crashedAt = world.snapshot();
      expect(crashedAt.crashed, isTrue);
      world.advanceDead(0.5);
      expect(
        world.snapshot().crashAge,
        closeTo(crashedAt.crashAge + 0.5, 1e-9),
      );
      expect(world.snapshot().eggY, crashedAt.eggY);
      expect(world.update(1, umbrellaOpen: false), isEmpty);
    });

    test('devam: koruma verilir ve yakındaki engeller temizlenir', () {
      final world = FallWorld(seed: 5);
      run(world, 60, open: false);
      final floor = world.floor;
      world.revive();
      expect(world.isAlive, isTrue);
      expect(world.snapshot().crashed, isFalse);
      expect(world.shieldLeft, GameConfig.shieldSeconds);
      expect(world.floor, floor);
      final nearby = world.snapshot().obstacles.where(
        (o) =>
            o.rect.top < world.cameraY + 500 && o.rect.bottom > world.cameraY,
      );
      expect(nearby, isEmpty);
    });

    test('yumurta hep ortadan düşer (şemsiye yalnızca hızı değiştirir)', () {
      final world = FallWorld(seed: 7);
      for (var i = 0; i < 240; i++) {
        world.update(1 / 60, umbrellaOpen: i.isEven);
        expect(world.snapshot().eggX, GameConfig.eggX);
      }
    });

    test('engel sıraları sallanır (dünya saati ilerler)', () {
      final world = FallWorld(seed: 8);
      final row = world.snapshot().obstacles.firstWhere((o) => o.isRow);
      final before = row.gapCenterAt(world.snapshot().time);
      run(world, 0.5, open: true);
      expect(row.gapCenterAt(world.snapshot().time), isNot(before));
    });

    test('kalkan süresince çarpışma olmaz', () {
      final world = FallWorld(seed: 6)..grantShield();
      final events = run(world, GameConfig.shieldSeconds * 0.9, open: false);
      expect(events.whereType<EggCrashed>(), isEmpty);
    });
  });

  group('Obstacle (sıra)', () {
    const row = Obstacle(
      id: 0,
      kind: ObstacleKind.balcony,
      rect: Rect.fromLTWH(0, 100, GameConfig.worldWidth, 100),
      gapWidth: 200,
      swingAmplitude: 85,
      swingSpeed: 2,
    );

    test('aynı anda solda ve sağda parça vardır, arada açıklık kalır', () {
      final (left, right) = row.partsAt(0);
      expect(left.left, 0);
      expect(right.right, GameConfig.worldWidth);
      expect(right.left - left.right, 200);
      expect(row.hitBoxesAt(0), hasLength(2));
    });

    test('açıklık periyodik olarak sağa sola sallanır', () {
      final centers = [
        for (var t = 0.0; t < 3.2; t += 0.1) row.gapCenterAt(t),
      ];
      expect(centers.reduce((a, b) => a < b ? a : b), closeTo(130, 1));
      expect(centers.reduce((a, b) => a > b ? a : b), closeTo(300, 1));
      // Periyot: 2π / swingSpeed.
      expect(row.gapCenterAt(3.14159), closeTo(row.gapCenterAt(0), 0.01));
    });

    test('kutular çizim alanının içindedir', () {
      final (left, _) = row.partsAt(1);
      final box = row.hitBoxesAt(1).first;
      expect(box.left, left.left);
      expect(box.top, greaterThanOrEqualTo(left.top));
      expect(box.bottom, lessThanOrEqualTo(left.bottom));
    });
  });

  group('GameReplay', () {
    WorldSnapshot snap(int floor) => WorldSnapshot(
      cameraY: 0,
      eggX: 0,
      eggY: 0,
      time: 0,
      umbrellaOpen: true,
      scared: false,
      happy: false,
      shieldLeft: 0,
      speed: 0,
      floor: floor,
      obstacles: const [],
      coins: const [],
    );

    test('yalnızca son N saniyeyi tutar', () {
      final replay = GameReplay(fps: 10, seconds: 2);
      for (var i = 0; i < 100; i++) {
        replay.record(0.1, () => snap(i));
      }
      expect(replay.frames, hasLength(20));
      expect(replay.frames.last.floor, 99);
      expect(replay.durationSeconds, 2);
    });

    test('kare hızına göre seyreltir', () {
      final replay = GameReplay(fps: 10, seconds: 10);
      for (var i = 0; i < 60; i++) {
        replay.record(1 / 60, () => snap(i));
      }
      expect(replay.frames.length, inInclusiveRange(9, 11));
    });
  });
}
