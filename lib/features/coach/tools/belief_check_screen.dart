import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import 'coach_tool_record.dart';
import 'tool_form.dart';

/// فحص معتقد: جملة تتكرر في الرأس، ومن أين جاءت، وما يؤيدها وما ينقضها، ثم صياغة أدق لها
/// وما يؤيدها، وتقدير مدى صدق الجملة القديمة قبل الفحص وبعده، وخطوة صغيرة تختبر الجديدة.
class BeliefCheckScreen extends StatefulWidget {
  /// [now] يُستبدل في الاختبارات فقط.
  const BeliefCheckScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<BeliefCheckScreen> createState() => _BeliefCheckScreenState();
}

class _BeliefCheckScreenState extends State<BeliefCheckScreen> {
  // الجملة، المصدر، ما يؤيدها، ما ينقضها، الصياغة الجديدة، ما يؤيد الجديدة، الخطوة.
  final List<TextEditingController> _fields = List.generate(7, (_) => TextEditingController());
  int _before = 7;
  int _after = 5;
  bool _addTask = true;
  TimeOfDay? _reminder;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(int i) => _fields[i].text.trim();

  Future<void> _save() async {
    if (_saving || _t(0).isEmpty) return;
    setState(() => _saving = true);
    final saved = await saveToolRecordWithStep(
      context,
      record: CoachToolRecord(
        id: '',
        kind: CoachToolKind.belief,
        date: widget.now(),
        data: {
          'belief': _t(0),
          'origin': _t(1),
          'for': _t(2),
          'against': _t(3),
          'reframe': _t(4),
          'reframeFor': _t(5),
          'before': _before,
          'after': _after,
        },
        step: _t(6).isEmpty ? null : _t(6),
      ),
      texts: [for (var i = 0; i < _fields.length; i++) _t(i)],
      addTask: _addTask,
      reminder: _reminder,
    );
    if (!saved && mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final questions = [
      l10n.beliefSentence,
      l10n.beliefOrigin,
      l10n.beliefFor,
      l10n.beliefAgainst,
      l10n.beliefNew,
      l10n.beliefNewFor,
      l10n.beliefStep,
    ];
    Widget question(int i) => ToolQuestion(
          question: questions[i],
          controller: _fields[i],
          fieldKey: ValueKey('belief_field_$i'),
          maxLength: i == 0 || i == 4 ? 160 : (i == 6 ? 120 : 300),
          onChanged: i == 0 || i == 6 ? (_) => setState(() {}) : null,
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.beliefTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.beliefIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
          const SizedBox(height: 16),
          for (var i = 0; i < 4; i++) question(i),
          ToolHeader(l10n.beliefStrengthBefore(_before)),
          Slider(
            key: const ValueKey('belief_before'),
            value: _before.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$_before',
            onChanged: (v) => setState(() => _before = v.round()),
          ),
          question(4),
          question(5),
          ToolHeader(l10n.beliefStrengthAfter(_after)),
          Slider(
            key: const ValueKey('belief_after'),
            value: _after.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$_after',
            onChanged: (v) => setState(() => _after = v.round()),
          ),
          question(6),
          StepTaskOption(
            addTask: _addTask,
            reminder: _reminder,
            onAddTaskChanged: (v) => setState(() => _addTask = v),
            onReminderChanged: (t) => setState(() => _reminder = t),
          ),
          const SizedBox(height: 12),
          ToolSaveButton(
            label: l10n.save,
            hint: l10n.writeSentenceFirst,
            onPressed: _saving || _t(0).isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }
}
