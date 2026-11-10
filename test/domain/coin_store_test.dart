import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/store/coin_pack.dart';
import 'package:eggbrella/domain/store/coin_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefManager.instance.init();
  });

  test('çevrimdışı modda sahte satın alma coin yükler', () async {
    final player = PlayerRepository(SharedPrefManager.instance);
    final store = CoinStore(PurchaseRepository(apiKey: ''), player);
    final before = store.balance;
    final pack = CoinPacks.all.first;
    final outcome = await store.buy(pack);
    expect(outcome.result, isA<PurchaseCompleted>());
    expect(outcome.credited, pack.coins);
    expect(store.balance, before + pack.coins);
  });

  test('ürün kimlikleri backend kataloğuyla aynı biçimde', () {
    for (final p in CoinPacks.all) {
      expect(p.productId, 'com.flywork.eggbrella.${p.id}');
    }
  });
}
