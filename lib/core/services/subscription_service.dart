import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SubscriptionStatus {
  final bool active;
  final DateTime lastVerified;

  const SubscriptionStatus({required this.active, required this.lastVerified});

  /// الحالة المحفوظة تُعتمد بدون اتصال لمدة [SubscriptionService.offlineGrace] فقط.
  bool isActiveAt(DateTime now) =>
      active && now.difference(lastVerified) <= SubscriptionService.offlineGrace;

  factory SubscriptionStatus.fromMap(Map map) => SubscriptionStatus(
        active: map['active'] as bool,
        lastVerified: map['lastVerified'] as DateTime,
      );

  Map<String, dynamic> toMap() => {'active': active, 'lastVerified': lastVerified};
}

/// اشتراك "سؤال المتابعة الذكي" عبر Google Play Billing.
/// التحقق يتم على الجهاز فقط (لا يوجد خادم)، والمرجع دائمًا هو ما يرجّعه Google Play.
class SubscriptionService {
  static const String productId = 'eman_coach_monthly';
  static const Duration offlineGrace = Duration(days: 3);
  static const Duration recheckAfter = Duration(hours: 12);
  static const Duration _restoreTimeout = Duration(seconds: 15);
  static const String _boxName = 'subscription';
  static const String _statusKey = 'status';

  static Future<SubscriptionService>? _instance;

  final Box _box;
  final InAppPurchase? _store;
  final StreamController<PurchaseStatus> _events = StreamController.broadcast();
  Completer<void>? _pendingRestore;
  ProductDetails? _product;

  SubscriptionService._(this._box, this._store);

  static Future<SubscriptionService> getInstance() => _instance ??= _create();

  static Future<SubscriptionService> _create() async {
    final box = await Hive.openBox(_boxName);
    final store = await _playStoreIfAvailable();
    final service = SubscriptionService._(box, store);
    store?.purchaseStream.listen(service.handlePurchaseUpdates);
    return service;
  }

  static Future<InAppPurchase?> _playStoreIfAvailable() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    final store = InAppPurchase.instance;
    return await store.isAvailable() ? store : null;
  }

  @visibleForTesting
  static void resetForTesting() => _instance = null;

  /// false على غير Android أو عند تعذّر الاتصال بـ Google Play.
  bool get canPurchase => _store != null;

  /// purchased / pending / canceled / error لمنتج الاشتراك، بعد حفظ الحالة.
  Stream<PurchaseStatus> get purchaseEvents => _events.stream;

  SubscriptionStatus? get status {
    final raw = _box.get(_statusKey);
    return raw is Map ? SubscriptionStatus.fromMap(raw) : null;
  }

  bool get isActive => status?.isActiveAt(DateTime.now()) ?? false;

  /// يعيد سؤال Google Play إذا مر على آخر تحقق أكثر من [recheckAfter]، ثم يرجّع [isActive].
  Future<bool> verify() async {
    final lastVerified = status?.lastVerified;
    if (lastVerified == null || DateTime.now().difference(lastVerified) > recheckAfter) {
      await restore();
    }
    return isActive;
  }

  /// يسأل Google Play عن الاشتراكات الحالية لهذا الحساب (يشمل جهازًا جديدًا).
  /// عند تعذّر الاتصال تبقى الحالة المحفوظة كما هي.
  Future<bool> restore() async {
    final store = _store;
    if (store == null) return isActive;
    final pending = _pendingRestore = Completer<void>();
    try {
      await store.restorePurchases();
      await pending.future.timeout(_restoreTimeout);
    } catch (e) {
      debugPrint('SubscriptionService.restore: $e');
    } finally {
      _pendingRestore = null;
    }
    return isActive;
  }

  Future<ProductDetails?> loadProduct() async {
    final store = _store;
    if (store == null) return null;
    if (_product != null) return _product;
    final response = await store.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return null;
    return _product = response.productDetails.first;
  }

  /// يفتح نافذة الشراء من Google Play؛ النتيجة تصل عبر [purchaseEvents].
  Future<bool> buy(ProductDetails product) {
    return _store!.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  @visibleForTesting
  Future<void> handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final ours = purchases.where((p) => p.productID == productId).toList();

    for (final purchase in ours) {
      // Google Play يسترد أي اشتراك لا يُؤكَّد خلال 3 أيام.
      if (purchase.pendingCompletePurchase && _entitles(purchase)) {
        await _store?.completePurchase(purchase);
      }
    }

    // نتيجة restorePurchases على Android قائمة كاملة بما يملكه الحساب الآن (قد تكون فارغة).
    final isRestoreSnapshot = purchases.every((p) => p.status == PurchaseStatus.restored);
    if (isRestoreSnapshot) {
      await _saveStatus(active: ours.any(_entitles));
      final pending = _pendingRestore;
      if (pending != null && !pending.isCompleted) pending.complete();
      return;
    }

    for (final purchase in ours) {
      if (_entitles(purchase)) await _saveStatus(active: true);
      _events.add(purchase.status);
    }
  }

  static bool _entitles(PurchaseDetails purchase) {
    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return false;
    }
    // restorePurchases يعلّم كل شيء "restored" حتى لو كان الدفع ما زال معلّقًا.
    if (purchase is GooglePlayPurchaseDetails) {
      return purchase.billingClientPurchase.purchaseState == PurchaseStateWrapper.purchased;
    }
    return true;
  }

  Future<void> _saveStatus({required bool active}) {
    return _box.put(
      _statusKey,
      SubscriptionStatus(active: active, lastVerified: DateTime.now()).toMap(),
    );
  }
}
