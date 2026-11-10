part of '../home_view.dart';

/// Figma ana-sayfa: çatı arka planı, ayarlar, logo, çatıda Yumi, OYNA ve
/// rekor satırı.
class HomeLoadedBody extends StatelessWidget {
  const HomeLoadedBody({
    required this.bestFloor,
    required this.onPlayTapped,
    required this.onSettingsTapped,
    required this.onSkinsTapped,
    super.key,
  });

  final int bestFloor;
  final VoidCallback onPlayTapped;
  final VoidCallback onSettingsTapped;
  final VoidCallback onSkinsTapped;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppBackground(image: Assets.images.imgBgRooftop),
        // Yumi çatıda: arka plana bağlı konum (Figma 173,392 · 150x182).
        // Figma'daki 150x182 kutudaki yumurta gövdesiyle aynı boy ve merkez;
        // yeni çizimde şemsiye daha geniş olduğu için kutu büyüdü.
        const AppDesignPositioned(
          left: 164,
          top: 373,
          width: 163,
          height: 204,
          child: AppFloat(
            amplitude: 4,
            child: AppYumi(pose: YumiPose.calm),
          ),
        ),
        AppScreenPadding(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppCircleIconButton(
                    icon: Assets.images.icons.icStore.image(),
                    semanticLabel: LocaleKeys.store_open.tr(),
                    onPressed: onSkinsTapped,
                  ),
                  AppCircleIconButton(
                    icon: Assets.images.icons.icSettings.image(),
                    semanticLabel: LocaleKeys.home_settings.tr(),
                    onPressed: onSettingsTapped,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              AppEntrance(
                offset: const Offset(0, -24),
                scaleFrom: 0.9,
                curve: Curves.easeOutBack,
                child: AppFloat(
                  amplitude: 3,
                  sway: 0.01,
                  period: const Duration(milliseconds: 3200),
                  child: Assets.images.imgLogo.image(width: 340, height: 97),
                ),
              ),
              const Spacer(),
              AppEntrance(
                delay: const Duration(milliseconds: 150),
                offset: const Offset(0, 40),
                child: AppPrimaryButton(
                  label: LocaleKeys.home_play.tr(),
                  width: 260,
                  height: 76,
                  textStyle: AppTextStyles.playButton,
                  onPressed: onPlayTapped,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              AppEntrance(
                delay: const Duration(milliseconds: 250),
                offset: const Offset(0, 40),
                child: AppRecordPill(
                  label: LocaleKeys.common_record.tr(args: ['$bestFloor']),
                ),
              ),
              const SizedBox(height: AppSpacing.m + 30),
            ],
          ),
        ),
      ],
    );
  }
}
