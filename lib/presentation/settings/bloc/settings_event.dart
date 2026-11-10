import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsSoundToggled extends SettingsEvent {
  const SettingsSoundToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class SettingsMusicToggled extends SettingsEvent {
  const SettingsMusicToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class SettingsHapticToggled extends SettingsEvent {
  const SettingsHapticToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class SettingsControlChanged extends SettingsEvent {
  const SettingsControlChanged(this.mode);

  final ControlMode mode;

  @override
  List<Object?> get props => [mode];
}
