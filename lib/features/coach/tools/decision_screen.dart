import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import 'coach_tool_record.dart';
import 'tool_form.dart';

/// قرار بين خيارين: ما يُكسب وما يُخسر مع كل خيار، وأي خيار قد يُندم على تركه بعد سنوات، وتجربة
/// صغيرة قبل الحسم، ثم الخيار المختار الآن وأول خطوة. التطبيق لا يرجّح شيئًا.
class DecisionScreen extends StatefulWidget {
  /// [now] يُستبدل في الاختبارات فقط.
  const DecisionScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

/// اختيار بين الخيارين، أو «غير واضح/لم يُحسم».
enum _Pick { a, b, none }

class _DecisionScreenState extends State<DecisionScreen> {
  final TextEditingController _optionA = TextEditingController();
  final TextEditingController _optionB = TextEditingController();
  // مكسب أ، خسارة أ، مكسب ب، خسارة ب، التجربة، الخطوة.
  final List<TextEditingController> _fields = List.generate(6, (_) => TextEditingController());
  _Pick _regret = _Pick.none;
  _Pick _chosen = _Pick.none;
  bool _addTask = true;
  TimeOfDay? _reminder;
  bool _saving = false;

  @override
  void dispose() {
    _optionA.dispose();
    _optionB.dispose();
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(int i) => _fields[i].text.trim();
  String get _a => _optionA.text.trim();
  String get _b => _optionB.text.trim();
  bool get _ready => _a.isNotEmpty && _b.isNotEmpty;

  Future<void> _save() async {
    if (_saving || !_ready) return;
    setState(() => _saving = true);
    final saved = await saveToolRecordWithStep(
      context,
      record: CoachToolRecord(
        id: '',
        kind: CoachToolKind.decision,
        date: widget.now(),
        data: {
          'optionA': _a,
          'optionB': _b,
          'gainA': _t(0),
          'lossA': _t(1),
          'gainB': _t(2),
          'lossB': _t(3),
          'regret': _regret.name,
          'experiment': _t(4),
          'chosen': _chosen.name,
        },
        step: _t(5).isEmpty ? null : _t(5),
      ),
      texts: [_a, _b, for (var i = 0; i < _fields.length; i++) _t(i)],
      addTask: _addTask,
      reminder: _reminder,
    );
    if (!saved && mounted) setState(() => _saving = false);
  }

  Widget _picks(String Function(_Pick) label, _Pick value, ValueChanged<_Pick> onPick, String keyPrefix) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in _Pick.values)
            ChoiceChip(
              key: ValueKey('${keyPrefix}_${p.name}'),
              label: Text(label(p)),
              selected: value == p,
              onSelected: (_) => setState(() => onPick(p)),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = _a.isEmpty ? l10n.decisionOptionA : _a;
    final b = _b.isEmpty ? l10n.decisionOptionB : _b;
    Widget option(TextEditingController c, String label, String key) => TextField(
          key: ValueKey(key),
          controller: c,
          maxLength: 80,
          style: const TextStyle(color: AppTheme.textColor),
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => setState(() {}),
        );
    Widget question(int i, String text) => ToolQuestion(
          question: text,
          controller: _fields[i],
          fieldKey: ValueKey('decision_field_$i'),
          maxLength: i == 5 ? 120 : 300,
          onChanged: i == 5 ? (_) => setState(() {}) : null,
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.decisionTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.decisionIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
          const SizedBox(height: 16),
          option(_optionA, l10n.decisionOptionA, 'decision_a'),
          option(_optionB, l10n.decisionOptionB, 'decision_b'),
          const SizedBox(height: 8),
          question(0, l10n.decisionGain(a)),
          question(1, l10n.decisionLoss(a)),
          question(2, l10n.decisionGain(b)),
          question(3, l10n.decisionLoss(b)),
          ToolHeader(l10n.decisionRegret),
          _picks((p) => switch (p) { _Pick.a => a, _Pick.b => b, _Pick.none => l10n.decisionUnsure }, _regret,
              (p) => _regret = p, 'decision_regret'),
          const SizedBox(height: 16),
          question(4, l10n.decisionExperiment),
          ToolHeader(l10n.decisionChosen),
          _picks((p) => switch (p) { _Pick.a => a, _Pick.b => b, _Pick.none => l10n.decisionUndecided }, _chosen,
              (p) => _chosen = p, 'decision_chosen'),
          const SizedBox(height: 16),
          question(5, l10n.decisionStep),
          StepTaskOption(
            addTask: _addTask,
            reminder: _reminder,
            onAddTaskChanged: (v) => setState(() => _addTask = v),
            onReminderChanged: (t) => setState(() => _reminder = t),
          ),
          const SizedBox(height: 12),
          ToolSaveButton(
            label: l10n.save,
            hint: l10n.decisionNeedOptions,
            onPressed: _saving || !_ready ? null : _save,
          ),
        ],
      ),
    );
  }
}
