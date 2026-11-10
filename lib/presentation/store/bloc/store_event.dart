import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/store/coin_pack.dart';
import 'package:eggbrella/presentation/store/bloc/store_state.dart';
import 'package:equatable/equatable.dart';

sealed class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

final class StoreStarted extends StoreEvent {
  const StoreStarted();
}

/// Yumurta / Şemsiye / Coin sekmesi.
final class StoreTabChanged extends StoreEvent {
  const StoreTabChanged(this.tab);

  final StoreTab tab;

  @override
  List<Object?> get props => [tab];
}

/// Skin kartı: önizlenir; sahip olunan skin hemen giyilir.
final class StoreSkinTapped extends StoreEvent {
  const StoreSkinTapped(this.skin);

  final Skin skin;

  @override
  List<Object?> get props => [skin];
}

/// Önizlenen skini satın al.
final class StoreSkinBuyTapped extends StoreEvent {
  const StoreSkinBuyTapped();
}

final class StoreCoinPackTapped extends StoreEvent {
  const StoreCoinPackTapped(this.pack);

  final CoinPack pack;

  @override
  List<Object?> get props => [pack];
}

final class StoreRestoreTapped extends StoreEvent {
  const StoreRestoreTapped();
}

/// Skin sahipliği / seçimi değişti (depo dinlenir).
final class StoreSkinsChanged extends StoreEvent {
  const StoreSkinsChanged();
}

final class StoreNoticeShown extends StoreEvent {
  const StoreNoticeShown();
}
