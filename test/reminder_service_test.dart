import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/notification_service.dart';
import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/health_and_fitness/models/health_entry.dart';
import 'package:eman_life_app/features/reminders/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

class _FakeGateway implements ReminderGateway {
  int cancels = 0;
  int permissionAsks = 0;
  bool permissionGranted = true;
  final List<(PlannedReminder, DateTime)> scheduled = [];

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled.clear();
  }

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return permissionGranted;
  }

  @override
  Future<void> schedule(PlannedReminder reminder, DateTime firstFire) async {
    scheduled.add((reminder, firstFire));
  }
}

void main() {
  group('ReminderPlanner', () {
    const med = Medication(id: '3', name: 'فيتامين د', time: 'صباحًا', reminder: '08:30', takenToday: false);
    const beauty = BeautyItem(id: '4', item: 'مرطب', time: 'مساءً', step: '', reminder: '21:00');

    test('every item with a valid time becomes one reminder, with its own title and body', () {
      final plan = ReminderPlanner.plan(
        medications: [med, const Medication(id: '5', name: 'بلا تذكير', time: '', takenToday: false)],
        beauty: [beauty],
        tasks: [
          {'id': 'abc', 'title': 'شراء خبز', 'done': false, 'reminder': '17:15'},
          {'id': 'def', 'title': 'بلا تذكير', 'done': false, 'reminder': ''},
        ],
      );

      expect(plan, hasLength(3));
      final byBody = {for (final r in plan) r.body: r};
      expect(byBody['فيتامين د']!.title, ReminderPlanner.medicationTitle);
      expect(byBody['فيتامين د']!.repeatsDaily, isTrue);
      expect((byBody['فيتامين د']!.hour, byBody['فيتامين د']!.minute), (8, 30));
      expect(byBody['مرطب']!.title, ReminderPlanner.routineTitle);
      expect(byBody['مرطب']!.repeatsDaily, isTrue);
      expect(byBody['شراء خبز']!.title, ReminderPlanner.taskTitle);
      expect(byBody['شراء خبز']!.repeatsDaily, isFalse, reason: 'a task reminder fires once');
    });

    test('a finished task is not reminded, and a task without an id cannot be', () {
      final plan = ReminderPlanner.plan(
        medications: const [],
        beauty: const [],
        tasks: [
          {'id': 'a', 'title': 'منجزة', 'done': true, 'reminder': '10:00'},
          {'title': 'بلا معرّف', 'done': false, 'reminder': '10:00'},
        ],
      );

      expect(plan, isEmpty);
    });

    test('malformed times are ignored instead of crashing', () {
      final plan = ReminderPlanner.plan(
        medications: [
          for (final bad in ['25:00', '12:60', '9:5', 'صباحًا', '', '12-30'])
            Medication(id: bad.hashCode.toString(), name: 'x', time: '', reminder: bad, takenToday: false),
        ],
        beauty: const [],
        tasks: const [],
      );

      expect(plan, isEmpty);
    });

    test('notification ids are stable, positive, 31-bit, and differ by kind and id', () {
      final a = ReminderPlanner.stableId('med', '3');

      expect(ReminderPlanner.stableId('med', '3'), a, reason: 'the same input always gives the same id');
      expect(a, inInclusiveRange(0, 0x7FFFFFFF));
      expect(ReminderPlanner.stableId('beauty', '3'), isNot(a));
      expect(ReminderPlanner.stableId('med', '4'), isNot(a));
    });

    test('the id of a known input is pinned, so it never silently changes between releases', () {
      // FNV-1a على "kind:id". لو تغيّرت هذه القيم فالتذكيرات المجدولة سابقًا لن تُلغى ولن تُستبدل.
      expect(ReminderPlanner.stableId('med', '3'), 1058587646);
      expect(ReminderPlanner.stableId('task', 'x1y2'), 1177735658);
      expect(ReminderPlanner.stableId('beauty', '3'), 1963227558);
    });
  });

  group('PlannedReminder.nextFire', () {
    PlannedReminder at(int h, int m) =>
        PlannedReminder(id: 1, title: '', body: '', hour: h, minute: m, repeatsDaily: true);

    test('is today when the time has not come yet', () {
      expect(at(9, 0).nextFire(DateTime(2026, 10, 17, 8, 59)), DateTime(2026, 10, 17, 9, 0));
    });

    test('is tomorrow when the time has passed or is exactly now', () {
      expect(at(9, 0).nextFire(DateTime(2026, 10, 17, 9, 1)), DateTime(2026, 10, 18, 9, 0));
      expect(at(9, 0).nextFire(DateTime(2026, 10, 17, 9, 0)), DateTime(2026, 10, 18, 9, 0));
    });

    test('rolls over month and year ends', () {
      expect(at(7, 0).nextFire(DateTime(2026, 12, 31, 23, 0)), DateTime(2027, 1, 1, 7, 0));
      expect(at(7, 0).nextFire(DateTime(2026, 2, 28, 23, 0)), DateTime(2026, 3, 1, 7, 0));
    });
  });

  group('ReminderService.syncAll', () {
    late TestStorage storage;
    late _FakeGateway gateway;

    setUp(() {
      storage = TestStorage.create();
      gateway = _FakeGateway();
      ReminderService.gatewayOverride = gateway;
    });
    tearDown(() async {
      ReminderService.gatewayOverride = null;
      await storage.dispose();
    });

    Future<HealthService> health() => HealthService.getInstance();

    test('schedules every reminder from the saved data, replacing the old ones', () async {
      final h = await health();
      await h.addMedication(name: 'دواء', reminder: '08:00');
      await h.addBeautyItem(item: 'مرطب', reminder: '21:00');
      await (await DatabaseService.getInstance()).saveDailyTasks([
        {'id': 't1', 'title': 'مهمة', 'done': false, 'reminder': '17:00'},
      ]);

      final count = await ReminderService.syncAll();
      final again = await ReminderService.syncAll();

      expect(count, 3);
      expect(again, 3);
      expect(gateway.cancels, 2, reason: 'each sync clears first, so nothing is ever scheduled twice');
      expect(gateway.scheduled, hasLength(3));
      expect(gateway.scheduled.every((s) => s.$2.isAfter(DateTime.now().subtract(const Duration(seconds: 5)))), isTrue);
    });

    test('with no reminders it cancels what was there and schedules nothing', () async {
      final h = await health();
      await h.addMedication(name: 'بلا تذكير');

      expect(await ReminderService.syncAll(), 0);
      expect(gateway.cancels, 1);
      expect(gateway.scheduled, isEmpty);
    });

    test('deleting the medication removes its reminder', () async {
      final h = await health();
      await h.addMedication(name: 'دواء', reminder: '08:00');
      await ReminderService.syncAll();
      expect(gateway.scheduled, hasLength(1));

      await h.delete(h.medications().single.id);
      await ReminderService.syncAll();

      expect(gateway.scheduled, isEmpty);
    });

    test('notification permission is asked only when the user just set a reminder, and only if there is one', () async {
      final h = await health();
      await ReminderService.syncAll(askPermission: true);
      expect(gateway.permissionAsks, 0, reason: 'nothing to remind of, so no question');

      await h.addMedication(name: 'دواء', reminder: '08:00');
      await ReminderService.syncAll();
      expect(gateway.permissionAsks, 0, reason: 'a silent sync at startup never asks');

      await ReminderService.syncAll(askPermission: true);
      expect(gateway.permissionAsks, 1);
    });

    test('cancelAll (used by "erase everything") clears the schedule', () async {
      final h = await health();
      await h.addMedication(name: 'دواء', reminder: '08:00');
      await ReminderService.syncAll();

      await ReminderService.cancelAll();

      expect(gateway.scheduled, isEmpty);
    });

    test('a failing system never breaks the app', () async {
      ReminderService.gatewayOverride = _ThrowingGateway();
      final h = await health();
      await h.addMedication(name: 'دواء', reminder: '08:00');

      expect(await ReminderService.syncAll(askPermission: true), 0);
      await ReminderService.cancelAll();
    });
  });

  group('device time zone', () {
    test('the schedule uses the device offset right now, with no zone database', () {
      final now = DateTime.now();

      final location = NotificationService.locationFor(now);

      expect(location.currentTimeZone.offset, now.timeZoneOffset);
    });
  });
}

class _ThrowingGateway implements ReminderGateway {
  @override
  Future<void> cancelAll() async => throw StateError('boom');

  @override
  Future<bool> requestPermission() async => throw StateError('boom');

  @override
  Future<void> schedule(PlannedReminder reminder, DateTime firstFire) async => throw StateError('boom');
}
