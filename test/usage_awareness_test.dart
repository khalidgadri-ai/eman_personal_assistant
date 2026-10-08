import 'dart:io';

import 'package:eman_life_app/features/awareness/models/social_app.dart';
import 'package:eman_life_app/features/awareness/usage_service.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/coach_signal_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:eman_life_app/features/coach/models/coach_signals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _instagram = 'com.instagram.android';
const _whatsapp = 'com.whatsapp';

void main() {
  final midnight = DateTime(2026, 10, 4);
  DateTime at(int hour, [int minute = 0]) => midnight.add(Duration(hours: hour, minutes: minute));
  UsageEventRecord event(String package, int type, DateTime time) => UsageEventRecord(package, type, time);
  Map<String, int> minutesById(List<SocialAppUsage> usage) => {for (final u in usage) u.app.id: u.minutes};

  group('foregroundTimeByPackage', () {
    test('adds up separate sessions of the same app', () {
      final result = foregroundTimeByPackage([
        event(_instagram, UsageEventType.resumed, at(9)),
        event(_instagram, UsageEventType.paused, at(9, 20)),
        event(_instagram, UsageEventType.resumed, at(13)),
        event(_instagram, UsageEventType.paused, at(13, 15)),
      ], midnight, at(23));

      expect(result[_instagram], const Duration(minutes: 35));
    });

    test('an app open at midnight counts from midnight, not from yesterday', () {
      final result = foregroundTimeByPackage([
        event(_whatsapp, UsageEventType.resumed, midnight.subtract(const Duration(minutes: 40))),
        event(_whatsapp, UsageEventType.paused, at(0, 25)),
      ], midnight, at(23));

      expect(result[_whatsapp], const Duration(minutes: 25));
    });

    test('an app still open right now counts until now', () {
      final result = foregroundTimeByPackage([
        event(_instagram, UsageEventType.resumed, at(22, 30)),
      ], midnight, at(23));

      expect(result[_instagram], const Duration(minutes: 30));
    });

    test('turning the screen off ends the session', () {
      final result = foregroundTimeByPackage([
        event(_whatsapp, UsageEventType.resumed, at(10)),
        event('android', UsageEventType.screenOff, at(10, 12)),
        event(_whatsapp, UsageEventType.paused, at(10, 40)),
      ], midnight, at(23));

      expect(result[_whatsapp], const Duration(minutes: 12));
    });

    test('moving between screens inside one app is one continuous session', () {
      final result = foregroundTimeByPackage([
        event(_instagram, UsageEventType.resumed, at(8)),
        event(_instagram, UsageEventType.resumed, at(8, 5)),
        event(_instagram, UsageEventType.paused, at(8, 10)),
      ], midnight, at(23));

      expect(result[_instagram], const Duration(minutes: 10));
    });
  });

  group('socialUsageFrom', () {
    test('keeps only the five social apps, merging the two TikTok packages', () {
      final usage = socialUsageFrom({
        'com.zhiliaoapp.musically': const Duration(minutes: 30),
        'com.ss.android.ugc.trill': const Duration(minutes: 10),
        _whatsapp: const Duration(minutes: 45, seconds: 50),
        'com.mybank.app': const Duration(hours: 2),
      });

      expect(minutesById(usage), {'whatsapp': 45, 'instagram': 0, 'x': 0, 'tiktok': 40, 'snapchat': 0});
      expect(totalMinutes(usage), 85);
    });
  });

  group('stored daily usage and the coach signal', () {
    late Directory hiveDir;
    late UsageService service;
    final now = at(21);
    final signals = CoachSignalService(now: () => now);

    setUp(() async {
      hiveDir = Directory.systemTemp.createTempSync('usage_awareness_test');
      Hive.init(hiveDir.path);
      UsageService.resetForTesting();
      service = await UsageService.getInstance();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      UsageService.resetForTesting();
      hiveDir.deleteSync(recursive: true);
    });

    Future<void> saveToday(Map<String, int> minutes, {DateTime? day}) {
      return service.saveSnapshot(day ?? midnight, [
        for (final app in socialApps) SocialAppUsage(app, minutes[app.id] ?? 0),
      ]);
    }

    test('off Android there is no permission, and nothing is read live', () async {
      expect(UsageService.isSupported, isFalse);
      expect(await service.hasPermission(), isFalse);
    });

    test("returns today's saved minutes when live data is unavailable", () async {
      await saveToday({'instagram': 50, 'tiktok': 20});

      expect(minutesById(await service.getDailyUsageByApp(now: now)), {
        'whatsapp': 0,
        'instagram': 50,
        'x': 0,
        'tiktok': 20,
        'snapchat': 0,
      });
    });

    test("yesterday's numbers are never shown as today", () async {
      await saveToday({'instagram': 90}, day: midnight.subtract(const Duration(days: 1)));

      expect(totalMinutes(await service.getDailyUsageByApp(now: now)), 0);
    });

    test('signal active: more than two hours across social apps today', () async {
      await saveToday({'whatsapp': 70, 'instagram': 40, 'snapchat': 15});

      expect(await signals.getUsageSignal(), isTrue);
    });

    test('signal inactive: exactly two hours has not exceeded the threshold', () async {
      await saveToday({'whatsapp': 60, 'tiktok': 60});

      expect(await signals.getUsageSignal(), isFalse);
    });

    test('signal inactive: no usage data at all', () async {
      expect(await signals.getUsageSignal(), isFalse);
    });
  });

  group('coach weighting for the usage signal', () {
    test('boosts only the organization and balance domain', () {
      final weights = CoachSessionService.domainWeights(const CoachSignals(usage: true));

      expect(weights[CoachDomain.organization], 1 + CoachSessionService.signalBoost);
      expect(
        weights.entries.where((e) => e.key != CoachDomain.organization).map((e) => e.value).toSet(),
        {1},
      );
    });

    test('the hint is neutral and only shows on the organization domain', () {
      const active = CoachSignals(usage: true);

      expect(active.hintFor(CoachDomain.organization), 'هذا السؤال مرتبط بتوزيع وقتك اليوم');
      expect(active.hintFor(CoachDomain.emotions), isNull);
    });
  });
}
