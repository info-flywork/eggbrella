part of '../game_view.dart';

/// Figma sayac: Yumi kalkanla (dünya çizer), büyük 3-2-1 ve "Koruma: 2 sn".
class GameCountdownOverlay extends StatelessWidget {
  const GameCountdownOverlay({required this.seconds, super.key});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AppScreenPadding(
        child: Column(
          children: [
            const SizedBox(height: 44 + AppSpacing.m + 250 + AppSpacing.m),
            TweenAnimationBuilder<double>(
              key: ValueKey(seconds),
              tween: Tween(begin: 1.6, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Opacity(
                opacity: ((scale - 1.6).abs() / 0.6).clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              ),
              child: Text(
                '$seconds',
                style: AppTextStyles.countdownBig.copyWith(
                  color: ColorName.colorWhite,
                  shadows: AppShadows.countdownGlow,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            AppCreamPill(
              label: LocaleKeys.game_shield.tr(
                args: ['${GameConfig.shieldSeconds.round()}'],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
          ],
        ),
      ),
    );
  }
}
