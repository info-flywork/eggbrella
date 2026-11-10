part of '../result_view.dart';

/// Figma oyun-sonu / yeni-rekor: bandajlı Yumi, skor, rekor ya da kurdele,
/// kazanılan coin, Tekrar oyna, Klibi paylaş ve ana sayfa.
class ResultLoadedBody extends StatelessWidget {
  const ResultLoadedBody({
    required this.result,
    required this.canShareClip,
    required this.onPlayAgain,
    required this.onShare,
    required this.onHome,
    super.key,
  });

  final GameResult result;
  final bool canShareClip;
  final VoidCallback onPlayAgain;
  final VoidCallback onShare;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    const white = ColorName.colorWhite;
    return Stack(
      fit: StackFit.expand,
      children: [
        AppBackground(image: Assets.images.imgBgRooftop),
        if (result.isNewRecord) const ResultConfetti(),
        AppScreenPadding(
          child: Column(
            children: [
              const SizedBox(height: 10 + AppSpacing.xs),
              // Kısa ekranlarda yalnız Yumi küçülür.
              Flexible(
                flex: 5,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 246),
                  child: const AppEntrance(
                    offset: Offset(0, -30),
                    scaleFrom: 0.8,
                    curve: Curves.easeOutBack,
                    child: AppFloat(
                      amplitude: 5,
                      child: AppYumi(
                        pose: YumiPose.bandaged,
                        width: 190,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                LocaleKeys.result_your_score.tr(),
                style: AppTextStyles.scoreLabel.copyWith(
                  color: white,
                  shadows: AppShadows.floorText,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppEntrance(
                delay: const Duration(milliseconds: 120),
                scaleFrom: 0.6,
                offset: Offset.zero,
                curve: Curves.easeOutBack,
                child: _CountUpScore(floor: result.floor),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (result.isNewRecord)
                const AppEntrance(
                  delay: Duration(milliseconds: 350),
                  scaleFrom: 0.4,
                  offset: Offset.zero,
                  curve: Curves.elasticOut,
                  duration: Duration(milliseconds: 900),
                  child: _RecordRibbon(),
                )
              else
                AppRecordPill(
                  label: LocaleKeys.common_record.tr(
                    args: ['${result.bestFloor}'],
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              AppCoinPill(amount: '+${result.coinsEarned}'),
              const Spacer(flex: 2),
              AppPrimaryButton(
                label: LocaleKeys.result_play_again.tr(),
                width: 300,
                height: 68,
                textStyle: AppTextStyles.largeButton,
                onPressed: onPlayAgain,
              ),
              const SizedBox(height: AppSpacing.xs * 2 + 4),
              AppSecondaryButton(
                label: LocaleKeys.result_share_clip.tr(),
                width: 240,
                leading: Assets.images.icons.icShare.image(
                  width: 28,
                  height: 28,
                ),
                onPressed: canShareClip ? onShare : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: AppCircleIconButton(
                  icon: Assets.images.icons.icHome.image(),
                  semanticLabel: LocaleKeys.result_home.tr(),
                  onPressed: onHome,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "152. kat" — kısa sürede sıfırdan sayarak gelir.
class _CountUpScore extends StatelessWidget {
  const _CountUpScore({required this.floor});

  final int floor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: floor.toDouble()),
      duration: Duration(milliseconds: math.min(1200, 300 + floor * 8)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => AppFitText(
        LocaleKeys.common_floor.tr(args: ['${value.round()}']),
        style: AppTextStyles.score.copyWith(
          color: ColorName.colorWhite,
          shadows: AppShadows.floorText,
        ),
      ),
    );
  }
}

/// Figma img/kurdele: 330x147 kurdele üzerinde "Yeni rekor!" (alt boşluk 26).
class _RecordRibbon extends StatelessWidget {
  const _RecordRibbon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 147,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Assets.images.imgRibbon.image(
            width: 330,
            height: 147,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 26),
            child: AppFitText(
              LocaleKeys.result_new_record.tr(),
              style: AppTextStyles.ribbon.copyWith(color: ColorName.colorNavy),
            ),
          ),
        ],
      ),
    );
  }
}
