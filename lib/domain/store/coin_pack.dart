import 'package:equatable/equatable.dart';

/// Coin paketi (consumable). Coin'i sunucu yükler (`/purchases/sync` +
/// RevenueCat webhook); ürün kimlikleri backend `config/catalog.js` ile aynı.
final class CoinPack extends Equatable {
  const CoinPack({
    required this.id,
    required this.coins,
    required this.productId,
    this.mockPrice = r'$0.99',
    this.badge,
  });

  final String id;
  final int coins;
  final String productId;

  /// RevenueCat anahtarı yokken (geliştirme) gösterilen fiyat.
  final String mockPrice;

  /// Kart üstü etiket çeviri anahtarı (en popüler / en avantajlı).
  final String? badge;

  @override
  List<Object?> get props => [id];
}

abstract final class CoinPacks {
  static const all = [
    CoinPack(
      id: 'coins_300',
      coins: 300,
      productId: 'com.flywork.eggbrella.coins_300',
    ),
    CoinPack(
      id: 'coins_800',
      coins: 800,
      productId: 'com.flywork.eggbrella.coins_800',
      mockPrice: r'$1.99',
      badge: 'store.badge_popular',
    ),
    CoinPack(
      id: 'coins_2000',
      coins: 2000,
      productId: 'com.flywork.eggbrella.coins_2000',
      mockPrice: r'$3.99',
      badge: 'store.badge_best',
    ),
  ];

  static List<String> get productIds => [for (final p in all) p.productId];
}
