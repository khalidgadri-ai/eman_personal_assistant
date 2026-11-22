import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/undo_snackbar.dart';
import '../../../l10n/l10n.dart';
import '../../budget/budget_format.dart';
import '../../reminders/reminder_notice.dart';
import '../coach_crisis_dialog.dart';
import '../coach_safety.dart';
import '../coach_session_service.dart';
import 'coach_step_task.dart';
import 'coach_tool_record.dart';

/// عجلة الحياة: تقييم ثمانية مجالات من 0 إلى 10 (رسم دائري مع العجلة السابقة للمقارنة)، ثم
/// مجال تركيز وأربعة أسئلة قصيرة عنه، آخرها خطوة صغيرة يمكن إضافتها إلى المهام بتذكير.
/// كل شيء محلي: لا إنترنت ولا ذكاء اصطناعي.
class WheelOfLifeScreen extends StatefulWidget {
  /// [now] يُستبدل في الاختبارات فقط.
  const WheelOfLifeScreen({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<WheelOfLifeScreen> createState() => _WheelOfLifeScreenState();
}

class _WheelOfLifeScreenState extends State<WheelOfLifeScreen> {
  static const int _answerMax = 300;
  static const int _stepMax = 120;

  CoachSessionService? _service;
  CoachToolRecord? _previous;
  final Map<WheelArea, int> _scores = {for (final a in WheelArea.values) a: 5};
  WheelArea? _focus;
  final List<TextEditingController> _answers = List.generate(4, (_) => TextEditingController());
  bool _addTask = true;
  TimeOfDay? _reminder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final service = await CoachSessionService.getInstance();
    final previous = service.toolRecords(kind: CoachToolKind.wheel).firstOrNull;
    if (!mounted) return;
    setState(() {
      _service = service;
      _previous = previous;
      // البداية من العجلة السابقة: يكفي تحريك ما تغيّر.
      if (previous != null) _scores.addAll(wheelScores(previous));
    });
  }

  WheelArea get _focusArea => _focus ?? lowestArea(_scores);

  Map<WheelArea, int> get _previousScores => _previous == null ? const {} : wheelScores(_previous!);

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(context: context, initialTime: _reminder ?? const TimeOfDay(hour: 9, minute: 0));
    if (picked != null && mounted) setState(() => _reminder = picked);
  }

