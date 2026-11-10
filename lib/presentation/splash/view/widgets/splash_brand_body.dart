part of '../splash_view.dart';

/// Figma 01-01-splash (typewriter): yeşil zemin, "flywork" harf harf belirir.
/// Dashink ile aynı: harf başına 166 ms, opaklık 0→1,
/// cubic-bezier(0, 0, .58, 1); yazı bitince kısa süre ekranda kalır
/// (SplashBloc.brandDuration).
class SplashBrandBody extends StatefulWidget {
  const SplashBrandBody({super.key});

  @override
  State<SplashBrandBody> createState() => _SplashBrandBodyState();
}

class _SplashBrandBodyState extends State<SplashBrandBody>
    with SingleTickerProviderStateMixin {
  static const _word = 'flywork';
  static const _curve = Cubic(0, 0, 0.58, 1);
  static const _step = Duration(milliseconds: 166);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _step * (_word.length + 1),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.brand.copyWith(color: ColorName.colorWhite);
    return ColoredBox(
      color: ColorName.colorBrandGreen,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final ms = _controller.value * _controller.duration!.inMilliseconds;
            final step = _step.inMilliseconds;
            return Semantics(
              label: _word,
              child: ExcludeSemantics(
                child: Text.rich(
                  TextSpan(
                    children: [
                      for (var i = 0; i < _word.length; i++)
                        TextSpan(
                          text: _word[i],
                          style: style.copyWith(
                            color: ColorName.colorWhite.withValues(
                              alpha: _curve.transform(
                                ((ms - i * step) / step).clamp(
                                  0.0,
                                  1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
