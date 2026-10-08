import 'package:flutter/material.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_key_setup_screen.dart';
import 'coach_ai_service.dart';
import 'coach_history_screen.dart';
import 'coach_paywall_screen.dart';
import 'coach_safety.dart';
import 'coach_session_service.dart';
import 'coach_signal_service.dart';
import 'models/coach_question.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  CoachSessionService? _service;
  final CoachAiService _aiService = CoachAiService();
  CoachDomain _selectedDomain = CoachDomain.beliefs;
  CoachQuestion? _currentQuestion;
  String? _signalHint;
  final TextEditingController _answerController = TextEditingController();
  bool _loading = true;
  bool _deepening = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final service = await CoachSessionService.getInstance();
    final signals = await CoachSignalService().getSignals();
    final domain = CoachSessionService.pickDomain(signals);
    if (!mounted) return;
    setState(() {
      _service = service;
      _selectedDomain = domain;
      _currentQuestion = service.pickQuestion(domain);
      _signalHint = signals.hintFor(domain);
      _loading = false;
    });
  }

  void _onDomainChanged(CoachDomain domain) {
    final service = _service;
    if (service == null) return;
    setState(() {
      _selectedDomain = domain;
      _currentQuestion = service.pickQuestion(domain);
      _signalHint = null;
      _answerController.clear();
    });
  }

  Future<void> _onNext() async {
    final service = _service;
    final question = _currentQuestion;
    if (service == null || question == null) return;

    final answer = _answerController.text.trim();

    if (containsCrisisSignals(answer)) {
      await _showCrisisDialog();
      return;
    }

    await service.saveSession(
      question: question,
      answerText: answer.isEmpty ? null : answer,
    );

    if (!mounted) return;
    setState(() {
      _currentQuestion = service.pickQuestion(_selectedDomain);
      _signalHint = null;
      _answerController.clear();
    });
  }

  Future<void> _onDeepen() async {
    final service = _service;
    final question = _currentQuestion;
    final answer = _answerController.text.trim();
    if (service == null || question == null || answer.isEmpty) return;

    if (containsCrisisSignals(answer)) {
      await _showCrisisDialog();
      return;
    }

    if (!await _ensureSubscribed() || !mounted) return;

    final gemini = await requireGeminiService(context);
    if (gemini == null || !mounted) return;

    setState(() => _deepening = true);
    final result = await _aiService.requestFollowUp(question: question, answer: answer);
    if (!mounted) return;

    switch (result) {
      case CrisisDetected():
        setState(() => _deepening = false);
        await _showCrisisDialog();
      case FollowUpQuestion(question: final followUp):
        await service.saveSession(question: question, answerText: answer);
        if (!mounted) return;
        setState(() {
          _currentQuestion = followUp;
          _signalHint = null;
          _answerController.clear();
          _deepening = false;
        });
    }
  }

  Future<bool> _ensureSubscribed() async {
    setState(() => _deepening = true);
    final subscription = await SubscriptionService.getInstance();
    final active = await subscription.verify();
    if (!mounted) return false;
    setState(() => _deepening = false);
    if (active) return true;

    final subscribed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CoachPaywallScreen()),
    );
    return subscribed == true;
  }

  Future<void> _showCrisisDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('مهم', style: TextStyle(color: AppTheme.textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  crisisResponseMessage,
                  style: TextStyle(color: AppTheme.textColor, height: 1.6),
                ),
                const SizedBox(height: 16),
                for (final line in crisisHelplines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          line.number,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          line.description,
                          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  crisisHelplinesNote,
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 11),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('فهمت', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مدرب الحياة'),
          actions: [
            IconButton(
              tooltip: 'سجل جلسات التأمل',
              icon: const Icon(Icons.history_rounded, color: AppTheme.accentColor),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CoachHistoryScreen()),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'هذا أداة تأمل ذاتي، وليس بديلاً عن معالج نفسي مرخّص.',
                        style: TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<CoachDomain>(
                      value: _selectedDomain,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      style: const TextStyle(color: AppTheme.textColor),
                      items: CoachDomain.values
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.arabicLabel),
                              ))
                          .toList(),
                      onChanged: _deepening
                          ? null
                          : (d) {
                              if (d != null) _onDomainChanged(d);
                            },
                    ),
                    const SizedBox(height: 24),
                    if (_signalHint case final hint?)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.insights_rounded, size: 16, color: AppTheme.subTextColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hint,
                                style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      _currentQuestion?.text ?? '',
                      style: const TextStyle(fontSize: 18, color: AppTheme.textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _answerController,
                      maxLines: 4,
                      style: const TextStyle(color: AppTheme.textColor),
                      decoration: const InputDecoration(
                        hintText: 'إجابتك (اختياري)...',
                        hintStyle: TextStyle(color: AppTheme.subTextColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _answerController,
                      builder: (context, value, _) {
                        final hasAnswer = value.text.trim().isNotEmpty;
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                                onPressed: _deepening ? null : _onNext,
                                child: const Text(
                                  'التالي',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.accentColor),
                                ),
                                onPressed: _deepening || !hasAnswer ? null : _onDeepen,
                                child: _deepening
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        'عمّق أكثر',
                                        style: TextStyle(color: AppTheme.accentColor),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
