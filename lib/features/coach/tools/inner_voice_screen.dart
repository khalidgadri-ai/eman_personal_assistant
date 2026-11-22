import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import 'coach_tool_record.dart';
import 'tool_form.dart';

/// الصوت الداخلي: نمط الصوت الناقد (القلِق، الناقد، اليائس، الكمالي) واسم له، والجملة التي يكررها
/// ومتى يعلو، والرد لو قالها صديق، ثم صياغة أهدأ وأعدل وخطوة عملية صغيرة.
class InnerVoiceScreen extends StatefulWidget {
  /// [now] يُستبدل في الاختبارات فقط.
  const InnerVoiceScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<InnerVoiceScreen> createState() => _InnerVoiceScreenState();
}

class _InnerVoiceScreenState extends State<InnerVoiceScreen> {
  InnerVoiceType? _type;
  final TextEditingController _name = TextEditingController();
  // الجملة، متى يعلو، رد الصديق، الصياغة الجديدة، الخطوة.
  final List<TextEditingController> _fields = List.generate(5, (_) => TextEditingController());
  bool _addTask = true;
  TimeOfDay? _reminder;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(int i) => _fields[i].text.trim();

  Future<void> _save() async {
    if (_saving || _t(0).isEmpty) return;
    setState(() => _saving = true);
    final name = _name.text.trim();
    final saved = await saveToolRecordWithStep(
      context,
      record: CoachToolRecord(
        id: '',
        kind: CoachToolKind.innerVoice,
        date: widget.now(),
        data: {
          if (_type != null) 'type': _type!.name,
          if (name.isNotEmpty) 'name': name,
          'sentence': _t(0),
          'when': _t(1),
          'friend': _t(2),
          'reframe': _t(3),
        },
        step: _t(4).isEmpty ? null : _t(4),
      ),
      texts: [name, for (var i = 0; i < _fields.length; i++) _t(i)],
      addTask: _addTask,
      reminder: _reminder,
    );
    if (!saved && mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final questions = [
      l10n.innerVoiceSentence,
      l10n.innerVoiceWhen,
      l10n.innerVoiceFriend,
      l10n.innerVoiceReframe,
      l10n.innerVoiceStep,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.innerVoiceTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.innerVoiceIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
          const SizedBox(height: 16),
          ToolHeader(l10n.innerVoiceType),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in InnerVoiceType.values)
                ChoiceChip(
                  key: ValueKey('voice_${type.name}'),
                  label: Text(type.label(l10n)),
                  selected: _type == type,
                  onSelected: (on) => setState(() => _type = on ? type : null),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('voice_name'),
            controller: _name,
            maxLength: 40,
            style: const TextStyle(color: AppTheme.textColor),
            decoration: InputDecoration(labelText: l10n.innerVoiceName),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < questions.length; i++)
            ToolQuestion(
              question: questions[i],
              controller: _fields[i],
              fieldKey: ValueKey('voice_field_$i'),
              maxLength: i == 4 ? 120 : 300,
              onChanged: i == 0 || i == 4 ? (_) => setState(() {}) : null,
            ),
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
