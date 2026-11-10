part of '../settings_view.dart';

/// Figma ayarlar Card/Modal (366 genişlik, üst 64, 4 aralık).
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.state,
    required this.languageName,
    required this.onSoundChanged,
    required this.onMusicChanged,
    required this.onHapticChanged,
    required this.onControlChanged,
    required this.onLanguageTapped,
    required this.onPrivacyTapped,
    required this.onRestoreTapped,
    required this.onCloseTapped,
    super.key,
  });

  final SettingsLoaded state;
  final String languageName;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onHapticChanged;
  final ValueChanged<ControlMode> onControlChanged;
  final VoidCallback onLanguageTapped;
  final VoidCallback onPrivacyTapped;
  final VoidCallback onRestoreTapped;
  final VoidCallback onCloseTapped;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.xxs);
    return AppModalCard(
      banner: LocaleKeys.settings_title.tr(),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      topRight: AppCircleIconButton(
        icon: Assets.icons.icClose.svg(),
        semanticLabel: LocaleKeys.settings_close.tr(),
        onPressed: onCloseTapped,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsToggleRow(
            icon: Assets.icons.icVolume,
            label: LocaleKeys.settings_sound.tr(),
            value: state.sound,
            onChanged: onSoundChanged,
          ),
          gap,
          SettingsToggleRow(
            icon: Assets.icons.icMusic,
            label: LocaleKeys.settings_music.tr(),
            value: state.music,
            onChanged: onMusicChanged,
          ),
          gap,
          SettingsToggleRow(
            icon: Assets.icons.icVibrate,
            label: LocaleKeys.settings_vibration.tr(),
            value: state.haptic,
            onChanged: onHapticChanged,
          ),
          gap,
          SettingsSelectRow(
            icon: Assets.icons.icGlobe,
            label: LocaleKeys.settings_language.tr(),
            value: languageName,
            onTap: onLanguageTapped,
          ),
          gap,
          SettingsControlSection(
            mode: state.controlMode,
            onChanged: onControlChanged,
          ),
          gap,
          SettingsSelectRow(
            icon: Assets.icons.icShield,
            label: LocaleKeys.settings_privacy.tr(),
            value: LocaleKeys.settings_privacy_value.tr(),
            onTap: onPrivacyTapped,
          ),
          gap,
          AppTextButton(
            label: LocaleKeys.settings_restore.tr(),
            onPressed: onRestoreTapped,
          ),
          gap,
          AppPrimaryButton(
            label: LocaleKeys.settings_close.tr(),
            onPressed: onCloseTapped,
          ),
        ],
      ),
    );
  }
}
