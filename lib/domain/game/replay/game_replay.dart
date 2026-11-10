import 'dart:collection';

import 'package:eggbrella/domain/game/game_config.dart';
import 'package:eggbrella/domain/game/world/world_snapshot.dart';
import 'package:eggbrella/domain/skins/skin.dart';

/// Oyunun son [GameConfig.clipSeconds] saniyesinin kareleri (halka tampon).
/// Klip, ekran görüntüsü yerine bu karelerin yeniden çizimiyle üretilir:
/// bellek küçük kalır, video çözünürlüğü ekrandan bağımsızdır.
class GameReplay {
  GameReplay({
    this.fps = GameConfig.clipFps,
    double seconds = GameConfig.clipSeconds,
    this.skins = SkinSelection.classic,
  }) : capacity = (fps * seconds).round();

  final int fps;

  /// Oyunun skinleri (klip aynı görünümle çizilir).
  final SkinSelection skins;
  final int capacity;
  final Queue<WorldSnapshot> _frames = Queue();
  double _sinceLast = double.infinity;

  /// Her oyun karesinde çağrılır; [fps]'e göre seyreltir.
  void record(double dt, WorldSnapshot Function() snapshot) {
    _sinceLast += dt;
    if (_sinceLast < 1 / fps) return;
    _sinceLast = 0;
    _frames.addLast(snapshot());
    while (_frames.length > capacity) {
      _frames.removeFirst();
    }
  }

  /// Kırılma anı: [snapshotAt] ile kırılmadan bu yana geçen süreye göre
  /// [seconds] boyunca kare ekler (kırılma animasyonu klipte de görünür).
  void hold(
    WorldSnapshot Function(double age) snapshotAt, {
    double seconds = 1,
  }) {
    final count = (fps * seconds).round();
    for (var i = 0; i < count; i++) {
      _frames.addLast(snapshotAt(i / fps));
      if (_frames.length > capacity) _frames.removeFirst();
    }
  }

  List<WorldSnapshot> get frames => List.unmodifiable(_frames);

  bool get isEmpty => _frames.isEmpty;

  double get durationSeconds => _frames.length / fps;
}
