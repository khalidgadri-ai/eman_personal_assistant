import 'package:flutter/material.dart';
import '../../core/services/contact_service.dart';
import '../../core/services/free_quota_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import 'coach_ai_service.dart';
import 'coach_history_screen.dart';
import 'coach_paywall_screen.dart';
import 'coach_quota_text.dart';
import 'coach_safety.dart';
import 'coach_session_service.dart';
import 'coach_signal_service.dart';
import 'models/coach_question.dart';

/// يتأكد أن مزوّد الذكاء الاصطناعي مُعدّ (ويعرض شاشة الإعداد إن لم يكن). false إن غادر المستخدم دون إعداد.
typedef CoachAiAccess = Future<bool> Function(BuildContext context);

Future<bool> _requireConfiguredAi(BuildContext context) async =>
    await requireAiService(context) != null;

/// كيف سُمح بطلب سؤال المتابعة: اشتراك فعّال، أو استعمال من الحصة المجانية الشهرية.
enum _DeepenAccess { subscriber, free }

String? _deviceCountryCode() => WidgetsBinding.instance.platformDispatcher.locale.countryCode;

class CoachScreen extends StatefulWidget {
  /// المعاملات للاختبارات فقط؛ الأصل هو الخدمة الحقيقية وساعة الجهاز ومنطقته والمتصفح.
  const CoachScreen({
    super.key,
    this.aiService,
    this.clock = DateTime.now,
    this.aiAccess = _requireConfiguredAi,
    this.countryCode = _deviceCountryCode,
    this.openLink = openExternalLink,
  });

