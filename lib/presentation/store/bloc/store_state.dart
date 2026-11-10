import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:equatable/equatable.dart';

enum StoreTab {
  egg,
  umbrella,
  coins;

  SkinSlot? get slot => switch (this) {
    StoreTab.egg => SkinSlot.egg,
    StoreTab.umbrella => SkinSlot.umbrella,
    StoreTab.coins => null,
  };
}

/// Kullanıcıya bir kez gösterilecek sonuç.
sealed class StoreNotice extends Equatable {
  const StoreNotice();

  @override
  List<Object?> get props => [];
}

final class StoreSkinPurchasedNotice extends StoreNotice {
  const StoreSkinPurchasedNotice();
}

/// Coin paketi alındı; [credited] 0 ise coin kısa süre içinde yüklenecek.
final class StoreCoinsPurchasedNotice extends StoreNotice {
  const StoreCoinsPurchasedNotice(this.credited);

  final int credited;

  @override
  List<Object?> get props => [credited];
}

final class StorePendingNotice extends StoreNotice {
  const StorePendingNotice();
}

final class StoreFailedNotice extends StoreNotice {
  const StoreFailedNotice(this.error);

  final PurchaseError error;

  @override
  List<Object?> get props => [error];
}

final class StoreRestoredNotice extends StoreNotice {
  const StoreRestoredNotice({required this.skins, required this.coins});

  final int skins;
  final int coins;

  @override
  List<Object?> get props => [skins, coins];
}

final class StoreState extends Equatable {
  const StoreState({
    required this.tab,
    required this.selection,
    required this.preview,
    required this.owned,
    required this.coins,
    this.prices = const {},
    this.busy,
    this.notice,
  });

  final StoreTab tab;

  /// Giyilen skinler.
  final SkinSelection selection;

  /// Önizleme: giyilenler + dokunulan (henüz alınmamış olabilir) skin.
  final SkinSelection preview;

  /// Sahip olunan skinler (`slot/id`).
  final Set<String> owned;

  /// Coin bakiyesi.
  final int coins;

  /// Ürün id -> fiyat (gelmemişse yok).
  final Map<String, String> prices;

  /// Sürmekte olan işlem: ürün id'si ya da geri yükleme için 'restore'.
  final String? busy;
  final StoreNotice? notice;

  bool get isBusy => busy != null;

  /// Skin sekmelerinde önizlenen skin.
  Skin? get focused => switch (tab.slot) {
    final SkinSlot slot => preview.of(slot),
    null => null,
  };

  bool isOwned(Skin skin) => owned.contains(keyOf(skin));

  static String keyOf(Skin skin) => '${skin.slot.name}/${skin.id}';

  StoreState copyWith({
    StoreTab? tab,
    SkinSelection? selection,
    SkinSelection? preview,
    Set<String>? owned,
    int? coins,
    Map<String, String>? prices,
    String? busy,
    bool clearBusy = false,
    StoreNotice? notice,
    bool clearNotice = false,
  }) => StoreState(
    tab: tab ?? this.tab,
    selection: selection ?? this.selection,
    preview: preview ?? this.preview,
    owned: owned ?? this.owned,
    coins: coins ?? this.coins,
    prices: prices ?? this.prices,
    busy: clearBusy ? null : (busy ?? this.busy),
    notice: clearNotice ? null : (notice ?? this.notice),
  );

  @override
  List<Object?> get props => [
    tab,
    selection,
    preview,
    owned,
    coins,
    prices,
    busy,
    notice,
  ];
}
