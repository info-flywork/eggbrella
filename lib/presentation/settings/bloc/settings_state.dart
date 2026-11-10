import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:equatable/equatable.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.sound,
    required this.music,
    required this.haptic,
    required this.controlMode,
  });

  final bool sound;
  final bool music;
  final bool haptic;
  final ControlMode controlMode;

  @override
  List<Object?> get props => [sound, music, haptic, controlMode];
}
