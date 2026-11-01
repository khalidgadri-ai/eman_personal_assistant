import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_numbers.dart';
import '../../core/widgets/entry_dialog.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'exercise_edit_screen.dart';
import 'health_service.dart';
import 'image_source_sheet.dart';
import 'models/exercise.dart';
import 'workout_log_screen.dart';

/// تفاصيل تمرين محفوظ: صورته وعضلاته وخطواته ومجموعاته، وآخر ما سُجّل منه. منه: تسجيل تمرين
/// اليوم، التثبيت، التعديل، الحذف.
class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.health,
    required this.exerciseId,
    this.pickImage = pickExerciseImage,
  });

  final HealthService health;
  final String exerciseId;
  final ExerciseImagePicker pickImage;

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  Exercise? _exercise;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _exercise = widget.health.exerciseById(widget.exerciseId));
  }

  Future<void> _edit(Exercise exercise) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditScreen(health: widget.health, exercise: exercise, pickImage: widget.pickImage),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _logToday(Exercise exercise) async {
    final values = await showEntryDialog(
      context,
      title: 'تسجيل تمرين اليوم',
      confirmLabel: 'تسجيل',
      fields: [
        EntryField(
          key: 'sets',
          label: 'المجموعات',
          keyboardType: TextInputType.number,
          maxLength: 2,
          required: true,
          initial: '${exercise.sets}',
          validator: (v) {
            final n = parseInteger(v);
            return n == null || n < 1 || n > Exercise.maxSets ? 'أدخل رقمًا من 1 إلى ${Exercise.maxSets}' : null;
          },
        ),
        EntryField(
          key: 'reps',
          label: 'التكرار',
          maxLength: Exercise.maxRepsLength,
          required: true,
          initial: exercise.reps,
        ),
        const EntryField(key: 'weight', label: 'الوزن (اختياري)', hint: 'مثال: 40 كجم', maxLength: 20),
        const EntryField(key: 'note', label: 'ملاحظة (اختياري)', maxLength: 200),
      ],
    );
    if (values == null) return;
    await widget.health.logWorkout(
      exercise: exercise,
      sets: parseInteger(values['sets']!) ?? exercise.sets,
      reps: values['reps']!,
      weight: values['weight']!,
      note: values['note']!,
    );
    if (!mounted) return;
    _reload();
    showInfoSnackBar(context, 'سُجّل تمرين اليوم');
  }

  Future<void> _confirmDelete(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('حذف التمرين؟', style: TextStyle(color: AppTheme.textColor)),
          content: Text(
            'سيُحذف «${exercise.name}» وصورته. سجل تمارينك السابق يبقى.',
            style: const TextStyle(color: AppTheme.subTextColor, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await widget.health.deleteExercise(exercise.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (removed != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('حُذف «${exercise.name}»'),
          action: SnackBarAction(label: 'تراجع', onPressed: () => widget.health.restoreExercise(removed)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    if (exercise == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    final image = exercise.hasImage ? widget.health.exerciseImage(exercise.id) : null;
    final recent = widget.health.workouts(exerciseId: exercise.id).take(3).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exercise.name),
          actions: [
            IconButton(
              tooltip: exercise.pinned ? 'إلغاء تثبيت التمرين' : 'تثبيت التمرين',
              icon: Icon(
                exercise.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: AppTheme.accentColor,
              ),
              onPressed: () async {
                await widget.health.toggleExercisePin(exercise.id);
                if (mounted) _reload();
              },
            ),
            IconButton(
              tooltip: 'تعديل التمرين',
              icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor),
              onPressed: () => _edit(exercise),
            ),
            IconButton(
              tooltip: 'حذف التمرين',
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
              onPressed: () => _confirmDelete(exercise),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(image, height: 220, width: double.infinity, fit: BoxFit.cover, gaplessPlayback: true),
              ),
            const SizedBox(height: 12),
            if (exercise.muscles.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.accessibility_new_rounded, color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(exercise.muscles, style: const TextStyle(color: AppTheme.textColor))),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.repeat_rounded, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'المجموعات والتكرار: ${exercise.setsAndReps}',
                  style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    onPressed: () => _logToday(exercise),
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    label: const Text('سجّل اليوم', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WorkoutLogScreen(
                        health: widget.health,
                        exerciseId: exercise.id,
                        title: 'سجل «${exercise.name}»',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('السجل'),
                ),
              ],
            ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('آخر التسجيلات', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
              for (final w in recent)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${w.date} — ${w.sets} × ${w.reps}${w.weight.isEmpty ? '' : ' — ${w.weight}'}',
                    style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                  ),
                ),
            ],
            if (exercise.steps.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('خطوات الأداء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 8),
              for (var n = 0; n < exercise.steps.length; n++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${n + 1}. ', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(exercise.steps[n], style: const TextStyle(color: AppTheme.textColor, height: 1.6))),
                    ],
                  ),
                ),
            ],
            if (exercise.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('ملاحظات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 8),
              // نص عادي فقط: ما يولّده الذكاء الاصطناعي لا يُفسَّر Markdown ولا روابط.
              SelectableText(exercise.notes, style: const TextStyle(color: AppTheme.subTextColor, height: 1.7)),
            ],
          ],
        ),
      ),
    );
  }
}
