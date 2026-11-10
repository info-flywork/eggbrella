part of '../splash_view.dart';

/// Figma 01-01-splash (typewriter): yeşil zemin, "flywork" harf harf belirir
/// (harf başına ~140 ms, cubic-bezier(0, 0, .58, 1)).
class SplashBrandBody extends StatefulWidget {
  const SplashBrandBody({super.key});

  @override
  State<SplashBrandBody> createState() => _SplashBrandBodyState();
}

class _SplashBrandBodyState extends State<SplashBrandBody>
    with SingleTickerProviderStateMixin {
  static const _word = 'flywork';
  static const _curve = Cubic(0, 0, 0.58, 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
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
            const step = 1 / _word.length;
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
                                ((_controller.value - i * step) / step).clamp(
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
