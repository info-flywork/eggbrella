part of '../game_view.dart';

/// Figma ipucu "Hint card": basılı tut = yavaşla, bırak = hızlı düş.
/// "Dokun aç-kapa" modunda metinler buna göre değişir.
class GameHintCard extends StatelessWidget {
  const GameHintCard({required this.mode, super.key});

  final ControlMode mode;

  @override
  Widget build(BuildContext context) {
    final (first, second) = switch (mode) {
      ControlMode.hold => (
        LocaleKeys.game_hint_hold.tr(),
        LocaleKeys.game_hint_release.tr(),
      ),
      ControlMode.toggle => (
        LocaleKeys.game_hint_tap_open.tr(),
        LocaleKeys.game_hint_tap_close.tr(),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: ColorName.colorCream,
        borderRadius: BorderRadius.circular(AppRadius.hintCard),
        border: Border.all(color: ColorName.colorCreamLine, width: 2),
        boxShadow: AppShadows.pill,
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HintRow(image: Assets.icons.icHintHold, label: first),
            const SizedBox(height: 10),
            Container(height: 2, color: ColorName.colorCreamLine),
            const SizedBox(height: 10),
            _HintRow(image: Assets.icons.icHintRelease, label: second),
          ],
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({required this.image, required this.label});

  /// Vektör çizim: her ekran yoğunluğunda keskin (eski PNG'ler 148 px idi).
  final SvgGenImage image;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        image.svg(width: 96, height: 48),
        const SizedBox(width: AppSpacing.m),
        Text(
          label,
          style: AppTextStyles.pill.copyWith(color: ColorName.colorNavy),
        ),
      ],
    );
  }
}
