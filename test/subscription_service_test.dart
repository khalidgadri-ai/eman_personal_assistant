import 'dart:io';

import 'package:eman_life_app/core/services/subscription_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

PurchaseDetails _purchase(PurchaseStatus status, {String productId = SubscriptionService.productId}) {
  return PurchaseDetails(
    purchaseID: 'GPA.test-1',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: 'google_play',
    ),
    transactionDate: '0',
    status: status,
  );
}

void main() {
  group('SubscriptionStatus.isActiveAt', () {
    final now = DateTime(2026, 10, 20, 12);

    test('active: Play confirmed the subscription recently', () {
      final status = SubscriptionStatus(
        active: true,
        lastVerified: now.subtract(const Duration(days: 1)),
      );

      expect(status.isActiveAt(now), isTrue);
    });

    test('active offline up to the grace period, then treated as expired', () {
      final atEdge = SubscriptionStatus(
        active: true,
        lastVerified: now.subtract(SubscriptionService.offlineGrace),
      );
      final tooOld = SubscriptionStatus(
        active: true,
        lastVerified: now.subtract(SubscriptionService.offlineGrace + const Duration(minutes: 1)),
      );

      expect(atEdge.isActiveAt(now), isTrue);
      expect(tooOld.isActiveAt(now), isFalse);
    });

    test('expired: Play no longer returns the subscription', () {
      final status = SubscriptionStatus(
        active: false,
        lastVerified: now.subtract(const Duration(minutes: 1)),
      );

      expect(status.isActiveAt(now), isFalse);
    });
  });

  group('SubscriptionService', () {
    late Directory hiveDir;
    late SubscriptionService subscription;

    setUp(() async {
      hiveDir = Directory.systemTemp.createTempSync('subscription_test');
      Hive.init(hiveDir.path);
      SubscriptionService.resetForTesting();
      subscription = await SubscriptionService.getInstance();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      SubscriptionService.resetForTesting();
      hiveDir.deleteSync(recursive: true);
    });

    test('never subscribed: not active and no stored status', () {
      expect(subscription.status, isNull);
      expect(subscription.isActive, isFalse);
    });

    test('a completed purchase activates the subscription', () async {
      await subscription.handlePurchaseUpdates([_purchase(PurchaseStatus.purchased)]);

      expect(subscription.isActive, isTrue);
      expect(
        DateTime.now().difference(subscription.status!.lastVerified),
        lessThan(const Duration(minutes: 1)),
      );
    });

    test('restoring on a new device activates the subscription', () async {
      await subscription.handlePurchaseUpdates([_purchase(PurchaseStatus.restored)]);

      expect(subscription.isActive, isTrue);
    });

    test('expired: an empty restore after an earlier purchase deactivates it', () async {
      await subscription.handlePurchaseUpdates([_purchase(PurchaseStatus.purchased)]);
      await subscription.handlePurchaseUpdates([]);

      expect(subscription.isActive, isFalse);
      expect(subscription.status?.active, isFalse);
    });

    test('canceled, failed and pending purchases do not activate it', () async {
      for (final status in [PurchaseStatus.canceled, PurchaseStatus.error, PurchaseStatus.pending]) {
        await subscription.handlePurchaseUpdates([_purchase(status)]);
        expect(subscription.isActive, isFalse, reason: status.name);
      }
    });

    test('purchases of other products are ignored', () async {
      await subscription.handlePurchaseUpdates([
        _purchase(PurchaseStatus.purchased, productId: 'some_other_product'),
      ]);

      expect(subscription.isActive, isFalse);
    });

    test('the status survives an app restart', () async {
      await subscription.handlePurchaseUpdates([_purchase(PurchaseStatus.purchased)]);

      SubscriptionService.resetForTesting();
      final reopened = await SubscriptionService.getInstance();

      expect(reopened.isActive, isTrue);
    });

    test('without Google Play, restore keeps the stored status instead of failing', () async {
      await subscription.handlePurchaseUpdates([_purchase(PurchaseStatus.purchased)]);

      expect(subscription.canPurchase, isFalse);
      expect(await subscription.restore(), isTrue);
    });
  });
}
