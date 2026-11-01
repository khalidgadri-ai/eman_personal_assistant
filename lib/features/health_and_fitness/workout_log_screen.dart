import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'health_service.dart';
import 'models/exercise.dart';

/// سجل التمارين المنفَّذة مجمّعًا باليوم (الأحدث أولًا). [exerciseId] يقصره على تمرين واحد.
class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key, required this.health, this.exerciseId, this.title = 'سجل التمارين'});

  final HealthService health;
  final String? exerciseId;
  final String title;

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  late List<WorkoutEntry> _entries = widget.health.workouts(exerciseId: widget.exerciseId);

  void _reload() => setState(() => _entries = widget.health.workouts(exerciseId: widget.exerciseId));

  Future<void> _delete(WorkoutEntry entry) async {
    final removed = await widget.health.deleteWorkout(entry.id);
    if (removed == null || !mounted) return;
    _reload();
    showUndoSnackBar(context, 'حُذف التسجيل', () async {
      await widget.health.restoreWorkout(removed);
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final byDay = <String, List<WorkoutEntry>>{};
    for (final entry in _entries) {
      byDay.putIfAbsent(entry.date, () => []).add(entry);
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: _entries.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'لم تُسجَّل تمارين بعد. افتح تمرينًا واضغط «سجّل اليوم».',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.subTextColor),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final day in byDay.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Text(
                        day.key,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (final entry in day.value)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center_rounded, color: AppTheme.accentColor),
                          title: Text(
                            entry.exerciseName.isEmpty ? 'تمرين' : entry.exerciseName,
                            style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            [
                              '${entry.sets} × ${entry.reps}',
                              if (entry.weight.isNotEmpty) entry.weight,
                              if (entry.note.isNotEmpty) entry.note,
                            ].join(' · '),
                            style: const TextStyle(color: AppTheme.subTextColor),
                          ),
                          trailing: IconButton(
                            tooltip: 'حذف التسجيل',
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
                            onPressed: () => _delete(entry),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}
