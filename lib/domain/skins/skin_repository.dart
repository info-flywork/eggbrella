import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:flutter/foundation.dart';

/// Skin sahipliği ve seçimi. Seçim cihazda; sahiplik RevenueCat'ten gelir
/// ve çevrimdışı açılış için önbelleğe yazılır. Seçim değişince dinleyenler
/// (Yumi görselleri, oyun sprite'ları) haber alır.
class SkinRepository extends ChangeNotifier {
  SkinRepository(this._prefs, this._purchases)
    : _owned = _prefs.ownedProducts.toSet(),
      _selection = SkinSelection(
        egg: SkinCatalog.find(SkinSlot.egg, _prefs.eggSkin),
        umbrella: SkinCatalog.find(SkinSlot.umbrella, _prefs.umbrellaSkin),
      ) {
    _dropUnowned();
  }

  final SharedPrefManager _prefs;
  final PurchaseRepository _purchases;
  Set<String> _owned;
  SkinSelection _selection;

  SkinSelection get selection => _selection;

  bool isOwned(Skin skin) => skin.isFree || _owned.contains(skin.productId);

  /// Mağaza fiyatları (ürün id -> fiyat). Hata olursa boş.
  Future<Map<String, String>> prices() async {
    try {
      return await _purchases.fetchPrices(SkinCatalog.productIds);
    } on Object catch (e) {
      debugPrint('SkinRepository.prices: $e');
      return const {};
    }
  }

  /// RevenueCat'ten sahipliği tazeler (açılışta).
  Future<void> refresh() async {
    try {
      final owned = await _purchases.ownedProductIds();
      if (owned.isNotEmpty || _purchases.isEnabled) await _setOwned(owned);
    } on Object catch (e) {
      debugPrint('SkinRepository.refresh: $e');
    }
  }

  Future<void> equip(Skin skin) async {
    if (!isOwned(skin) || _selection.of(skin.slot) == skin) return;
    _selection = _selection.withSkin(skin);
    await switch (skin.slot) {
      SkinSlot.egg => _prefs.setEggSkin(skin.id),
      SkinSlot.umbrella => _prefs.setUmbrellaSkin(skin.id),
    };
    notifyListeners();
  }

  /// Satın alır; başarılıysa skin hemen giyilir.
  Future<PurchaseResult> buy(Skin skin) async {
    final productId = skin.productId;
    if (productId == null) return const PurchaseCompleted();
    final result = await _purchases.buy(productId);
    if (result is PurchaseCompleted) {
      await _setOwned({..._owned, productId});
      await equip(skin);
    }
    return result;
  }

  /// Satın alımları geri yükler; yeni gelen skin sayısını döner.
  Future<int> restore() async {
    final before = _owned.length;
    final owned = await _purchases.restore();
    await _setOwned({..._owned, ...owned});
    return _owned.length - before;
  }

  Future<void> _setOwned(Set<String> owned) async {
    _owned = owned;
    await _prefs.setOwnedProducts(owned.toList());
    if (_dropUnowned()) {
      await _prefs.setEggSkin(_selection.egg.id);
      await _prefs.setUmbrellaSkin(_selection.umbrella.id);
    }
    notifyListeners();
  }

  /// Sahip olunmayan (iade edilmiş) skin seçiliyse klasiğe döner.
  bool _dropUnowned() {
    var next = _selection;
    if (!isOwned(next.egg)) next = next.withSkin(SkinCatalog.classicEgg);
    if (!isOwned(next.umbrella)) {
      next = next.withSkin(SkinCatalog.classicUmbrella);
    }
    final changed = next != _selection;
    _selection = next;
    return changed;
  }
}
