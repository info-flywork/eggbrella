part of '../game_view.dart';

/// Figma duraklatma: uyuyan Yumi, devam / ayarlar / ana sayfa.
class GamePauseCard extends StatelessWidget {
  const GamePauseCard({
    required this.floor,
    required this.onResume,
    required this.onSettings,
    required this.onHome,
    super.key,
  });

  final int floor;
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      banner: LocaleKeys.pause_title.tr(),
      imageSize: const Size(170, 183),
      headline: LocaleKeys.pause_headline.tr(),
      message: LocaleKeys.pause_message.tr(args: ['$floor']),
      actions: [
        AppPrimaryButton(
          label: LocaleKeys.pause_resume.tr(),
          leading: Assets.icons.icPlay.svg(width: 24, height: 24),
          onPressed: onResume,
        ),
        AppSecondaryButton(
          label: LocaleKeys.pause_settings.tr(),
          leading: Assets.icons.icSettings.svg(width: 24, height: 24),
          onPressed: onSettings,
        ),
        AppSecondaryButton(
          label: LocaleKeys.pause_home.tr(),
          leading: Assets.icons.icHome.svg(width: 24, height: 24),
          onPressed: onHome,
        ),
      ],
    );
  }
}

/// Duraklatma ve çıkış onayının ortak kartı (Figma Card/Modal, 366 genişlik,
/// 12 aralık).
class _GameModal extends StatelessWidget {
  const _GameModal({
    required this.banner,
    required this.imageSize,
    required this.headline,
    required this.message,
    required this.actions,
  });

  final String banner;
  final Size imageSize;
  final String headline;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppScreenPadding(
      child: Center(
        child: AppEntrance(
          scaleFrom: 0.92,
          offset: const Offset(0, 16),
          curve: Curves.easeOutBack,
          child: AppModalCard(
            banner: banner,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFloat(
                  amplitude: 3,
                  child: AppYumi(
                    pose: YumiPose.sleep,
                    width: imageSize.width,
                    height: imageSize.height,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardHeadline.copyWith(
                    color: ColorName.colorNavy,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardBody.copyWith(
                    color: ColorName.colorNavySoft,
                  ),
                ),
                const SizedBox(height: AppSpacing.s + 4),
                for (final action in actions) ...[
                  const SizedBox(height: AppSpacing.s),
                  action,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
