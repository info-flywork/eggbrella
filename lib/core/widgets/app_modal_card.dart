import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_fit_text.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma Label/Banner: sarı başlık etiketi (koyu sarı çerçeve + 4px taban).
class AppBanner extends StatelessWidget {
  const AppBanner({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 6),
      decoration: BoxDecoration(
        color: ColorName.colorYellow,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: ColorName.colorYellowDark, width: 2.5),
        boxShadow: AppShadows.banner,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColorName.colorInnerHighlight45, ColorName.colorYellow],
          stops: [0, 0.18],
        ),
      ),
      // Uzun başlıklar şeridi kartın dışına taşırmasın.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: AppFitText(
          label,
          style: AppTextStyles.banner.copyWith(color: ColorName.colorNavy),
        ),
      ),
    );
  }
}

/// Figma Card/Modal: krem kart, 24 köşe; varsa [banner] üst kenarın
/// ortasına yarı taşarak oturur.
class AppModalCard extends StatelessWidget {
  const AppModalCard({
    required this.child,
    this.banner,
    this.width = 366,
    this.padding = const EdgeInsets.fromLTRB(24, 44, 24, 24),
    this.topRight,
    super.key,
  });

  final Widget child;
  final String? banner;
  final double width;
  final EdgeInsets padding;

  /// Sağ üst köşedeki öğe (Ayarlar: Kapat (x)).
  final Widget? topRight;

  /// Banner yüksekliğinin yarısı (49 / 2).
  static const double _bannerOverhang = 26.5;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Padding(
        padding: EdgeInsets.only(top: banner == null ? 0 : _bannerOverhang),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: padding,
              decoration: BoxDecoration(
                color: ColorName.colorCream,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: ColorName.colorCreamLine, width: 2),
                boxShadow: AppShadows.card,
              ),
              child: child,
            ),
            if (banner != null)
              Positioned(
                top: -_bannerOverhang,
                left: 0,
                right: 0,
                child: Center(child: AppBanner(label: banner!)),
              ),
            if (topRight != null)
              Positioned(top: 10, right: 12, child: topRight!),
          ],
        ),
      ),
    );
  }
}

/// Figma Scrim: lacivert %55.
class AppScrim extends StatelessWidget {
  const AppScrim({super.key});

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: ColorName.colorScrim, child: SizedBox.expand());
}
