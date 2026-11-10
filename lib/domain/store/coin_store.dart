import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/store/coin_pack.dart';
import 'package:flutter/foundation.dart';

/// Coin paketi satın almanın sonucu ve bu sırada yüklenen coin.
typedef CoinPurchaseOutcome = ({PurchaseResult result, int credited});

/// Coin paketleri: store satın alımı RevenueCat'te, coin yüklemesi sunucuda.
class CoinStore {
  CoinStore(this._purchases, this._player);

  final PurchaseRepository _purchases;
  final PlayerRepository _player;

  int get balance => _player.progress.coins;

  Future<Map<String, String>> prices() async {
    try {
      return await _purchases.fetchPrices(
        CoinPacks.productIds,
        mockPrices: {for (final p in CoinPacks.all) p.productId: p.mockPrice},
      );
    } on Object catch (e) {
      debugPrint('CoinStore.prices: $e');
      return const {};
    }
  }

  Future<CoinPurchaseOutcome> buy(CoinPack pack) async {
    // Anahtarsız (geliştirme) + sunucuya bağlı: coin'i yalnız sunucu
    // yükleyebilir, sahte başarı gösterilmez.
    if (!_purchases.isEnabled && _player.isRemote) {
      debugPrint('CoinStore: RevenueCat anahtarı yok (dart-define)');
      return (result: const PurchaseFailed(PurchaseError.store), credited: 0);
    }
    final result = await _purchases.buy(pack.productId);
    if (result is! PurchaseCompleted) return (result: result, credited: 0);
    if (!_purchases.isEnabled) {
      await _player.creditOfflinePurchase(pack.coins);
      return (result: result, credited: pack.coins);
    }
    return (result: result, credited: await _syncQuietly());
  }

  /// Geri yüklemede sunucuda yüklenmemiş coin işlemi varsa yüklenir.
  Future<int> sync() => _syncQuietly();

  /// Store'da tamamlanan satın almada sunucu senkronu başarısız olsa da
  /// hata gösterilmez: webhook coin'i yine yükler.
  Future<int> _syncQuietly() async {
    try {
      return await _player.syncPurchases();
    } on Object catch (e) {
      debugPrint('CoinStore.sync: $e');
      return 0;
    }
  }
}
