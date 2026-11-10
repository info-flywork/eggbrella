part of '../store_view.dart';

/// Sekmedeki skinler (4 sütun, kaydırma yok). Her kart, giyilen diğer
/// parçayla birlikte gösterilir.
class StoreSkinGrid extends StatelessWidget {
  const StoreSkinGrid({
    required this.slot,
    required this.state,
    required this.onTapped,
    super.key,
  });

  final SkinSlot slot;
  final StoreState state;
  final ValueChanged<Skin> onTapped;

  static const _columns = 4;
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final skins = SkinCatalog.of(slot);
    final rows = (skins.length / _columns).ceil();
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - _gap * (_columns - 1)) / _columns;
        final h = (box.maxHeight - _gap * (rows - 1)) / rows;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final skin in skins)
              SizedBox(
                width: w,
                height: h,
                child: _SkinCard(
                  skin: skin,
                  skins: state.selection.withSkin(skin),
                  focused: state.focused == skin,
                  equipped: state.selection.of(slot) == skin,
                  owned: state.isOwned(skin),
                  price: state.prices[skin.productId],
                  onTap: () => onTapped(skin),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.skins,
    required this.focused,
    required this.equipped,
    required this.owned,
    required this.price,
    required this.onTap,
  });

  final Skin skin;
  final SkinSelection skins;
  final bool focused;
  final bool equipped;
  final bool owned;
  final String? price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = skin.nameKey.tr();
    final status = equipped
        ? LocaleKeys.store_selected.tr()
        : owned
        ? (skin.isFree
              ? LocaleKeys.store_free.tr()
              : LocaleKeys.store_owned.tr())
        : (price ?? '…');
    return AppPressable(
      onPressed: onTap,
      semanticLabel: '$name, $status',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
        decoration: BoxDecoration(
          color: focused ? ColorName.colorWhite : const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: focused ? ColorName.colorGreen : ColorName.colorCreamLine,
            width: focused ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: AppYumi(pose: YumiPose.calm, skins: skins),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: AppTextStyles.cardBody.copyWith(
                color: ColorName.colorNavy,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            _StatusChip(label: status, equipped: equipped, locked: !owned),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.equipped,
    required this.locked,
  });

  final String label;
  final bool equipped;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = equipped
        ? (ColorName.colorGreen, ColorName.colorWhite)
        : locked
        ? (ColorName.colorNavy, ColorName.colorWhite)
        : (ColorName.colorCreamLine, ColorName.colorNavy);
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: AppTextStyles.cardBody.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
