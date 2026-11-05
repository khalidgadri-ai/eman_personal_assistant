import 'package:eman_life_app/features/reminders/reminder_service.dart';

/// بوابة تذكيرات وهمية: تسجّل ما جُدول، وتتيح محاكاة إشعارات مطفأة أو جدولة يرفضها النظام.
class FakeReminderGateway implements ReminderGateway {
  final List<PlannedReminder> scheduled = [];
  int permissionAsks = 0;
  bool? notificationsEnabled = true;
  bool accepts = true;

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return true;
  }

  @override
  Future<bool?> areNotificationsEnabled() async => notificationsEnabled;

  @override
  Future<bool> schedule(PlannedReminder reminder, DateTime firstFire) async {
    if (!accepts) return false;
    scheduled.add(reminder);
    return true;
  }
}
