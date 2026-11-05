import 'package:flutter/widgets.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'reminder_service.dart';

/// يعيد جدولة التذكيرات من بيانات المستخدم الحالية. [ask] لا يكون true إلا حين ضبط المستخدم
/// تذكيرًا بنفسه: عندئذ فقط يُسأل عن إذن الإشعارات، ويُخبَر برسالة قصيرة إن كانت الإشعارات
/// مطفأة أو فشلت جدولة التذكير، بدل أن يظن أنه سيرن.
Future<void> syncRemindersWithNotice(BuildContext context, {bool ask = false}) async {
  final result = await ReminderService.sync(askPermission: ask);
  if (!ask || !result.needsAttention || !context.mounted) return;
  showInfoSnackBar(context, ReminderService.notScheduledMessage);
}
