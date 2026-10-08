import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/theme/app_theme.dart';
import 'coach_session_service.dart';
import 'models/coach_question.dart';

class CoachHistoryScreen extends StatefulWidget {
  const CoachHistoryScreen({super.key});

  @override
  State<CoachHistoryScreen> createState() => _CoachHistoryScreenState();
}

class _CoachHistoryScreenState extends State<CoachHistoryScreen> {
  Map<CoachDomain, List<Map<String, dynamic>>> _grouped = {};
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
    if (!mounted) return;
    setState(() {
      _grouped = grouped;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل جلسات التأمل')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _grouped.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد جلسات محفوظة بعد',
                      style: TextStyle(color: AppTheme.subTextColor),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _grouped.entries.map(_buildDomainSection).toList(),
                  ),
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
            entry.key.arabicLabel,
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
            Text(
              intl.DateFormat('yyyy-MM-dd HH:mm').format(date),
              style: const TextStyle(fontSize: 11, color: AppTheme.subTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
