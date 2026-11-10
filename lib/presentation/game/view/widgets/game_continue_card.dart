part of '../game_view.dart';

/// Figma devam-teklifi: "Kırıldın!" kartı, 5 sn geri sayım halkası, coin ile
/// devam ve "Hayır, teşekkürler".
class GameContinueCard extends StatelessWidget {
  const GameContinueCard({
    required this.secondsLeft,
    required this.price,
    required this.canAfford,
    required this.onContinue,
    required this.onDecline,
    super.key,
  });

  final int secondsLeft;
  final int price;
  final bool canAfford;
  final VoidCallback onContinue;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return AppScreenPadding(
      child: Column(
        children: [
          const Spacer(),
          AppEntrance(
            scaleFrom: 0.9,
            curve: Curves.easeOutBack,
            child: AppModalCard(
              banner: LocaleKeys.continue_offer_title.tr(),
              width: 320,
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CountdownRing(seconds: secondsLeft),
                  const SizedBox(height: AppSpacing.s),
                  AppPrimaryButton(
                    label: LocaleKeys.continue_offer_continue.tr(
                      args: ['$price'],
                    ),
                    leading: const AppCoinIcon(size: 24),
                    onPressed: canAfford ? onContinue : null,
                  ),
                  if (!canAfford) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      LocaleKeys.continue_offer_not_enough.tr(),
                      style: AppTextStyles.cardBody.copyWith(
                        color: ColorName.colorRed,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s),
                  AppTextButton(
                    label: LocaleKeys.continue_offer_no_thanks.tr(),
                    onPressed: onDecline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 170),
        ],
      ),
    );
  }
}

/// Figma "Geri sayım": 132px halka; yeşil yay kalan süreyle akıcı biçimde
/// boşalır, içte kalan saniye her saniye hafifçe zıplar.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    const total = GameBloc.offerSeconds;
    return SizedBox.square(
      dimension: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Her saniye, bir sonraki saniyenin oranına doğrusal iner.
          TweenAnimationBuilder<double>(
            key: ValueKey(seconds),
            tween: Tween(begin: seconds / total, end: (seconds - 1) / total),
            duration: const Duration(seconds: 1),
            builder: (context, fraction, _) => CustomPaint(
              size: const Size.square(132),
              painter: _RingPainter(fraction.clamp(0.0, 1.0)),
            ),
          ),
          TweenAnimationBuilder<double>(
            key: ValueKey('n$seconds'),
            tween: Tween(begin: 1.25, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Text(
              '$seconds',
              style: AppTextStyles.countdownRing.copyWith(
                color: ColorName.colorNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma halka görseli: gri yuva + parlak yeşil yay (12 yönünden saat
/// yönünde kalan süre kadar).
class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);

  final double fraction;

  static const _stroke = 20.0;
  static const _trackDark = Color(0xFFB9C2CE);
  static const _trackLight = Color(0xFFE3E8EE);
  static const _highlight = Color(0x66FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2 + 2);
    Paint stroke(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = color;

    canvas
      ..drawArc(rect, 0, 2 * math.pi, false, stroke(_trackDark, _stroke))
      ..drawArc(rect, 0, 2 * math.pi, false, stroke(_trackLight, _stroke - 6));
    if (fraction <= 0) return;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * fraction;
    canvas
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        stroke(ColorName.colorGreenDark, _stroke),
      )
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        stroke(ColorName.colorGreen, _stroke - 5),
      )
      ..drawArc(
        rect.deflate(3),
        start,
        sweep,
        false,
        stroke(_highlight, 3),
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
