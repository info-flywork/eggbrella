import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SkinRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefManager.instance.init();
    // Anahtarsız: sahte mod (satın alma hemen tamamlanır).
    repo = SkinRepository(
      SharedPrefManager.instance,
      PurchaseRepository(apiKey: ''),
    );
  });

  test('başlangıçta klasik skinler giyili ve yalnız onlar sahipli', () {
    expect(repo.selection, SkinSelection.classic);
    expect(repo.isOwned(SkinCatalog.classicEgg), isTrue);
    expect(repo.isOwned(SkinCatalog.eggs[1]), isFalse);
  });

  test('sahip olunmayan skin giyilemez', () async {
    await repo.equip(SkinCatalog.eggs[1]);
    expect(repo.selection.egg, SkinCatalog.classicEgg);
  });

  test('satın alınan skin sahiplenilir, giyilir ve kalıcıdır', () async {
    final golden = SkinCatalog.eggs[1];
    final result = await repo.buy(golden);
    expect(result, isA<PurchaseCompleted>());
    expect(repo.isOwned(golden), isTrue);
    expect(repo.selection.egg, golden);

    final reopened = SkinRepository(
      SharedPrefManager.instance,
      PurchaseRepository(apiKey: ''),
    );
    expect(reopened.selection.egg, golden);
    expect(reopened.isOwned(golden), isTrue);
  });

  test('her skinin her poz katmanı katalogla eşleşir', () {
    for (final skin in [...SkinCatalog.eggs, ...SkinCatalog.umbrellas]) {
      expect(skin.layerPath(YumiPose.calm), contains('/${skin.id}/'));
      expect(skin.isFree, skin.id == 'classic');
    }
  });
}
