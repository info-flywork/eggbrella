part of '../settings_view.dart';

/// Figma Row/Toggle: 52 yükseklik, ikon 24, etiket, toggle.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AssetGenImage icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: icon,
      label: label,
      onTap: () => onChanged(!value),
      trailing: AppToggle(
        value: value,
        onChanged: onChanged,
        semanticLabel: label,
      ),
    );
  }
}

/// Figma Row/Select: etiket, sağda değer ve chevron.
class SettingsSelectRow extends StatelessWidget {
  const SettingsSelectRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final AssetGenImage icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: icon,
      label: label,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: AppFitText(
              value,
              alignment: Alignment.centerRight,
              textAlign: TextAlign.end,
              style: AppTextStyles.rowValue.copyWith(
                color: ColorName.colorNavySoft,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Assets.icons.icChevron.svg(width: 20, height: 20),
        ],
      ),
    );
  }
}

/// Figma "Kontrol": el ikonu + başlık, altında Basılı tut / Dokun aç-kapa.
class SettingsControlSection extends StatelessWidget {
  const SettingsControlSection({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final ControlMode mode;
  final ValueChanged<ControlMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Diğer satırlarla aynı yan boşluk (ikon ve yazı hizalı kalsın).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Assets.images.icons.icHand.image(width: 28, height: 28),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: AppFitText(
                    LocaleKeys.settings_control.tr(),
                    alignment: Alignment.centerLeft,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.rowLabel.copyWith(
                      color: ColorName.colorNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppSegmented<ControlMode>(
            options: [
              (ControlMode.hold, LocaleKeys.settings_control_hold.tr()),
              (ControlMode.toggle, LocaleKeys.settings_control_toggle.tr()),
            ],
            selected: mode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final AssetGenImage icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              icon.image(width: 28, height: 28),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: AppFitText(
                  label,
                  alignment: Alignment.centerLeft,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.rowLabel.copyWith(
                    color: ColorName.colorNavy,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Değer (dil adı, "Politika") uzun dillerde etiketi ezmesin.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
