import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma Coin ikonu.
class AppCoinIcon extends StatelessWidget {
  const AppCoinIcon({this.size = 32, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      Assets.icons.icCoin.svg(width: size, height: size);
}

/// Figma HUD/Coins: lacivert hap içinde coin + miktar ("134", "+34").
class AppCoinPill extends StatelessWidget {
  const AppCoinPill({required this.amount, super.key});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
      decoration: BoxDecoration(
        color: ColorName.colorNavy,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppCoinIcon(),
          const SizedBox(width: 6),
          Text(
            amount,
            style: AppTextStyles.hudCoins.copyWith(color: ColorName.colorWhite),
          ),
        ],
      ),
    );
  }
}

/// Figma HUD/Floor: gölgeli beyaz "78. kat".
class AppFloorText extends StatelessWidget {
  const AppFloorText({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      style: AppTextStyles.hudFloor.copyWith(
        color: ColorName.colorWhite,
        shadows: AppShadows.floorText,
      ),
    );
  }
}

/// Krem hap (Rekor, Koruma): krem zemin, çizgi çerçeve, yumuşak gölge.
class AppCreamPill extends StatelessWidget {
  const AppCreamPill({
    required this.label,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    super.key,
  });

  final String label;
  final Widget? leading;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ColorName.colorCream,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: ColorName.colorCreamLine, width: 2),
        boxShadow: AppShadows.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.pill.copyWith(color: ColorName.colorNavy),
          ),
        ],
      ),
    );
  }
}

/// Figma "Rekor: 147. kat" (kupa ikonlu krem hap).
class AppRecordPill extends StatelessWidget {
  const AppRecordPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => AppCreamPill(
    label: label,
    leading: Assets.icons.icTrophy.svg(width: 22, height: 22),
  );
}

/// Tam ekran arka plan görseli (Figma: object-cover).
class AppBackground extends StatelessWidget {
  const AppBackground({required this.image, super.key});

  final AssetGenImage image;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: image.image(fit: BoxFit.cover, alignment: Alignment.topCenter),
  );
}
