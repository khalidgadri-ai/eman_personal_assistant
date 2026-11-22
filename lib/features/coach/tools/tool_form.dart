import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/undo_snackbar.dart';
import '../../../l10n/l10n.dart';
import '../../reminders/reminder_notice.dart';
import '../coach_crisis_dialog.dart';
import '../coach_safety.dart';
import '../coach_session_service.dart';
import 'coach_step_task.dart';
import 'coach_tool_record.dart';

/// أجزاء مشتركة لنماذج أدوات المدرب: سؤال مع خانة إجابة، وخيار «إضافة الخطوة إلى المهام»
/// بتذكير، والحفظ (فحص الأزمة ثم السجل ثم المهمة ثم التذكير).

String hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

Future<TimeOfDay?> pickReminderTime(BuildContext context, TimeOfDay? current) =>
    showTimePicker(context: context, initialTime: current ?? const TimeOfDay(hour: 9, minute: 0));

class ToolHeader extends StatelessWidget {
  const ToolHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      );
}

/// سؤال وتحته خانة الإجابة.
class ToolQuestion extends StatelessWidget {
  const ToolQuestion({
    super.key,
    required this.question,
    required this.controller,
    required this.fieldKey,
    this.maxLength = 300,
    this.onChanged,
  });

  final String question;
  final TextEditingController controller;
  final Key fieldKey;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(color: AppTheme.textColor, height: 1.5)),
            TextField(
              key: fieldKey,
              controller: controller,
              minLines: 1,
              maxLines: 3,
              maxLength: maxLength,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: context.l10n.answerOptional,
                hintStyle: const TextStyle(color: AppTheme.subTextColor),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

/// «إضافة الخطوة إلى المهام» مع تذكير اختياري.
class StepTaskOption extends StatelessWidget {
  const StepTaskOption({
    super.key,
    required this.addTask,
    required this.reminder,
    required this.onAddTaskChanged,
    required this.onReminderChanged,
    this.label,
  });

  final bool addTask;
  final TimeOfDay? reminder;
  final ValueChanged<bool> onAddTaskChanged;
  final ValueChanged<TimeOfDay?> onReminderChanged;

  /// بدل «إضافة الخطوة إلى المهام» (تغيير العادة: تذكير يومي بلا مهمة).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final time = reminder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          key: const ValueKey('tool_add_task'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: addTask,
          onChanged: (v) => onAddTaskChanged(v ?? false),
          title: Text(label ?? l10n.stepToTask, style: const TextStyle(color: AppTheme.textColor)),
        ),
        if (addTask)
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await pickReminderTime(context, time);
                  if (picked != null) onReminderChanged(picked);
                },
                icon: const Icon(Icons.alarm_rounded),
                label: Text(time == null ? l10n.stepSetReminder : l10n.stepReminder(hhmm(time))),
              ),
              if (time != null) TextButton(onPressed: () => onReminderChanged(null), child: Text(l10n.stepNoReminder)),
            ],
          ),
      ],
    );
  }
}

/// زر الحفظ الكبير أسفل النموذج.
class ToolSaveButton extends StatelessWidget {
  const ToolSaveButton({super.key, required this.label, required this.onPressed, this.hint});

  final String label;
  final VoidCallback? onPressed;

  /// سطر صغير فوق الزر حين يكون معطّلًا (ما الذي ينقص).
  final String? hint;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onPressed == null && hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(hint!,
                  textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onPressed,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      );
}

/// يحفظ سجل أداة: فحص الأزمة على [texts] أولًا (النافذة تظهر ثم يكمل الحفظ، فلا يضيع ما كُتب)،
/// ثم السجل، ثم الخطوة مهمةً إن طُلب، ثم التذكير. يعرض رسالة ويغلق الشاشة. true إن حُفظ.
Future<bool> saveToolRecordWithStep(
  BuildContext context, {
  required CoachToolRecord record,
  required Iterable<String> texts,
  bool addTask = false,
  TimeOfDay? reminder,
}) async {
  final l10n = context.l10n;
  if (texts.any(containsCrisisSignals)) {
    await showCrisisHelpDialog(context, countryCode: deviceCountryCode());
    if (!context.mounted) return false;
  }
  final service = await CoachSessionService.getInstance();
  await service.saveToolRecord(record);
  final step = (record.step ?? '').trim();
  final withTask = addTask && step.isNotEmpty;
  if (withTask) {
    await addCoachStepAsTask(step, reminder: reminder == null ? '' : hhmm(reminder));
    if (reminder != null && context.mounted) await syncRemindersWithNotice(context, ask: true);
  }
  if (!context.mounted) return true;
  showInfoSnackBar(context, withTask ? l10n.toolSavedWithTask : l10n.toolSaved);
  Navigator.of(context).pop(true);
  return true;
}
