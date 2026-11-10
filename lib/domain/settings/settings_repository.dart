import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';

/// Cihaz tercihleri: ses, müzik, titreşim, kontrol modu.
class SettingsRepository {
  SettingsRepository(this._prefs, this._soundManager);

  final SharedPrefManager _prefs;
  final SoundManager _soundManager;

  bool get isSoundEnabled => _prefs.isSoundEnabled;
  bool get isMusicEnabled => _prefs.isMusicEnabled;
  bool get isHapticEnabled => _prefs.isHapticEnabled;
  ControlMode get controlMode => _prefs.controlMode;

  Future<void> setSoundEnabled({required bool enabled}) =>
      _prefs.setSoundEnabled(enabled: enabled);

  Future<void> setMusicEnabled({required bool enabled}) async {
    await _prefs.setMusicEnabled(enabled: enabled);
    _soundManager.onMusicSettingChanged();
  }

  Future<void> setHapticEnabled({required bool enabled}) =>
      _prefs.setHapticEnabled(enabled: enabled);

  Future<void> setControlMode(ControlMode mode) => _prefs.setControlMode(mode);
}
