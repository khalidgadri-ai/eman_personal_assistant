import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/undo_snackbar.dart';
import 'coach_session_service.dart';
import 'models/coach_question.dart';
import 'tools/coach_tool_record.dart';
import '../../l10n/l10n.dart';

class CoachHistoryScreen extends StatefulWidget {
  const CoachHistoryScreen({super.key});

  @override
  State<CoachHistoryScreen> createState() => _CoachHistoryScreenState();
}

class _CoachHistoryScreenState extends State<CoachHistoryScreen> {
  Map<CoachDomain, List<Map<String, dynamic>>> _grouped = {};
  List<CoachToolRecord> _tools = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = await CoachSessionService.getInstance();
    final sessions = service.getSessions();
    final grouped = <CoachDomain, List<Map<String, dynamic>>>{};
    for (final session in sessions) {
      final domain = CoachDomain.values.byName(session['domain'] as String);
      grouped.putIfAbsent(domain, () => []).add(session);
    }
    final tools = service.toolRecords();
    if (!mounted) return;
    setState(() {
      _grouped = grouped;
      _tools = tools;
      _loading = false;
    });
  }

  Future<void> _delete(Map<String, dynamic> session) async {
    final service = await CoachSessionService.getInstance();
    final removed = await service.deleteSession('${session['id']}');
    await _load();
    if (removed == null || !mounted) return;
    showUndoSnackBar(context, context.l10n.coachSessionDeleted, () async {
      await service.restoreSession(removed);
      if (mounted) await _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.coachHistory)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grouped.isEmpty && _tools.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.coachNoSessions,
                    style: TextStyle(color: AppTheme.subTextColor),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_tools.isNotEmpty) _buildToolsSection(),
                    ..._grouped.entries.map(_buildDomainSection),
                  ],
                ),
    );
  }

  /// سجلات أدوات المدرب (عجلة الحياة، المشاعر): ملخص سطر واحد، والحذف مع «تراجع».
  Widget _buildToolsSection() {
    final l10n = context.l10n;
    final dateFormat = intl.DateFormat('yyyy-MM-dd HH:mm');
    String title(CoachToolRecord r) => switch (r.kind) {
          CoachToolKind.wheel => l10n.wheelTitle,
          CoachToolKind.emotion => l10n.emotionLine(recordFeeling(r)?.label(l10n) ?? '', recordIntensity(r)),
        };
    String? detail(CoachToolRecord r) {
      if (r.kind != CoachToolKind.wheel) return r.data['trigger'] as String?;
      final focus = WheelArea.values.where((a) => a.name == r.data['focus']).firstOrNull;
      return [
        if (focus != null) l10n.historyWheelFocus(focus.label(l10n), wheelScores(r)[focus] ?? 0),
        if (r.hasStep) l10n.historyStep(r.step!),
      ].join('\n');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.historyToolsSection,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          for (final r in _tools)
            Card(
              key: ValueKey('tool_${r.id}'),
              color: AppTheme.cardColor,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(title(r), style: const TextStyle(color: AppTheme.textColor)),
                subtitle: Text(
                  [dateFormat.format(r.date), if (detail(r) case final d? when d.isNotEmpty) d].join('\n'),
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12, height: 1.5),
                ),
                trailing: IconButton(
                  tooltip: l10n.deleteEntry,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor, size: 20),
                  onPressed: () => _delete({'id': r.id}),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDomainSection(MapEntry<CoachDomain, List<Map<String, dynamic>>> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key.label(context.l10n),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.value.map(_buildSessionCard),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final date = session['date'] as DateTime;
    final answer = session['answerText'] as String?;
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session['questionText'] as String,
              style: const TextStyle(color: AppTheme.textColor),
            ),
            if (answer != null && answer.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(answer, style: const TextStyle(color: AppTheme.subTextColor)),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    intl.DateFormat('yyyy-MM-dd HH:mm').format(date),
                    style: const TextStyle(fontSize: 11, color: AppTheme.subTextColor),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.coachDeleteSession,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.subTextColor, size: 20),
                  onPressed: () => _delete(session),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
