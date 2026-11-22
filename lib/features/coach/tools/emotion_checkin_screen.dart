import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/undo_snackbar.dart';
import '../../../l10n/l10n.dart';
import '../../meditation/meditation_tab.dart';
import '../coach_crisis_dialog.dart';
import '../coach_safety.dart';
import '../coach_session_service.dart';
import 'coach_tool_record.dart';

/// يفتح تبويب التأمل في صفحة مستقلة (اقتراح «تنفّس هادئ» بعد شعور قوي). يُستبدل في الاختبارات.
typedef MeditationOpener = Future<void> Function(BuildContext context);

Future<void> _openMeditation(BuildContext context) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(context.l10n.tabMeditation)),
          body: const MeditationTab(),
        ),
      ),
    );

/// تسمية المشاعر: الشعور وكلمة أدق وشدته ومكانه في الجسد وما أثاره وما يحتاجه، ثم سجل عبر الأيام.
/// محلي بالكامل. شدة 7 فأكثر تعرض (اقتراحًا فقط) جلسة «تنفّس هادئ» من تبويب التأمل.
class EmotionCheckinScreen extends StatefulWidget {
  /// المعاملات للاختبارات فقط.
  const EmotionCheckinScreen({super.key, this.now = DateTime.now, this.openMeditation = _openMeditation});

  final DateTime Function() now;
  final MeditationOpener openMeditation;

  @override
  State<EmotionCheckinScreen> createState() => _EmotionCheckinScreenState();
}

class _EmotionCheckinScreenState extends State<EmotionCheckinScreen> {
  static const int _logLimit = 20;

  CoachSessionService? _service;
  List<CoachToolRecord> _log = const [];
  Feeling? _feeling;
  final TextEditingController _word = TextEditingController();
  final TextEditingController _trigger = TextEditingController();
  int _intensity = 5;
  final Set<BodySpot> _body = {};
  FeelingNeed? _need;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _word.dispose();
    _trigger.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final service = _service ?? await CoachSessionService.getInstance();
    if (!mounted) return;
    setState(() {
      _service = service;
      _log = service.toolRecords(kind: CoachToolKind.emotion);
    });
  }

  Future<void> _save() async {
    final service = _service;
    final feeling = _feeling;
    if (service == null || feeling == null || _saving) return;
    final l10n = context.l10n;
    final word = _word.text.trim();
    final trigger = _trigger.text.trim();
    if (containsCrisisSignals('$word\n$trigger')) {
      await showCrisisHelpDialog(context, countryCode: deviceCountryCode());
      if (!mounted) return;
    }
    setState(() => _saving = true);
    final intensity = _intensity;
    await service.saveToolRecord(CoachToolRecord(
      id: '',
      kind: CoachToolKind.emotion,
      date: widget.now(),
      data: {
        'feeling': feeling.name,
        if (word.isNotEmpty) 'word': word,
        'intensity': intensity,
        'body': [for (final b in BodySpot.values) if (_body.contains(b)) b.name],
        if (trigger.isNotEmpty) 'trigger': trigger,
        if (_need != null) 'need': _need!.name,
      },
    ));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _feeling = null;
      _word.clear();
      _trigger.clear();
      _intensity = 5;
      _body.clear();
      _need = null;
    });
    await _load();
    if (!mounted) return;
    showInfoSnackBar(context, l10n.emotionSaved);
    if (intensity >= strongFeelingIntensity) await _offerBreathing();
  }

  Future<void> _offerBreathing() async {
    final l10n = context.l10n;
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        content: Text(l10n.emotionStrong, style: const TextStyle(color: AppTheme.textColor, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.notNow)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.openMeditation, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (open == true && mounted) await widget.openMeditation(context);
  }

  Future<void> _delete(CoachToolRecord record) async {
    final service = _service;
    if (service == null) return;
    final removed = await service.deleteSession(record.id);
    await _load();
    if (removed == null || !mounted) return;
    showUndoSnackBar(context, context.l10n.toolRecordDeleted, () async {
      await service.restoreSession(removed);
      if (mounted) await _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.emotionTitle)),
      body: _service == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(l10n.emotionIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
                const SizedBox(height: 16),
                _header(l10n.emotionWhich),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in Feeling.values)
                      ChoiceChip(
                        label: Text(f.label(l10n)),
                        selected: _feeling == f,
                        onSelected: (_) => setState(() => _feeling = f),
                      ),
                  ],
                ),
                TextField(
                  key: const ValueKey('emotion_word'),
                  controller: _word,
                  maxLength: 40,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(labelText: l10n.emotionWord),
                ),
                const SizedBox(height: 8),
                _header(l10n.emotionIntensity(_intensity)),
                Slider(
                  key: const ValueKey('emotion_intensity'),
                  value: _intensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_intensity',
                  onChanged: (v) => setState(() => _intensity = v.round()),
                ),
                _header(l10n.emotionWhere),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in BodySpot.values)
                      FilterChip(
                        label: Text(b.label(l10n)),
                        selected: _body.contains(b),
                        onSelected: (on) => setState(() => on ? _body.add(b) : _body.remove(b)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const ValueKey('emotion_trigger'),
                  controller: _trigger,
                  maxLines: 2,
                  minLines: 1,
                  maxLength: 300,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(labelText: l10n.emotionTrigger),
                ),
                const SizedBox(height: 8),
                _header(l10n.emotionNeed),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final n in FeelingNeed.values)
                      ChoiceChip(
                        label: Text(n.label(l10n)),
                        selected: _need == n,
                        onSelected: (on) => setState(() => _need = on ? n : null),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_feeling == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l10n.emotionPickFirst,
                        textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _feeling == null || _saving ? null : _save,
                  child: Text(l10n.save, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.surfaceColor),
                _header(l10n.emotionLog),
                ..._buildLog(l10n),
              ],
            ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      );

  List<Widget> _buildLog(AppLocalizations l10n) {
    if (_log.isEmpty) {
      return [Text(l10n.emotionLogEmpty, style: const TextStyle(color: AppTheme.subTextColor))];
    }
    final frequent = mostFrequentFeeling(_log, widget.now());
    final dateFormat = intl.DateFormat('yyyy-MM-dd HH:mm');
    return [
      if (frequent != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(l10n.emotionMostFrequent(frequent.label(l10n)), style: const TextStyle(color: AppTheme.accentColor)),
        ),
      for (final record in _log.take(_logLimit))
        Card(
          key: ValueKey('emotion_${record.id}'),
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              l10n.emotionLine(recordFeeling(record)?.label(l10n) ?? '', recordIntensity(record)),
              style: const TextStyle(color: AppTheme.textColor),
            ),
            subtitle: Text(
              [
                dateFormat.format(record.date),
                if (record.data['word'] case final String word) word,
                if (record.data['trigger'] case final String trigger) trigger,
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
            ),
            trailing: IconButton(
              tooltip: l10n.deleteEntry,
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor),
              onPressed: () => _delete(record),
            ),
          ),
        ),
    ];
  }
}
