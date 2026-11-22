import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/undo_snackbar.dart';
import '../../../l10n/l10n.dart';
import '../../reminders/reminder_notice.dart';
import '../coach_crisis_dialog.dart';
import '../coach_safety.dart';
import '../coach_session_service.dart';
import 'coach_tool_record.dart';
import 'tool_form.dart';

/// تغيير عادة: ما يثيرها (المكان والوقت والأشخاص والشعور)، وتعديل صغير في البيئة، وخطوة يومية،
/// ثم متابعة 21 يومًا بعلامة لكل يوم وتذكير يومي اختياري (يتوقف وحده بعد اليوم 21 أو عند الإيقاف).
/// عادة واحدة جارية في كل مرة.
class HabitChangeScreen extends StatefulWidget {
  /// [now] يُستبدل في الاختبارات فقط.
  const HabitChangeScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<HabitChangeScreen> createState() => _HabitChangeScreenState();
}

class _HabitChangeScreenState extends State<HabitChangeScreen> {
  CoachSessionService? _service;
  List<CoachToolRecord> _habits = const [];
  // العادة، أين، متى، مع من، بعد أي شعور، تعديل البيئة، الخطوة اليومية.
  final List<TextEditingController> _fields = List.generate(7, (_) => TextEditingController());
  TimeOfDay? _reminder;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final service = _service ?? await CoachSessionService.getInstance();
    if (!mounted) return;
    setState(() {
      _service = service;
      _habits = service.toolRecords(kind: CoachToolKind.habit);
    });
  }

  CoachToolRecord? get _active => _habits.where((h) => habitIsActive(h, widget.now())).firstOrNull;

  String _t(int i) => _fields[i].text.trim();
  bool get _ready => _t(0).isNotEmpty && _t(6).isNotEmpty;

  Future<void> _start() async {
    final service = _service;
    if (service == null || _busy || !_ready) return;
    final texts = [for (var i = 0; i < _fields.length; i++) _t(i)];
    if (texts.any(containsCrisisSignals)) {
      await showCrisisHelpDialog(context, countryCode: deviceCountryCode());
      if (!mounted) return;
    }
    setState(() => _busy = true);
    await service.saveToolRecord(CoachToolRecord(
      id: '',
      kind: CoachToolKind.habit,
      date: widget.now(),
      data: {
        'habit': texts[0],
        'where': texts[1],
        'when': texts[2],
        'who': texts[3],
        'feeling': texts[4],
        'environment': texts[5],
        'dailyStep': texts[6],
        if (_reminder != null) 'reminder': hhmm(_reminder!),
        'checkins': const <String>[],
      },
    ));
    if (!mounted) return;
    if (_reminder != null) await syncRemindersWithNotice(context, ask: true);
    for (final c in _fields) {
      c.clear();
    }
    _reminder = null;
    await _load();
    if (!mounted) return;
    setState(() => _busy = false);
    showInfoSnackBar(context, context.l10n.habitStarted);
  }

  Future<void> _update(CoachToolRecord habit, Map<String, dynamic> changes, {bool resync = false, bool ask = false}) async {
    final service = _service;
    if (service == null) return;
    await service.updateToolRecord(CoachToolRecord(
      id: habit.id,
      kind: habit.kind,
      date: habit.date,
      data: {...habit.data, ...changes},
    ));
    if (resync && mounted) await syncRemindersWithNotice(context, ask: ask);
    await _load();
  }

  Future<void> _toggleToday(CoachToolRecord habit) async {
    final today = dayKey(widget.now());
    final checkins = habitCheckins(habit);
    checkins.contains(today) ? checkins.remove(today) : checkins.add(today);
    await _update(habit, {'checkins': checkins.toList()..sort()});
  }

  Future<void> _changeReminder(CoachToolRecord habit, TimeOfDay? time) async {
    final data = {...habit.data}..remove('reminder');
    final service = _service;
    if (service == null) return;
    await service.updateToolRecord(CoachToolRecord(
      id: habit.id,
      kind: habit.kind,
      date: habit.date,
      data: {...data, if (time != null) 'reminder': hhmm(time)},
    ));
    if (mounted) await syncRemindersWithNotice(context, ask: time != null);
    await _load();
  }

  Future<void> _stop(CoachToolRecord habit) async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        content: Text(l10n.habitStopAsk, style: const TextStyle(color: AppTheme.textColor, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.habitStop, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    await _update(habit, {'stopped': true}, resync: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = _active;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.habitTitle)),
      body: _service == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (active != null) ..._buildTracker(l10n, active) else ..._buildForm(l10n),
                ..._buildPast(l10n, active),
              ],
            ),
    );
  }

  List<Widget> _buildTracker(AppLocalizations l10n, CoachToolRecord habit) {
    final now = widget.now();
    final day = habitDayNumber(habit, now);
    final checkins = habitCheckins(habit);
    final start = DateTime(habit.date.year, habit.date.month, habit.date.day);
    final doneToday = checkins.contains(dayKey(now));
    final reminder = ReminderTimeText.parse(habit.data['reminder']);
    return [
      Text('${habit.data['habit'] ?? ''}',
          style: const TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('${habit.data['dailyStep'] ?? ''}', style: const TextStyle(color: AppTheme.subTextColor, height: 1.5)),
      const SizedBox(height: 12),
      Text(l10n.habitDay(day), key: const ValueKey('habit_day'), style: const TextStyle(color: AppTheme.accentColor)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < habitDays; i++)
            _dayDot(
              number: i + 1,
              done: checkins.contains(dayKey(DateTime(start.year, start.month, start.day + i))),
              isToday: i + 1 == day,
              future: i + 1 > day,
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(l10n.habitDoneCount(habitDoneCount(habit)), style: const TextStyle(color: AppTheme.textColor)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        key: const ValueKey('habit_today'),
        style: ElevatedButton.styleFrom(
          backgroundColor: doneToday ? AppTheme.surfaceColor : AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => _toggleToday(habit),
        icon: Icon(doneToday ? Icons.undo_rounded : Icons.check_rounded, color: Colors.white),
        label: Text(doneToday ? l10n.habitUncheckToday : l10n.habitCheckToday, style: const TextStyle(color: Colors.white)),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          TextButton.icon(
            onPressed: () async {
              final picked = await pickReminderTime(context, reminder);
              if (picked != null) await _changeReminder(habit, picked);
            },
            icon: const Icon(Icons.alarm_rounded),
            label: Text(reminder == null ? l10n.stepSetReminder : l10n.stepReminder(hhmm(reminder))),
          ),
          if (reminder != null) TextButton(onPressed: () => _changeReminder(habit, null), child: Text(l10n.stepNoReminder)),
        ],
      ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          onPressed: () => _stop(habit),
          child: Text(l10n.habitStop, style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    ];
  }

  Widget _dayDot({required int number, required bool done, required bool isToday, required bool future}) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppTheme.accentColor : Colors.transparent,
        border: Border.all(
          color: isToday ? AppTheme.textColor : (future ? AppTheme.surfaceColor : AppTheme.subTextColor),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Text(
        '$number',
        style: TextStyle(color: done ? Colors.white : (future ? AppTheme.surfaceColor : AppTheme.subTextColor), fontSize: 12),
      ),
    );
  }

  List<Widget> _buildForm(AppLocalizations l10n) {
    final questions = [
      l10n.habitName,
      l10n.habitWhere,
      l10n.habitWhen,
      l10n.habitWho,
      l10n.habitFeeling,
      l10n.habitEnvironment,
      l10n.habitDailyStep,
    ];
    final last = _habits.firstOrNull;
    return [
      if (last != null && !habitIsActive(last, widget.now()) && last.data['stopped'] != true)
        Card(
          color: AppTheme.surfaceColor,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.habitFinished(habitDoneCount(last)), style: const TextStyle(color: AppTheme.textColor)),
          ),
        ),
      Text(l10n.habitIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
      const SizedBox(height: 16),
      for (var i = 0; i < questions.length; i++)
        ToolQuestion(
          question: questions[i],
          controller: _fields[i],
          fieldKey: ValueKey('habit_field_$i'),
          maxLength: i == 0 ? 80 : (i == 6 ? 120 : 300),
          onChanged: i == 0 || i == 6 ? (_) => setState(() {}) : null,
        ),
      Row(
        children: [
          TextButton.icon(
            onPressed: () async {
              final picked = await pickReminderTime(context, _reminder);
              if (picked != null && mounted) setState(() => _reminder = picked);
            },
            icon: const Icon(Icons.alarm_rounded),
            label: Text(_reminder == null ? l10n.habitDailyReminder : l10n.stepReminder(hhmm(_reminder!))),
          ),
          if (_reminder != null)
            TextButton(onPressed: () => setState(() => _reminder = null), child: Text(l10n.stepNoReminder)),
        ],
      ),
      const SizedBox(height: 12),
      ToolSaveButton(label: l10n.habitStart, hint: l10n.habitNeedFields, onPressed: _busy || !_ready ? null : _start),
    ];
  }

  List<Widget> _buildPast(AppLocalizations l10n, CoachToolRecord? active) {
    final past = _habits.where((h) => h.id != active?.id).toList();
    if (past.isEmpty) return const [];
    return [
      const SizedBox(height: 24),
      const Divider(color: AppTheme.surfaceColor),
      ToolHeader(l10n.habitPast),
      for (final h in past)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${h.data['habit'] ?? ''}', style: const TextStyle(color: AppTheme.textColor)),
          subtitle: Text(l10n.habitDoneCount(habitDoneCount(h)), style: const TextStyle(color: AppTheme.subTextColor)),
        ),
    ];
  }
}

/// وقت التذكير المحفوظ `HH:mm` كـ [TimeOfDay]، أو null.
abstract final class ReminderTimeText {
  static TimeOfDay? parse(Object? value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch('${value ?? ''}');
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    return h < 24 && m < 60 ? TimeOfDay(hour: h, minute: m) : null;
  }
}
