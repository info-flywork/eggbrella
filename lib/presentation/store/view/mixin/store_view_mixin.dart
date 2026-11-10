part of '../store_view.dart';

mixin StoreViewMixin on State<StoreView> {
  StoreBloc get _bloc => context.read<StoreBloc>();

  void onCloseTapped() => context.pop();

  void onTabChanged(StoreTab tab) => _bloc.add(StoreTabChanged(tab));

  void onSkinTapped(Skin skin) => _bloc.add(StoreSkinTapped(skin));

  void onSkinBuyTapped() => _bloc.add(const StoreSkinBuyTapped());

  void onCoinPackTapped(CoinPack pack) => _bloc.add(StoreCoinPackTapped(pack));

  void onRestoreTapped() => _bloc.add(const StoreRestoreTapped());

  void onStateChanged(BuildContext context, StoreState state) {
    final notice = state.notice;
    if (notice == null) return;
    final message = switch (notice) {
      StoreSkinPurchasedNotice() => LocaleKeys.store_skin_purchased.tr(),
      StoreCoinsPurchasedNotice(:final credited) =>
        credited > 0
            ? LocaleKeys.store_coins_purchased.tr(args: ['$credited'])
            : LocaleKeys.store_coins_on_the_way.tr(),
      StorePendingNotice() => LocaleKeys.store_pending.tr(),
      StoreRestoredNotice(:final skins, :final coins) =>
        skins + coins > 0
            ? LocaleKeys.store_restore_done.tr()
            : LocaleKeys.store_restore_none.tr(),
      StoreFailedNotice(:final error) => switch (error) {
        PurchaseError.network => LocaleKeys.store_error_network.tr(),
        PurchaseError.notAllowed => LocaleKeys.store_error_not_allowed.tr(),
        PurchaseError.unavailable => LocaleKeys.store_error_unavailable.tr(),
        PurchaseError.store ||
        PurchaseError.unknown => LocaleKeys.store_error_generic.tr(),
      },
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    _bloc.add(const StoreNoticeShown());
  }
}
