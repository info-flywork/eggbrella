import 'dart:async';

import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/render/scene_renderer.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:eggbrella/domain/game/replay/game_replay.dart';
import 'package:eggbrella/domain/game/world/fall_world.dart';
import 'package:eggbrella/domain/game/world/world_snapshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Kare döngüsü: [FallWorld]'ü ilerletir, girdiyi şemsiyeye çevirir, olayları
/// bloc'a iletir ve klip için kareleri kaydeder. Ekranı yeniden çizmek için
/// her karede dinleyicilerini uyarır.
class GameWorldController extends ChangeNotifier {
  GameWorldController({
    required TickerProvider vsync,
    required GameSprites sprites,
    required this.replay,
    required this.sound,
    required this.onCoin,
    required this.onCrash,
    required this.coinBalance,
  }) : renderer = SceneRenderer(sprites) {
    _ticker = vsync.createTicker(_tick);
    unawaited(_ticker.start());
  }

  final SceneRenderer renderer;
  final GameReplay replay;
  final SoundManager sound;
  final VoidCallback onCoin;
  final ValueChanged<int> onCrash;

  /// HUD bakiyesi (klip karelerine yazılır).
  final int Function() coinBalance;

  late final Ticker _ticker;
  FallWorld _world = FallWorld();
  Duration _last = Duration.zero;
  double _time = 0;
  bool _running = false;
  bool _pressed = false;
  bool _toggledOpen = true;
  bool _wasOpen = true;
  ControlMode _mode = ControlMode.hold;

  /// Kat sayacı (HUD dinler).
  final ValueNotifier<int> floor = ValueNotifier(0);

  double get time => _time;
  int get currentFloor => _world.floor;
  double get shieldLeft => _world.shieldLeft;

  WorldSnapshot snapshot() => _world.snapshot();

  /// Görünür dünya yüksekliği (tasarım birimi).
  // Ayarlayıcı yerine metot: lint (setter'ın getter'ı yok).
  // ignore: use_setters_to_change_properties
  void setViewHeight(double value) => _world.viewHeight = value;

  /// Dünya yalnızca oyun aşamasında akar.
  void setRunning({required bool value}) {
    if (_running == value) return;
    _running = value;
    if (value) _wasOpen = _isOpen;
  }

  // ignore: use_setters_to_change_properties
  void setControlMode(ControlMode mode) => _mode = mode;

  bool get _isOpen => switch (_mode) {
    ControlMode.hold => _pressed,
    ControlMode.toggle => _toggledOpen,
  };

  void pointerDown() {
    _pressed = true;
    if (_mode == ControlMode.toggle && _running) _toggledOpen = !_toggledOpen;
  }

  void pointerUp() => _pressed = false;

  /// Devam: aynı kattan, koruma ile.
  void revive() {
    _world.revive();
    _toggledOpen = true;
    notifyListeners();
  }

  /// Sayaç başlarken (devam dışı) koruma.
  void grantShield() {
    _world.grantShield();
    notifyListeners();
  }

  /// Yeni oyun (aynı ekranda "Tekrar oyna" yerine rota yenilenir; test için).
  @visibleForTesting
  void reset({int? seed}) {
    _world = FallWorld(seed: seed);
    floor.value = 0;
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _time += dt;
    if (_running && _world.isAlive) {
      final open = _isOpen;
      if (open != _wasOpen) {
        sound.play(open ? GameSound.umbrellaOpen : GameSound.umbrellaClose);
        _wasOpen = open;
      }
      final events = _world.update(dt, umbrellaOpen: open);
      replay.record(dt, () => _world.snapshot().withBalance(coinBalance()));
      for (final event in events) {
        switch (event) {
          case CoinCollected():
            onCoin();
          case FloorReached(:final floor):
            this.floor.value = floor;
          case AwningBounced():
            sound.play(GameSound.umbrellaOpen, volume: 0.9);
          case EggCrashed():
            replay.hold(
              (age) =>
                  _world.snapshot(crashAge: age).withBalance(coinBalance()),
            );
            onCrash(_world.floor);
        }
      }
    }
    if (!_world.isAlive) _world.advanceDead(dt);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    floor.dispose();
    super.dispose();
  }
}
