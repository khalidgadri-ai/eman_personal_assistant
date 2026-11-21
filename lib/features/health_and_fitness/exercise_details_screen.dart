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
import '../../l10n/l10n.dart';

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
      title: context.l10n.workoutLogTitle,
      confirmLabel: context.l10n.logAction,
      fields: [
        EntryField(
          key: 'sets',
          label: context.l10n.setsField,
          keyboardType: TextInputType.number,
          maxLength: 2,
          required: true,
          initial: '${exercise.sets}',
          validator: (v) {
            final n = parseInteger(v);
            return n == null || n < 1 || n > Exercise.maxSets ? context.l10n.setsError(Exercise.maxSets) : null;
          },
        ),
        EntryField(
          key: 'reps',
          label: context.l10n.repsField,
          maxLength: Exercise.maxRepsLength,
          required: true,
          initial: exercise.reps,
        ),
        EntryField(key: 'weight', label: context.l10n.weightField, hint: context.l10n.weightHint, maxLength: 20),
        EntryField(key: 'note', label: context.l10n.noteOptionalField, maxLength: 200),
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
    showInfoSnackBar(context, context.l10n.workoutLogged);
  }

  Future<void> _confirmDelete(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(context.l10n.exerciseDeleteAsk, style: TextStyle(color: AppTheme.textColor)),
        content: Text(
          context.l10n.exerciseDeleteBody(exercise.name),
          style: const TextStyle(color: AppTheme.subTextColor, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel, style: TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.deleteAction, style: TextStyle(color: Colors.white)),
          ),
        ],
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
          content: Text(context.l10n.exerciseDeleted(exercise.name)),
          action: SnackBarAction(label: context.l10n.undo, onPressed: () => widget.health.restoreExercise(removed)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    if (exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final image = exercise.hasImage ? widget.health.exerciseImage(exercise.id) : null;
    final recent = widget.health.workouts(exerciseId: exercise.id).take(3).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            tooltip: exercise.pinned ? context.l10n.exerciseUnpin : context.l10n.exercisePin,
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
            tooltip: context.l10n.exerciseEdit,
            icon: const Icon(Icons.edit_rounded, color: AppTheme.accentColor),
            onPressed: () => _edit(exercise),
          ),
          IconButton(
            tooltip: context.l10n.exerciseDelete,
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
                context.l10n.setsRepsLine(exercise.setsAndReps),
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
                  label: Text(context.l10n.logToday, style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkoutLogScreen(
                      health: widget.health,
                      exerciseId: exercise.id,
                      title: context.l10n.exerciseLogOf(exercise.name),
                    ),
                  ),
                ),
                icon: const Icon(Icons.history_rounded),
                label: Text(context.l10n.logLabel),
              ),
            ],
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(context.l10n.latestLogs, style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
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
            Text(context.l10n.stepsHeader, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
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
            Text(context.l10n.notesHeader, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 8),
            // نص عادي فقط: ما يولّده الذكاء الاصطناعي لا يُفسَّر Markdown ولا روابط.
            SelectableText(exercise.notes, style: const TextStyle(color: AppTheme.subTextColor, height: 1.7)),
          ],
        ],
      ),
    );
  }
}
