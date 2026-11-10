import 'package:eggbrella/domain/settings/settings_repository.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_event.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Figma ayarlar: toggle'lar anında kaydedilir.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._settings) : super(const SettingsInitial()) {
    on<SettingsStarted>((_, emit) => emit(_load()));
    on<SettingsSoundToggled>((event, emit) async {
      await _settings.setSoundEnabled(enabled: event.enabled);
      emit(_load());
    });
    on<SettingsMusicToggled>((event, emit) async {
      await _settings.setMusicEnabled(enabled: event.enabled);
      emit(_load());
    });
    on<SettingsHapticToggled>((event, emit) async {
      await _settings.setHapticEnabled(enabled: event.enabled);
      emit(_load());
    });
    on<SettingsControlChanged>((event, emit) async {
      await _settings.setControlMode(event.mode);
      emit(_load());
    });
  }

  final SettingsRepository _settings;

  SettingsLoaded _load() => SettingsLoaded(
    sound: _settings.isSoundEnabled,
    music: _settings.isMusicEnabled,
    haptic: _settings.isHapticEnabled,
    controlMode: _settings.controlMode,
  );
}
