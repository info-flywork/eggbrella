part of '../result_view.dart';

/// Figma klip-hazirlaniyor: dönen halka içinde klaket, "Vazgeç".
class ResultClipPreparingCard extends StatelessWidget {
  const ResultClipPreparingCard({required this.onCancel, super.key});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _ClipCard(
      icon: SizedBox.square(
        dimension: 96,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _SpinningRing(),
            Assets.images.icons.icClapperboard.image(width: 40, height: 40),
          ],
        ),
      ),
      title: LocaleKeys.clip_preparing_title.tr(),
      message: LocaleKeys.clip_preparing_message.tr(),
      actions: [
        AppTextButton(
          label: LocaleKeys.common_cancel.tr(),
          onPressed: onCancel,
        ),
      ],
    );
  }
}

/// Figma klip-hata: kırmızı daire içinde video-off, "Tekrar dene" / "Kapat".
class ResultClipErrorCard extends StatelessWidget {
  const ResultClipErrorCard({
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _ClipCard(
      icon: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorName.colorErrorSoft,
          shape: BoxShape.circle,
        ),
        child: Assets.icons.icVideoOff.svg(width: 40, height: 40),
      ),
      title: LocaleKeys.clip_error_title.tr(),
      message: LocaleKeys.clip_error_message.tr(),
      actions: [
        AppPrimaryButton(
          label: LocaleKeys.common_retry.tr(),
          onPressed: onRetry,
        ),
        AppTextButton(label: LocaleKeys.common_close.tr(), onPressed: onClose),
      ],
    );
  }
}

class _ClipCard extends StatelessWidget {
  const _ClipCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });

  final Widget icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: AppEntrance(
          scaleFrom: 0.92,
          offset: Offset.zero,
          curve: Curves.easeOutBack,
          child: AppModalCard(
            width: 340,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: AppSpacing.s),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
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

/// Figma img/halka: yükleme göstergesi olarak döner.
class _SpinningRing extends StatefulWidget {
  const _SpinningRing();

  @override
  State<_SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<_SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _controller,
    child: Assets.images.imgRing.image(width: 96, height: 96),
  );
}
