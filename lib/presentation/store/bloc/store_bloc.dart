import 'dart:async';

import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:eggbrella/domain/store/coin_store.dart';
import 'package:eggbrella/presentation/store/bloc/store_event.dart';
import 'package:eggbrella/presentation/store/bloc/store_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mağaza: yumurta ve şemsiye skinleri (non-consumable) ile coin paketleri
/// (consumable; coin'i sunucu yükler).
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc(this._skins, this._coins)
    : super(
        StoreState(
          tab: StoreTab.egg,
          selection: _skins.selection,
          preview: _skins.selection,
          owned: _ownedOf(_skins),
          coins: _coins.balance,
        ),
      ) {
    on<StoreStarted>(_onStarted);
    on<StoreTabChanged>((e, emit) => emit(state.copyWith(tab: e.tab)));
    on<StoreSkinTapped>(_onSkinTapped);
    on<StoreSkinBuyTapped>(_onSkinBuyTapped);
    on<StoreCoinPackTapped>(_onCoinPackTapped);
    on<StoreRestoreTapped>(_onRestoreTapped);
    on<StoreSkinsChanged>(_onSkinsChanged);
    on<StoreNoticeShown>((e, emit) => emit(state.copyWith(clearNotice: true)));
    _skins.addListener(_onRepository);
  }

  final SkinRepository _skins;
  final CoinStore _coins;

  static Set<String> _ownedOf(SkinRepository repo) => {
    for (final s in [...SkinCatalog.eggs, ...SkinCatalog.umbrellas])
      if (repo.isOwned(s)) StoreState.keyOf(s),
  };

  void _onRepository() => add(const StoreSkinsChanged());

  Future<void> _onStarted(StoreStarted event, Emitter<StoreState> emit) async {
    final prices = await Future.wait([_skins.prices(), _coins.prices()]);
    emit(state.copyWith(prices: {...prices[0], ...prices[1]}));
  }

  Future<void> _onSkinTapped(
    StoreSkinTapped event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(preview: state.preview.withSkin(event.skin)));
    if (_skins.isOwned(event.skin)) await _skins.equip(event.skin);
  }

  Future<void> _onSkinBuyTapped(
    StoreSkinBuyTapped event,
    Emitter<StoreState> emit,
  ) async {
    final skin = state.focused;
    if (skin == null || state.isBusy || _skins.isOwned(skin)) return;
    emit(state.copyWith(busy: skin.productId));
    final result = await _skins.buy(skin);
    emit(
      state.copyWith(
        clearBusy: true,
        notice: _notice(result, const StoreSkinPurchasedNotice()),
      ),
    );
  }

  Future<void> _onCoinPackTapped(
    StoreCoinPackTapped event,
    Emitter<StoreState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: event.pack.productId));
    final outcome = await _coins.buy(event.pack);
    emit(
      state.copyWith(
        clearBusy: true,
        coins: _coins.balance,
        notice: _notice(
          outcome.result,
          StoreCoinsPurchasedNotice(outcome.credited),
        ),
      ),
    );
  }

  StoreNotice? _notice(PurchaseResult result, StoreNotice success) =>
      switch (result) {
        PurchaseCompleted() => success,
        PurchasePending() => const StorePendingNotice(),
        PurchaseFailed(:final error) => StoreFailedNotice(error),
        PurchaseCancelled() => null,
      };

  Future<void> _onRestoreTapped(
    StoreRestoreTapped event,
    Emitter<StoreState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: 'restore'));
    try {
      final skins = await _skins.restore();
      final coins = await _coins.sync();
      emit(
        state.copyWith(
          clearBusy: true,
          coins: _coins.balance,
          notice: StoreRestoredNotice(skins: skins, coins: coins),
        ),
      );
    } on Object catch (e) {
      debugPrint('StoreBloc.restore: $e');
      emit(
        state.copyWith(
          clearBusy: true,
          notice: const StoreFailedNotice(PurchaseError.network),
        ),
      );
    }
  }

  void _onSkinsChanged(StoreSkinsChanged event, Emitter<StoreState> emit) {
    final selection = _skins.selection;
    // Alınmamış bir skine bakılıyorsa o parçanın önizlemesi korunur.
    var preview = selection;
    for (final slot in SkinSlot.values) {
      final looked = state.preview.of(slot);
      if (!_skins.isOwned(looked)) preview = preview.withSkin(looked);
    }
    emit(
      state.copyWith(
        selection: selection,
        preview: preview,
        owned: _ownedOf(_skins),
      ),
    );
  }

  @override
  Future<void> close() {
    _skins.removeListener(_onRepository);
    return super.close();
  }
}