  final CoachAiService? aiService;
  final DateTime Function() clock;
  final CoachAiAccess aiAccess;
  final String? Function() countryCode;
  final LinkOpener openLink;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  CoachSessionService? _service;
  late final CoachAiService _aiService = widget.aiService ?? CoachAiService();
  SubscriptionService? _subscription;
  FreeQuotaService? _quota;
  String? _quotaLine;
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
    final question = await service.showNextQuestion(domain);
    try {
      _subscription = await SubscriptionService.getInstance();
      _quota = await FreeQuotaService.getInstance();
    } catch (e) {
      // بلا سطر الحصة فقط؛ المدرب نفسه يعمل.
      debugPrint('CoachScreen: quota state unavailable (${e.runtimeType})');
    }
    if (!mounted) return;
    setState(() {
      _quotaLine = _buildQuotaLine();
      _service = service;
      _selectedDomain = domain;
      _currentQuestion = question;
      _signalHint = signals.hintFor(domain);
      _loading = false;
    });
  }

  Future<void> _onDomainChanged(CoachDomain domain) async {
    final service = _service;
    if (service == null) return;
    final question = await service.showNextQuestion(domain);
    if (!mounted) return;
    setState(() {
      _selectedDomain = domain;
      _currentQuestion = question;
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
    final next = await service.showNextQuestion(_selectedDomain);

    if (!mounted) return;
    setState(() {
      _currentQuestion = next;
      _signalHint = null;
      _answerController.clear();
    });
  }

  /// السطر تحت «عمّق أكثر»: لغير المشترك فقط. الحالة المحفوظة (بلا اتصال) تكفي لعرضه.
  String? _buildQuotaLine() {
    final subscription = _subscription;
    final quota = _quota;
    if (subscription == null || quota == null || subscription.isActive) return null;
    final now = widget.clock();
    return coachQuotaLine(
      remaining: quota.remaining(FreeQuotaService.coachFollowUp, now),
      now: now,
    );
  }

  void _refreshQuotaLine() {
    if (!mounted) return;
    setState(() => _quotaLine = _buildQuotaLine());
  }

  Future<void> _onDeepen() async {
    final service = _service;
    final question = _currentQuestion;
    final answer = _answerController.text.trim();
    if (service == null || question == null || answer.isEmpty) return;

    // فحص الأزمة أولًا دائمًا، قبل أي شاشة اشتراك أو طلب للموديل.
    if (containsCrisisSignals(answer)) {
      await _showCrisisDialog();
      return;
    }

    final access = await _resolveAccess();
    if (access == null || !mounted) {
      _refreshQuotaLine();
      return;
    }

    if (!await widget.aiAccess(context) || !mounted) {
      _refreshQuotaLine();
      return;
    }

    setState(() => _deepening = true);
    final result = await _aiService.requestFollowUp(question: question, answer: answer);
    if (!mounted) return;

    switch (result) {
      case CrisisDetected():
        setState(() => _deepening = false);
        await _showCrisisDialog();
      case FollowUpQuestion(question: final followUp):
        await service.saveSession(question: question, answerText: answer);
        // يُحتسب الاستعمال المجاني فقط إذا جاء السؤال فعلًا من الموديل، لا من البنك المحلي.
        if (access == _DeepenAccess.free && followUp.id == CoachAiService.aiFollowUpId) {
          await _consumeFreeUse();
        }
        if (!mounted) return;
        setState(() {
          _currentQuestion = followUp;
          _signalHint = null;
          _answerController.clear();
          _deepening = false;
        });
    }
    _refreshQuotaLine();
  }

  /// مشترك فعّال، أو غير مشترك بقي له استعمال مجاني: يكمل. وإلا تظهر شاشة الاشتراك.
  /// null إذا لم يكمل (رجع المستخدم من شاشة الاشتراك دون اشتراك).
  Future<_DeepenAccess?> _resolveAccess() async {
    setState(() => _deepening = true);
    final subscription = await SubscriptionService.getInstance();
    final active = await subscription.verify();
    final quota = await _loadQuota();
    if (!mounted) return null;
    setState(() => _deepening = false);
    if (active) return _DeepenAccess.subscriber;

    final now = widget.clock();
    if (quota != null && quota.remaining(FreeQuotaService.coachFollowUp, now) > 0) {
      return _DeepenAccess.free;
    }

    final subscribed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CoachPaywallScreen(quotaExhaustedAt: now)),
    );
    return subscribed == true ? _DeepenAccess.subscriber : null;
  }

  Future<FreeQuotaService?> _loadQuota() async {
    try {
      return _quota ??= await FreeQuotaService.getInstance();
    } catch (e) {
      debugPrint('CoachScreen: free quota unavailable (${e.runtimeType})');
      return null;
    }
  }

  /// فشل الحفظ لا يمنع المستخدم من سؤاله الذي وصل فعلًا.
  Future<void> _consumeFreeUse() async {
    try {
      await _quota?.consume(FreeQuotaService.coachFollowUp, widget.clock());
    } catch (e) {
      debugPrint('CoachScreen: could not count the free use (${e.runtimeType})');
    }
  }

  Future<void> _showCrisisDialog() async {
    final general = <Widget>[
      const Text(
        crisisLocalEmergencyMessage,
        style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600, height: 1.6),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentColor)),
        onPressed: () => widget.openLink(crisisHelplineFinderUrl),
        icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.accentColor),
        label: const Text(crisisHelplineFinderLabel, style: TextStyle(color: AppTheme.accentColor)),
      ),
      const SizedBox(height: 16),
    ];
    final saudi = <Widget>[
      const Text(
        crisisHelplinesNote,
        style: TextStyle(color: AppTheme.subTextColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
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
    ];
    final saudiFirst = showSaudiHelplinesFirst(widget.countryCode());

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
                ...saudiFirst ? [...saudi, ...general] : [...general, ...saudi],
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
              tooltip: 'سجل جلسات المدرب',
              icon: const Icon(Icons.history_rounded, color: AppTheme.accentColor),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CoachHistoryScreen()),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildQuestionArea(),
                    ),
                  ),
                  // الأزرار خارج منطقة التمرير: تبقى فوق لوحة المفاتيح على الجوالات الصغيرة.
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: _buildActions(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'هذه أداة تأمل ذاتي، وليست بديلًا عن معالج نفسي مرخّص.',
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
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        if (_quotaLine case final line?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                line,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
