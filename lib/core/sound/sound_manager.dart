import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:flutter/foundation.dart';

/// Oyun ses efektleri (`assets/sounds/`, scripts/generate_sounds.py).
enum GameSound {
  coin('coin.wav'),
  crack('crack.wav'),
  umbrellaOpen('umbrella_open.wav'),
  umbrellaClose('umbrella_close.wav'),
  beep('beep.wav'),
  go('go.wav'),
  fanfare('fanfare.wav'),
  tap('tap.wav');

  const GameSound(this.file);

  final String file;
}

/// Ayarlardaki "Ses" ve "Müzik" tercihlerine uyarak efektleri ve arka plan
/// müziğini çalar. iOS'ta sessiz moda saygı duyar ve diğer uygulamaların
/// müziğini kesmez (ambient).
class SoundManager {
  SoundManager(this._prefs);

  final SharedPrefManager _prefs;
  final Map<GameSound, AudioPool> _pools = {};
  final AudioPlayer _music = AudioPlayer(playerId: 'music');
  Future<void>? _loading;
  bool _foreground = true;
  bool _musicWanted = false;

  /// Splash'te bir kez çağrılır; hata olursa oyun sessiz devam eder.
  Future<void> preload() => _loading ??= _load();

  Future<void> _load() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(respectSilence: true).build(),
      );
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.35);
      await _music.setSource(AssetSource('sounds/music.m4a'));
      for (final sound in GameSound.values) {
        _pools[sound] = await AudioPool.createFromAsset(
          path: 'sounds/${sound.file}',
          maxPlayers: 3,
        );
      }
    } on Object catch (e) {
      debugPrint('SoundManager: sesler yüklenemedi: $e');
    }
  }

  void play(GameSound sound, {double volume = 0.7}) {
    if (!_prefs.isSoundEnabled) return;
    final pool = _pools[sound];
    if (pool == null) return;
    unawaited(pool.start(volume: volume).then((_) {}, onError: (_) {}));
  }

  /// Arka plan müziğini başlatır (ayar kapalıysa yalnızca isteği hatırlar).
  void startMusic() {
    _musicWanted = true;
    _syncMusic();
  }

  void stopMusic() {
    _musicWanted = false;
    _syncMusic();
  }

  /// Ayarlardan "Müzik" değiştiğinde çağrılır.
  void onMusicSettingChanged() => _syncMusic();

  void onLifecycleChanged({required bool foreground}) {
    _foreground = foreground;
    _syncMusic();
  }

  void _syncMusic() {
    final shouldPlay = _musicWanted && _foreground && _prefs.isMusicEnabled;
    final future = shouldPlay ? _music.resume() : _music.pause();
    unawaited(future.then((_) {}, onError: (_) {}));
  }
}
