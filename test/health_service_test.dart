import 'dart:convert';
import 'dart:io';

import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';

void main() {
  late TestStorage storage;
  late HealthService health;

  setUp(() async {
    storage = TestStorage.create();
    health = await HealthService.getInstance();
  });
  tearDown(() => storage.dispose());

  test('a fresh install has no medications and no routine items', () {
    expect(health.medications(), isEmpty);
    expect(health.beautyItems(), isEmpty);
  });

  group('medications', () {
    test('are listed in the order they were added, trimmed', () async {
      await health.addMedication(name: '  فيتامين   د ', time: ' 09:00 صباحاً ');
      await health.addMedication(name: 'مكمل آخر');

      final meds = health.medications();

      expect(meds.map((m) => m.name), ['فيتامين د', 'مكمل آخر']);
      expect(meds.first.time, '09:00 صباحاً');
      expect(meds.last.time, '');
    });

    test('a blank name is ignored', () async {
      await health.addMedication(name: '   ');

      expect(health.medications(), isEmpty);
    });

    test('"taken" is only true for the day it was ticked and resets the next day', () async {
      await health.addMedication(name: 'مكمل');
      final id = health.medications().single.id;
      final today = DateTime(2026, 10, 16, 9);

      await health.setMedicationTaken(id, true, now: today);

      expect(health.medications(now: today).single.takenToday, isTrue);
      expect(health.medications(now: DateTime(2026, 10, 16, 23, 59)).single.takenToday, isTrue);
      expect(health.medications(now: DateTime(2026, 10, 17, 0, 1)).single.takenToday, isFalse);

      await health.setMedicationTaken(id, false, now: today);
      expect(health.medications(now: today).single.takenToday, isFalse);
    });

    test('delete removes only that entry and survives a bogus id', () async {
      await health.addMedication(name: 'أ');
      await health.addMedication(name: 'ب');
      final firstId = health.medications().first.id;

      await health.delete(firstId);
      await health.delete('not-a-number');
      await health.delete('999');

      expect(health.medications().map((m) => m.name), ['ب']);
    });

    test('an over-long name is cut without breaking an emoji', () async {
      await health.addMedication(name: '😀' * 500);

      final name = health.medications().single.name;
      expect(name.runes.length, HealthService.maxTextLength);
    });
  });

  group('routine items', () {
    test('keep their time and steps, separately from medications', () async {
      await health.addMedication(name: 'دواء');
      await health.addBeautyItem(item: 'مرطب', time: 'مساءً', step: 'قبل النوم');

      final items = health.beautyItems();

      expect(items, hasLength(1));
      expect(items.single.item, 'مرطب');
      expect(items.single.time, 'مساءً');
      expect(items.single.step, 'قبل النوم');
      expect(health.medications(), hasLength(1));
    });

    test('a blank item is ignored', () async {
      await health.addBeautyItem(item: '  ');

      expect(health.beautyItems(), isEmpty);
    });
  });

  test('data survives a restart and is unreadable on disk', () async {
    const secret = 'دواء_سري_للاختبار';
    await health.addMedication(name: secret);
    await Hive.close();
    HealthService.resetForTesting();

    final raw = latin1.decode(File('${storage.directory!.path}/health_enc.hive').readAsBytesSync());
    expect(raw.contains(latin1.decode(utf8.encode(secret))), isFalse);

    // نفس المفتاح في التخزين الآمن، فيُفتح الصندوق من جديد بنفس البيانات.
    final reopened = await HealthService.getInstance();
    expect(reopened.medications().single.name, secret);
  });
}
