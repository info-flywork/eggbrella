part of '../game_view.dart';

/// Figma HUD: Pause (sol), "N. kat" (orta), boşluk (sağ); altında sağda
/// HUD/Coins.
class GameHud extends StatelessWidget {
  const GameHud({
    required this.controller,
    required this.coins,
    required this.showTopRow,
    required this.onPauseTapped,
    this.onUiPointerDown,
    super.key,
  });

  final GameWorldController controller;
  final int coins;

  /// Kırılma sahnesinde yalnız coin görünür.
  final bool showTopRow;
  final VoidCallback onPauseTapped;

  /// Pause düğmesine inen parmak: şemsiye kontrolüne sayılmasın diye
  /// oyun ekranına bildirilir (iç Listener dış olandan önce çalışır).
  final ValueChanged<int>? onUiPointerDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: showTopRow
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Listener(
                      onPointerDown: (e) => onUiPointerDown?.call(e.pointer),
                      child: AppCircleIconButton(
                        icon: Assets.images.icons.icPause.image(),
                        semanticLabel: LocaleKeys.game_pause.tr(),
                        onPressed: onPauseTapped,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ValueListenableBuilder<int>(
                          valueListenable: controller.floor,
                          builder: (context, floor, _) => AppFloorText(
                            label: LocaleKeys.common_floor.tr(
                              args: ['$floor'],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: AppCoinPill(amount: '$coins'),
        ),
      ],
    );
  }
}