  static String _hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final service = _service;
    if (service == null || _saving) return;
    final l10n = context.l10n;
    final texts = [for (final c in _answers) c.text.trim()];
    if (texts.any(containsCrisisSignals)) {
      await showCrisisHelpDialog(context, countryCode: deviceCountryCode());
      if (!mounted) return;
    }
    setState(() => _saving = true);
    final step = texts[3];
    await service.saveToolRecord(CoachToolRecord(
      id: '',
      kind: CoachToolKind.wheel,
      date: widget.now(),
      data: {
        'scores': {for (final e in _scores.entries) e.key.name: e.value},
        'focus': _focusArea.name,
        'answers': texts.sublist(0, 3),
      },
      step: step.isEmpty ? null : step,
    ));
    final withTask = _addTask && step.isNotEmpty;
    if (withTask) {
      await addCoachStepAsTask(step, reminder: _reminder == null ? '' : _hhmm(_reminder!));
      if (_reminder != null && mounted) await syncRemindersWithNotice(context, ask: true);
    }
    if (!mounted) return;
    showInfoSnackBar(context, withTask ? l10n.wheelSavedWithTask : l10n.wheelSaved);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wheelTitle)),
      body: _service == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(l10n.wheelIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
                const SizedBox(height: 12),
                SizedBox(height: 300, child: _buildRadar(l10n)),
                const SizedBox(height: 12),
                _buildLegend(l10n),
                const SizedBox(height: 12),
                for (final area in WheelArea.values) _buildSlider(l10n, area),
                const SizedBox(height: 16),
                _header(l10n.wheelFocus),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final area in WheelArea.values)
                      ChoiceChip(
                        label: Text('${area.label(l10n)} (${_scores[area]})'),
                        selected: _focusArea == area,
                        onSelected: (_) => setState(() => _focus = area),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildQuestions(l10n),
                CheckboxListTile(
                  key: const ValueKey('wheel_add_task'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _addTask,
                  onChanged: (v) => setState(() => _addTask = v ?? false),
                  title: Text(l10n.stepToTask, style: const TextStyle(color: AppTheme.textColor)),
                ),
                if (_addTask)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickReminder,
                        icon: const Icon(Icons.alarm_rounded),
                        label: Text(_reminder == null ? l10n.stepSetReminder : l10n.stepReminder(_hhmm(_reminder!))),
                      ),
                      if (_reminder != null)
                        TextButton(
                          onPressed: () => setState(() => _reminder = null),
                          child: Text(l10n.stepNoReminder),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.wheelSave, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      );

  List<Widget> _buildQuestions(AppLocalizations l10n) {
    final area = _focusArea;
    final name = area.label(l10n);
    final score = _scores[area] ?? 0;
    final questions = [
      l10n.wheelQ1(name, score),
      score >= 9 ? l10n.wheelQ2Keep(name) : l10n.wheelQ2(name, score + 1 > 10 ? 10 : score + 1),
      l10n.wheelQ3,
      l10n.wheelQ4,
    ];
    return [
      for (var i = 0; i < questions.length; i++) ...[
        Text(questions[i], style: const TextStyle(color: AppTheme.textColor, height: 1.5)),
        TextField(
          key: ValueKey('wheel_answer_$i'),
          controller: _answers[i],
          maxLines: i == 3 ? 2 : 3,
          minLines: 1,
          maxLength: i == 3 ? _stepMax : _answerMax,
          style: const TextStyle(color: AppTheme.textColor),
          decoration: InputDecoration(
            hintText: l10n.answerOptional,
            hintStyle: const TextStyle(color: AppTheme.subTextColor),
          ),
          onChanged: i == 3 ? (_) => setState(() {}) : null,
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  Widget _buildSlider(AppLocalizations l10n, WheelArea area) {
    final value = _scores[area] ?? 0;
    final was = _previousScores[area];
    return Column(
      key: ValueKey('wheel_slider_${area.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(area.label(l10n), style: const TextStyle(color: AppTheme.textColor))),
            if (was != null && was != value)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Text(l10n.wheelWas(was), style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
              ),
            Text('$value', style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: '$value',
          onChanged: (v) => setState(() => _scores[area] = v.round()),
        ),
      ],
    );
  }

  Widget _buildRadar(AppLocalizations l10n) {
    const areas = WheelArea.values;
    RadarDataSet dataSet(Map<WheelArea, int> scores, Color color, double fill) => RadarDataSet(
          dataEntries: [for (final a in areas) RadarEntry(value: (scores[a] ?? 0).toDouble())],
          fillColor: color.withValues(alpha: fill),
          borderColor: color,
          borderWidth: 2,
          entryRadius: 2,
        );
    // مجموعتان شفافتان تثبّتان المقياس من 0 (المركز) إلى 10 مهما كانت الدرجات.
    RadarDataSet scale(double v) => RadarDataSet(
          dataEntries: [for (final _ in areas) RadarEntry(value: v)],
          fillColor: Colors.transparent,
          borderColor: Colors.transparent,
          borderWidth: 0,
          entryRadius: 0,
        );
    return RadarChart(
      RadarChartData(
        dataSets: [
          scale(10),
          scale(0),
          if (_previous != null) dataSet(_previousScores, AppTheme.subTextColor, 0.08),
          dataSet(_scores, AppTheme.accentColor, 0.25),
        ],
        radarShape: RadarShape.polygon,
        isMinValueAtCenter: true,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
        radarBorderData: const BorderSide(color: AppTheme.surfaceColor),
        gridBorderData: const BorderSide(color: AppTheme.surfaceColor),
        tickBorderData: const BorderSide(color: AppTheme.surfaceColor),
        titleTextStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 10),
        titlePositionPercentageOffset: 0.12,
        getTitle: (index, angle) => RadarChartTitle(text: areas[index].label(l10n)),
        radarTouchData: RadarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    Widget dot(Color color, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
          ],
        );
    final previous = _previous;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        dot(AppTheme.accentColor, l10n.wheelNow),
        if (previous != null)
          dot(AppTheme.subTextColor, l10n.wheelLastTime(formatDayMonth(previous.date, context.appLang))),
      ],
    );
  }
}
