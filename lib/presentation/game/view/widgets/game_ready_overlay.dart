part of '../game_view.dart';

/// Figma oyun-baslangic / ipucu: alt kısımda "Başlamak için dokun" ve
/// (ipucunda) üstünde kontrol kartı. Ekranın tamamı dokunulabilir.
class GameReadyOverlay extends StatelessWidget {
  const GameReadyOverlay({required this.onTap, this.hint, super.key});

  final VoidCallback onTap;
  final Widget? hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.game_tap_to_start.tr(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AppScreenPadding(
          child: Column(
            children: [
              const Spacer(),
              if (hint != null) ...[
                AppEntrance(scaleFrom: 0.92, child: hint!),
                const SizedBox(height: AppSpacing.m),
              ],
              AppPulse(
                child: Text(
                  LocaleKeys.game_tap_to_start.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tapToStart.copyWith(
                    color: ColorName.colorWhite,
                    shadows: AppShadows.floorText,
                  ),
                ),
              ),
              const SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }
}
