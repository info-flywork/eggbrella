part of '../splash_view.dart';

/// Figma acilis: gökyüzü, logo, Yumi ve yükleme çubuğu.
class SplashLoadingBody extends StatelessWidget {
  const SplashLoadingBody({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        AppBackground(image: Assets.images.imgBgSky),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.m,
              padding.top + AppSpacing.m,
              AppSpacing.m,
              padding.bottom + AppSpacing.m,
            ),
            child: Column(
              children: [
                const Spacer(flex: 90),
                AppEntrance(
                  duration: const Duration(milliseconds: 700),
                  offset: Offset.zero,
                  scaleFrom: 0.9,
                  curve: Curves.easeOutBack,
                  child: Assets.images.imgLogo.image(width: 350, height: 100),
                ),
                const Spacer(flex: 70),
                const AppFloat(
                  amplitude: 10,
                  child: AppYumi(
                    pose: YumiPose.calm,
                    width: 228,
                    height: 276,
                  ),
                ),
                const Spacer(flex: 124),
                _LoadingBar(progress: progress),
                const Spacer(flex: 70),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Figma Loading bar: 250x18 beyaz hap, 3px iç boşluk, sarı ilerleme.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(progress * 100).round()}%',
      child: Container(
        width: 250,
        height: 18,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: ColorName.colorWhite,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: ColorName.colorCreamLine, width: 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorName.colorYellow,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
