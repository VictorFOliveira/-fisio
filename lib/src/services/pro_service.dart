import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProService extends ChangeNotifier {
  ProService._();
  static final instance = ProService._();
  static const productId = 'mais_fisio_pro_lifetime';
  static const _storage = FlutterSecureStorage();
  static const _entitlementKey = 'mais_fisio_pro_entitled_v1';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? product;
  bool available = false;
  bool loading = true;
  bool isPro = false;
  String? error;

  Future<void> initialize() async {
    isPro = (await _storage.read(key: _entitlementKey)) == 'true';
    _subscription ??= _iap.purchaseStream.listen(_onPurchases, onError: (Object e) {
      error = 'Não foi possível consultar as compras.';
      notifyListeners();
    });
    try {
      available = await _iap.isAvailable();
      if (available) {
        final response = await _iap.queryProductDetails({productId});
        if (response.productDetails.isNotEmpty) product = response.productDetails.first;
        if (response.error != null) error = response.error!.message;
      }
    } catch (_) {
      error = 'Google Play Billing indisponível neste aparelho.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> buy() async {
    final item = product;
    if (item == null) {
      error = 'Produto PRO ainda não configurado na Google Play.';
      notifyListeners();
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: item));
  }

  Future<void> restore() async {
    if (!available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // Para o MVP offline, a Play Store é a fonte da compra. Antes da produção,
        // adicionar validação de recibo/servidor para reduzir fraude.
        isPro = true;
        await _storage.write(key: _entitlementKey, value: 'true');
      } else if (purchase.status == PurchaseStatus.error) {
        error = purchase.error?.message ?? 'Falha ao concluir a compra.';
      }
      if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
    }
    notifyListeners();
  }

  Future<void> clearLocalEntitlementForTesting() async {
    await _storage.delete(key: _entitlementKey);
    isPro = false;
    notifyListeners();
  }

  @override void dispose() { _subscription?.cancel(); super.dispose(); }
}
