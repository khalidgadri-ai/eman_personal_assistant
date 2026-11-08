import 'package:eman_life_app/core/services/free_quota_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';

// كل الاختبارات تمرّر الوقت بنفسها: لا DateTime.now() حقيقي، فلا تفشل عند تغيّر الشهر.
void main() {
  const feature = FreeQuotaService.coachFollowUp;
  final november = DateTime(2026, 11, 6, 9, 30);
  final december = DateTime(2026, 12, 2);
  final january = DateTime(2027, 1, 1);

  group('pure calculation', () {
    test('the monthly limit of the coach follow-up is 5', () {
      expect(FreeQuotaService.coachFollowUpMonthlyLimit, 5);
      expect(FreeQuotaService.limitOf(feature), 5);
    });

    test('a feature without a free allowance has a limit of zero', () {
      expect(FreeQuotaService.limitOf('some_future_feature'), 0);
      expect(FreeQuotaService.remainingFor(null, 'some_future_feature', november), 0);
    });

    test('periodKey is the calendar month as yyyy-MM', () {
      expect(FreeQuotaService.periodKey(DateTime(2026, 11, 30, 23, 59)), '2026-11');
      expect(FreeQuotaService.periodKey(DateTime(2027, 1, 1)), '2027-01');
      expect(FreeQuotaService.periodKey(DateTime(999, 3, 1)), '0999-03');
    });

    test('renewsOn is the first day of the next month, including December to January', () {
      expect(FreeQuotaService.renewsOn(DateTime(2026, 11, 6)), DateTime(2026, 12, 1));
      expect(FreeQuotaService.renewsOn(DateTime(2026, 12, 31, 23, 59)), DateTime(2027, 1, 1));
      expect(FreeQuotaService.renewsOn(DateTime(2027, 1, 31)), DateTime(2027, 2, 1));
      expect(FreeQuotaService.renewsOn(DateTime(2028, 2, 29)), DateTime(2028, 3, 1));
    });

    test('nothing stored yet means the whole allowance is left', () {
      expect(FreeQuotaService.remainingFor(null, feature, november), 5);
    });

    test('consuming counts one use and never goes past the limit', () {
      Object? stored;
      for (var i = 1; i <= 5; i++) {
        stored = FreeQuotaService.consumedValue(stored, feature, november);
        expect(FreeQuotaService.remainingFor(stored, feature, november), 5 - i);
      }
      stored = FreeQuotaService.consumedValue(stored, feature, november);
      expect(FreeQuotaService.remainingFor(stored, feature, november), 0);
      expect((stored as Map)['used'], 5);
    });

    test('usage from an earlier month does not carry over', () {
      final full = {'period': '2026-11', 'used': 5};

      expect(FreeQuotaService.remainingFor(full, feature, november), 0);
      expect(FreeQuotaService.remainingFor(full, feature, december), 5);
      expect(
        FreeQuotaService.remainingFor({'period': '2026-12', 'used': 5}, feature, january),
        5,
        reason: 'December rolls over to January of the next year',
      );
    });

    test('consuming in a new month starts again from one', () {
      final next = FreeQuotaService.consumedValue({'period': '2026-11', 'used': 5}, feature, december);

      expect(next, {'period': '2026-12', 'used': 1});
    });

    test('corrupt values read as no free use left, and never crash', () {
      const corrupt = <String, Object?>{
        'a string instead of a map': 'oops',
        'a number instead of a map': 7,
        'a list instead of a map': [1, 2],
        'an empty map': <String, Object?>{},
        'a string count': {'period': '2026-11', 'used': '3'},
        'a decimal count': {'period': '2026-11', 'used': 2.5},
        'a negative count': {'period': '2026-11', 'used': -1},
        'a count above the limit': {'period': '2026-11', 'used': 6},
        'no count': {'period': '2026-11'},
        'a null count': {'period': '2026-11', 'used': null},
        'a number as the period': {'period': 202611, 'used': 1},
        'a period that is not yyyy-MM': {'period': 'november', 'used': 1},
        'a month 13': {'period': '2026-13', 'used': 1},
      };

      corrupt.forEach((why, raw) {
        expect(FreeQuotaService.remainingFor(raw, feature, november), 0, reason: why);
        expect(
          FreeQuotaService.remainingFor(FreeQuotaService.consumedValue(raw, feature, november), feature, november),
          0,
          reason: '$why: consuming does not revive it',
        );
      });
    });
  });

  group('stored in Hive', () {
    late TestStorage storage;
    late FreeQuotaService quota;

    setUp(() async {
      storage = TestStorage.create();
      quota = await FreeQuotaService.getInstance();
    });
    tearDown(() => storage.dispose());

    test('a fresh install starts with 5', () {
      expect(quota.remaining(feature, november), 5);
    });

    test('each consume takes one, down to zero and no further', () async {
      await quota.consume(feature, november);
      expect(quota.remaining(feature, november), 4);

      for (var i = 0; i < 10; i++) {
        await quota.consume(feature, november);
      }
      expect(quota.remaining(feature, november), 0);
      expect(Hive.box('subscription').get('free_quota_$feature')['used'], 5);
    });

    test('the allowance comes back in the next month, and across New Year', () async {
      for (var i = 0; i < 5; i++) {
        await quota.consume(feature, november);
      }
      expect(quota.remaining(feature, november), 0);
      expect(quota.remaining(feature, december), 5);

      await quota.consume(feature, december);
      expect(quota.remaining(feature, december), 4);
      expect(quota.remaining(feature, january), 5);
    });

    test('the count survives an app restart', () async {
      await quota.consume(feature, november);
      await quota.consume(feature, november);

      FreeQuotaService.resetForTesting();
      final reopened = await FreeQuotaService.getInstance();

      expect(reopened.remaining(feature, november), 3);
    });

    test('a corrupt stored value reads as used up, without throwing', () async {
      final box = Hive.box('subscription');
      for (final bad in <Object?>['oops', 42, {'period': '2026-11', 'used': -3}, {'period': '2026-11', 'used': 99}]) {
        await box.put('free_quota_$feature', bad);
        expect(quota.remaining(feature, november), 0, reason: '$bad');
      }
    });

    test('healCorrupt turns a corrupt value into "used up this month", valid again next month', () async {
      final box = Hive.box('subscription');
      await box.put('free_quota_$feature', 'oops');

      await quota.healCorrupt(november);

      expect(box.get('free_quota_$feature'), {'period': '2026-11', 'used': 5});
      expect(quota.remaining(feature, november), 0);
      expect(quota.remaining(feature, december), 5);
    });

    test('healCorrupt leaves valid values and a never-used feature alone', () async {
      final box = Hive.box('subscription');
      await quota.healCorrupt(november);
      expect(box.containsKey('free_quota_$feature'), isFalse);

      await quota.consume(feature, november);
      await quota.healCorrupt(november);
      await quota.healCorrupt(december);

      expect(box.get('free_quota_$feature'), {'period': '2026-11', 'used': 1});
    });

    test('opening the service repairs a corrupt value left by an earlier run', () async {
      await Hive.box('subscription').put('free_quota_$feature', 'oops');

      FreeQuotaService.resetForTesting();
      await FreeQuotaService.getInstance();

      final repaired = Hive.box('subscription').get('free_quota_$feature') as Map;
      expect(repaired['used'], 5);
      expect(repaired['period'], matches(RegExp(r'^\d{4}-\d{2}$')));
    });

    test('the count lives next to the subscription cache without touching it', () async {
      final box = Hive.box('subscription');
      await box.put('status', {'active': true});

      await quota.consume(feature, november);

      expect(box.get('status'), {'active': true});
    });
  });
}
