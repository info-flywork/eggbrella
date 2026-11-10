import 'package:eggbrella/core/utils/constants/string_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Satın almanın sonucu.
sealed class PurchaseResult {
  const PurchaseResult();
}

/// Ürün alındı (ya da zaten sahipti).
final class PurchaseCompleted extends PurchaseResult {
  const PurchaseCompleted();
}

/// Kullanıcı store ekranını kapattı.
final class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

/// Ödeme onay bekliyor (Aile Paylaşımı "Satın Almak İçin Sor").
final class PurchasePending extends PurchaseResult {
  const PurchasePending();
}

/// Satın alma başarısız; [error] kullanıcıya gösterilecek nedeni seçer.
final class PurchaseFailed extends PurchaseResult {
  const PurchaseFailed(this.error);

  final PurchaseError error;
}

/// RevenueCat/store hata kodlarının kullanıcıya anlamlı gruplaması.
enum PurchaseError {
  network,
  notAllowed,
  unavailable,
  store,
  unknown;

  static PurchaseError fromCode(PurchasesErrorCode code) => switch (code) {
    PurchasesErrorCode.networkError ||
    PurchasesErrorCode.offlineConnectionError => network,
    PurchasesErrorCode.purchaseNotAllowedError ||
    PurchasesErrorCode.insufficientPermissionsError => notAllowed,
    PurchasesErrorCode.productNotAvailableForPurchaseError => unavailable,
    PurchasesErrorCode.storeProblemError ||
    PurchasesErrorCode.unexpectedBackendResponseError ||
    PurchasesErrorCode.unknownBackendError ||
    PurchasesErrorCode.operationAlreadyInProgressError => store,
    _ => unknown,
  };
}

/// Uygulama içi satın almaların tek noktası (RevenueCat, `purchases_flutter`).
///
/// Skinler non-consumable'dır; sahiplik RevenueCat müşteri bilgisinden
/// (`allPurchasedProductIdentifiers`) okunur, RevenueCat app user id'si
/// backend kullanıcı id'sidir (cihazlar arası geri yükleme). Anahtar
/// verilmemişse (simülatör / geliştirme) sahte modda çalışır.
class PurchaseRepository {
  PurchaseRepository({String? apiKey}) : _apiKey = apiKey ?? _platformKey;

  final String _apiKey;
  bool _configured = false;

  static String get _platformKey => defaultTargetPlatform == TargetPlatform.iOS
      ? StringConstants.revenueCatAppleKey
      : StringConstants.revenueCatGoogleKey;

  bool get isEnabled => _apiKey.isNotEmpty;

  /// Sahte modda gösterilen fiyat (gerçek fiyat store'dan gelir).
  static const String mockPrice = r'$0.99';

  /// RevenueCat'i [appUserId] (backend kullanıcı id'si) ile başlatır.
  Future<void> configure({String? appUserId}) async {
    if (!isEnabled) return;
    if (_configured) {
      if (appUserId != null) await Purchases.logIn(appUserId);
      return;
    }
    await Purchases.configure(
      PurchasesConfiguration(_apiKey)..appUserID = appUserId,
    );
    _configured = true;
  }

  /// Ürün id -> yerelleştirilmiş fiyat. Store'da bulunmayan ürün haritada
  /// olmaz.
  Future<Map<String, String>> fetchPrices(
    List<String> productIds, {
    Map<String, String> mockPrices = const {},
  }) async {
    if (!isEnabled) {
      return {for (final id in productIds) id: mockPrices[id] ?? mockPrice};
    }
    final products = await Purchases.getProducts(
      productIds,
      productCategory: ProductCategory.nonSubscription,
    );
    return {for (final p in products) p.identifier: p.priceString};
  }

  /// Sahip olunan ürünler (RevenueCat önbelleği; ağ yoksa son bilinen).
  Future<Set<String>> ownedProductIds() async {
    if (!isEnabled || !_configured) return const {};
    final info = await Purchases.getCustomerInfo();
    return info.allPurchasedProductIdentifiers.toSet();
  }

  Future<PurchaseResult> buy(String productId) async {
    if (!isEnabled) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return const PurchaseCompleted();
    }
    try {
      final products = await Purchases.getProducts([
        productId,
      ], productCategory: ProductCategory.nonSubscription);
      if (products.isEmpty) {
        return const PurchaseFailed(PurchaseError.unavailable);
      }
      await Purchases.purchase(PurchaseParams.storeProduct(products.first));
      return const PurchaseCompleted();
    } on PlatformException catch (e) {
      return switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError => const PurchaseCancelled(),
        PurchasesErrorCode.paymentPendingError => const PurchasePending(),
        PurchasesErrorCode.productAlreadyPurchasedError =>
          const PurchaseCompleted(),
        final code => PurchaseFailed(PurchaseError.fromCode(code)),
      };
    }
  }

  /// "Satın alımları geri yükle": store ile eşitler, sahip olunanları döner.
  Future<Set<String>> restore() async {
    if (!isEnabled) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const {};
    }
    final info = await Purchases.restorePurchases();
    return info.allPurchasedProductIdentifiers.toSet();
  }
}
