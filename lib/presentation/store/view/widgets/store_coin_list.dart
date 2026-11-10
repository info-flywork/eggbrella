part of '../store_view.dart';

/// Coin paketleri: her satırda coin yığını, miktar, kaç devam ettiği ve
/// fiyat butonu; popüler / avantajlı paketlerde etiket.
class StoreCoinList extends StatelessWidget {
  const StoreCoinList({required this.state, required this.onTapped, super.key});

  final StoreState state;
  final ValueChanged<CoinPack> onTapped;

  /// Devam bedeli (oyuncu ilerlemesindeki varsayılanla aynı).
  static const continuePrice = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, pack) in CoinPacks.all.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          Expanded(
            child: _CoinPackTile(
              pack: pack,
              stack: i + 1,
              price: state.prices[pack.productId],
              busy: state.busy == pack.productId,
              enabled: !state.isBusy,
              onTap: () => onTapped(pack),
            ),
          ),
        ],
      ],
    );
  }
}

class _CoinPackTile extends StatelessWidget {
  const _CoinPackTile({
    required this.pack,
    required this.stack,
    required this.price,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final CoinPack pack;
  final int stack;
  final String? price;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = pack.badge;
    final canBuy = enabled && price != null;
    return AppPressable(
      onPressed: canBuy ? onTap : null,
      semanticLabel: '${pack.coins} coin, ${price ?? ''}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badge != null
                ? ColorName.colorYellow
                : ColorName.colorCreamLine,
            width: badge != null ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            _CoinStack(count: stack),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        LocaleKeys.store_coins_amount.tr(
                          args: ['${pack.coins}'],
                        ),
                        style: AppTextStyles.pill.copyWith(
                          color: ColorName.colorNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Flexible(child: _Badge(label: badge.tr())),
                      ],
                    ],
                  ),
                  AppFitText(
                    LocaleKeys.store_coins_continues.tr(
                      args: ['${pack.coins ~/ StoreCoinList.continuePrice}'],
                    ),
                    alignment: Alignment.centerLeft,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.cardBody.copyWith(
                      color: ColorName.colorNavySoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _PriceButton(price: price, busy: busy, enabled: canBuy),
          ],
        ),
      ),
    );
  }
}

class _CoinStack extends StatelessWidget {
  const _CoinStack({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: 4.0 + i * 7,
              top: 8.0 - i * 4,
              child: const AppCoinIcon(),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: ColorName.colorYellow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AppFitText(
        label,
        style: AppTextStyles.cardBody.copyWith(
          color: ColorName.colorNavy,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  const _PriceButton({
    required this.price,
    required this.busy,
    required this.enabled,
  });

  final String? price;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled || busy
            ? ColorName.colorGreen
            : ColorName.colorCreamLine,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border(
          bottom: BorderSide(
            color: enabled || busy
                ? ColorName.colorGreenDark
                : ColorName.colorCreamLine,
            width: 3,
          ),
        ),
      ),
      child: busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: ColorName.colorWhite,
              ),
            )
          : AppFitText(
              price ?? '…',
              style: AppTextStyles.segment.copyWith(
                color: ColorName.colorWhite,
              ),
            ),
    );
  }
}
