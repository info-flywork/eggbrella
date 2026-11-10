part of '../store_view.dart';

/// Alttaki krem panel: sekmeler, sabit yükseklikte ürün alanı (sekme
/// değişince panel zıplamaz) ve işlem satırı.
class StorePanel extends StatelessWidget {
  const StorePanel({
    required this.state,
    required this.onTabChanged,
    required this.onSkinTapped,
    required this.onSkinBuyTapped,
    required this.onCoinPackTapped,
    required this.onRestoreTapped,
    super.key,
  });

  final StoreState state;
  final ValueChanged<StoreTab> onTabChanged;
  final ValueChanged<Skin> onSkinTapped;
  final VoidCallback onSkinBuyTapped;
  final ValueChanged<CoinPack> onCoinPackTapped;
  final VoidCallback onRestoreTapped;

  /// 4 sütun x 2 satır skin kartı ya da 3 coin paketi.
  static const double contentHeight = 252;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        bottom > 0 ? bottom : AppSpacing.s,
      ),
      decoration: const BoxDecoration(
        color: ColorName.colorCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: ColorName.colorCreamLine, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331E2A4A),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSegmented<StoreTab>(
            options: [
              (StoreTab.egg, LocaleKeys.store_tab_egg.tr()),
              (StoreTab.umbrella, LocaleKeys.store_tab_umbrella.tr()),
              (StoreTab.coins, LocaleKeys.store_tab_coins.tr()),
            ],
            selected: state.tab,
            onChanged: onTabChanged,
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: contentHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (state.tab.slot) {
                final SkinSlot slot => StoreSkinGrid(
                  key: ValueKey(slot),
                  slot: slot,
                  state: state,
                  onTapped: onSkinTapped,
                ),
                null => StoreCoinList(
                  key: const ValueKey('coins'),
                  state: state,
                  onTapped: onCoinPackTapped,
                ),
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 56,
            child: _Action(state: state, onBuy: onSkinBuyTapped),
          ),
          AppTextButton(
            label: LocaleKeys.store_restore.tr(),
            onPressed: state.isBusy ? null : onRestoreTapped,
          ),
        ],
      ),
    );
  }
}

/// Skin sekmelerinde: önizlenen skin alınmamışsa satın al, alınmışsa
/// kullanıldığı bilgisi. Coin sekmesinde devam ipucu.
class _Action extends StatelessWidget {
  const _Action({required this.state, required this.onBuy});

  final StoreState state;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final skin = state.focused;
    if (skin == null) {
      return Center(
        child: Text(
          LocaleKeys.store_coins_hint.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.cardBody.copyWith(
            color: ColorName.colorNavySoft,
          ),
        ),
      );
    }
    if (state.isOwned(skin)) {
      return Center(
        child: AppCreamPill(
          leading: const Icon(
            Icons.check_rounded,
            size: 20,
            color: ColorName.colorGreenDark,
          ),
          label: '${skin.nameKey.tr()} · ${LocaleKeys.store_equipped.tr()}',
        ),
      );
    }
    if (state.busy == skin.productId) {
      return const Center(
        child: CircularProgressIndicator(color: ColorName.colorGreen),
      );
    }
    final price = state.prices[skin.productId];
    return AppPrimaryButton(
      label: LocaleKeys.store_buy.tr(args: [price ?? '…']),
      onPressed: price == null || state.isBusy ? null : onBuy,
    );
  }
}
