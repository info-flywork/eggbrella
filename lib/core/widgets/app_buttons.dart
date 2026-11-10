import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_fit_text.dart';
import 'package:eggbrella/core/widgets/app_pressable.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma Button/Primary: yeşil hap, koyu yeşil çerçeve ve 4px taban,
/// üstte iç parlama.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.height = 56,
    this.width = double.infinity,
    this.textStyle = AppTextStyles.button,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;
  final double width;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      pressedOffset: 4,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorName.colorGreen,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: ColorName.colorGreenDark, width: 2),
          boxShadow: AppShadows.primaryButton,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // İç parlama: inset 0 3 2 rgba(255,255,255,.35).
            const _InnerHighlight(color: ColorName.colorInnerHighlight35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Flexible(
                    child: AppFitText(
                      label,
                      style: textStyle.copyWith(color: ColorName.colorWhite),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma Button/Secondary: krem hap, krem çizgi çerçeve ve 3px taban.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.width = double.infinity,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      child: Container(
        width: width,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: ColorName.colorCream,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: ColorName.colorCreamLine, width: 2),
          boxShadow: AppShadows.secondaryButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Flexible(
              child: AppFitText(
                label,
                style: AppTextStyles.button.copyWith(
                  color: ColorName.colorNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma Button/Text: 44px yükseklikte soluk lacivert metin.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      pressedOffset: 1,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppFitText(
          label,
          style: AppTextStyles.textButton.copyWith(
            color: ColorName.colorNavySoft,
          ),
        ),
      ),
    );
  }
}

/// Figma: 44px beyaz daire ikon butonu (Pause, Ayarlar, Ana sayfa, Kapat).
class AppCircleIconButton extends StatelessWidget {
  const AppCircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  /// 28px ikon.
  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      pressedOffset: 1,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorName.colorWhite,
          shape: BoxShape.circle,
          border: Border.all(color: ColorName.colorCreamLine, width: 1.5),
          boxShadow: AppShadows.iconButton,
        ),
        // 3D ikonlar (assets/images/icons) çizgisiz ve dolu: 28 ile okunur.
        child: SizedBox.square(dimension: 28, child: icon),
      ),
    );
  }
}

/// Üst kenardan içe doğru beyaz parlama (CSS inset shadow karşılığı).
class _InnerHighlight extends StatelessWidget {
  const _InnerHighlight({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0, 0.22],
            ),
          ),
        ),
      ),
    );
  }
}
