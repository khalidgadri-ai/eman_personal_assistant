import '../../../core/app_events.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/ids.dart';

/// فئة المهمة المضافة من أدوات المدرب (معرّف عربي ثابت يُعرض بلغة التطبيق في تبويب المهام).
const String coachTaskCategory = 'شخصي';

/// يضيف الخطوة الصغيرة إلى قائمة المهام اليومية، مع تذكير اختياري [reminder] بصيغة `HH:mm`.
/// يقرأ القائمة من التخزين أولًا ثم يكتبها، ويُخبر تبويب المهام ليعيد قراءتها.
/// جدولة التذكير على المتصل (`syncRemindersWithNotice`)، لأنها قد تسأل عن إذن الإشعارات.
Future<void> addCoachStepAsTask(String step, {String reminder = ''}) async {
  final title = step.trim();
  if (title.isEmpty) return;
  final db = await DatabaseService.getInstance();
  final tasks = db.getDailyTasks()
    ..add({
      'id': newId(),
      'title': title,
      'category': coachTaskCategory,
      'done': false,
      'pinned': false,
      'reminder': reminder,
    });
  await db.saveDailyTasks(tasks);
  AppEvents.tasksChanged.value++;
}
