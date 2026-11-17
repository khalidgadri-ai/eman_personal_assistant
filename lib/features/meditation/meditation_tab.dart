import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import '../coach/coach_paywall_screen.dart';
import '../health_and_fitness/health_service.dart';
import 'meditation_catalog.dart';
import 'meditation_player.dart';
import 'meditation_session_screen.dart';
import 'models/meditation_session.dart';
import 'session_planner.dart';

typedef MeditationPlayerBuilder = MeditationPlayer Function();

Future<bool> _verifySubscription() async {
  try {
    return await (await SubscriptionService.getInstance()).verify();
  } catch (e) {
    debugPrint('MeditationTab: subscription check failed (${e.runtimeType})');
    return false;
  }
}

Future<bool> _openPaywall(BuildContext context) async {
  final subscribed = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const CoachPaywallScreen(feature: PaywallFeature.meditation)),
  );
  return subscribed == true;
}

/// ملاحظات السلامة: تظهر مرة واحدة لكل نوع قبل أول استعمال.
const String gammaNoticeKind = 'gamma';
const String activeNoticeKind = 'active';

const String gammaNoticeText =
    'نغمة جاما للاستماع أثناء التأمل، بمستوى صوت منخفض. لا تُستعمل أثناء القيادة أو تشغيل الآلات. '
    'من لديه صرع أو جهاز طبي مزروع يستشير الطبيب قبل الاستعمال. النوع المزدوج يحتاج سماعات.';

const String activeNoticeText =
    'الحركة بلطف، في مكان واسع وآمن، والتوقف عند الدوخة أو الألم. من لديه حالة قلبية أو حمل أو '
    'إصابة يستشير الطبيب قبل هذه الجلسة.';

/// قسم «التأمل» في الصحة واللياقة: قائمة الجلسات ودقائق آخر 7 أيام.
class MeditationTab extends StatefulWidget {
  /// كلها تُستبدل في الاختبارات فقط؛ الأصل هو المشغّل الحقيقي والاشتراك الحقيقي.
  const MeditationTab({
    super.key,
    this.playerBuilder = AudioMeditationPlayer.new,
    this.loadSessions = _loadSessions,
    this.loadAssets = _loadAssets,
    this.checkSubscription = _verifySubscription,
    this.openPaywall = _openPaywall,
    this.clock = DateTime.now,
  });

  final MeditationPlayerBuilder playerBuilder;
  final Future<List<MeditationSession>> Function() loadSessions;
  final Future<Set<String>> Function() loadAssets;
  final Future<bool> Function() checkSubscription;
  final Future<bool> Function(BuildContext context) openPaywall;
  final DateTime Function() clock;

  static Future<List<MeditationSession>> _loadSessions() => MeditationCatalog.load();
  static Future<Set<String>> _loadAssets() => MeditationCatalog.bundledAssets();

  @override
  State<MeditationTab> createState() => _MeditationTabState();
}

class _MeditationTabState extends State<MeditationTab> with AutomaticKeepAliveClientMixin {
  List<MeditationSession>? _sessions;
  int _weekMinutes = 0;
  bool _failed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await widget.loadSessions();
      final assets = await widget.loadAssets();
      final minutes = await _readWeekMinutes();
      if (!mounted) return;
      setState(() {
        _sessions = MeditationCatalog.available(all, assets);
        _weekMinutes = minutes;
        _failed = false;
      });
    } catch (e) {
      debugPrint('MeditationTab: could not load sessions (${e.runtimeType})');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// آخر 7 أيام شاملة اليوم، من بداية اليوم الأول.
  Future<int> _readWeekMinutes() async {
    try {
      final now = widget.clock();
      final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      return (await HealthService.getInstance()).meditationMinutesSince(from);
    } catch (e) {
      debugPrint('MeditationTab: could not read the log (${e.runtimeType})');
      return 0;
    }
  }

  Future<void> _open(MeditationSession session) async {
    if (session.isPremium && !await widget.checkSubscription()) {
      if (!mounted || !await widget.openPaywall(context)) return;
    }
    if (!mounted) return;
    final choice = await showModalBottomSheet<_SessionChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (_) => _SetupSheet(session: session),
    );
    if (choice == null || !mounted) return;

    final plan = planSession(
      session,
      minutes: choice.minutes,
      background: session.backgroundIsChosen ? choice.background : null,
    );
    if (plan.usesGamma && !await _ensureNotice(gammaNoticeKind, gammaNoticeText)) return;
    if (session.kind == MeditationKind.active && !await _ensureNotice(activeNoticeKind, activeNoticeText)) return;
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MeditationSessionScreen(plan: plan, player: widget.playerBuilder()),
      ),
    );
    final minutes = await _readWeekMinutes();
    if (mounted) setState(() => _weekMinutes = minutes);
  }

  /// يعرض ملاحظة السلامة إن لم تُرَ من قبل. false إن تراجع المستخدم.
  Future<bool> _ensureNotice(String kind, String text) async {
    DatabaseService? db;
    try {
      db = await DatabaseService.getInstance();
      if (db.hasSeenMeditationNotice(kind)) return true;
    } catch (e) {
      debugPrint('MeditationTab: notice state unavailable (${e.runtimeType})');
    }
    if (!mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('ملاحظة قبل البدء', style: TextStyle(color: AppTheme.textColor)),
          content: Text(text, style: const TextStyle(color: AppTheme.subTextColor, height: 1.7)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('رجوع', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('فهمت، ابدأ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return false;
    try {
      await db?.markMeditationNoticeSeen(kind);
    } catch (e) {
      debugPrint('MeditationTab: could not save the notice (${e.runtimeType})');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sessions = _sessions;
    if (_failed) {
      return Center(
        child: TextButton(
          onPressed: _load,
          child: const Text('تعذّر فتح جلسات التأمل. إعادة المحاولة', style: TextStyle(color: AppTheme.accentColor)),
        ),
      );
    }
    if (sessions == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          'دقائق التأمل في آخر 7 أيام: $_weekMinutes',
          style: const TextStyle(color: AppTheme.accentColor, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'الصوت يستمر والشاشة مطفأة، ويمكن الإيقاف من الإشعار.',
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 12),
        ),
        const SizedBox(height: 12),
        for (final session in sessions) _SessionCard(session: session, onTap: () => _open(session)),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final MeditationSession session;
  final VoidCallback onTap;

  IconData get _icon => switch (session.kind) {
        MeditationKind.guided => Icons.self_improvement_rounded,
        MeditationKind.active => Icons.directions_walk_rounded,
        MeditationKind.gamma => Icons.graphic_eq_rounded,
        MeditationKind.silent => Icons.notifications_none_rounded,
      };

  String get _durations {
    final d = session.durations;
    // «من … إلى» بدل الشرطة: الأرقام حول الشرطة تنقلب في سطر عربي.
    return d.length == 1 ? '${d.first} دقيقة' : 'من ${d.first} إلى ${d.last} دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 32, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (session.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 12, color: AppTheme.accentColor),
                                SizedBox(width: 4),
                                Text('مع الاشتراك', style: TextStyle(color: AppTheme.accentColor, fontSize: 11)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.description,
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    Text(_durations, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionChoice {
  const _SessionChoice(this.minutes, this.background);

  final int minutes;
  final ToneBackground background;
}

/// اختيار المدة، والخلفية في المؤقت الصامت وجلسة جاما.
class _SetupSheet extends StatefulWidget {
  const _SetupSheet({required this.session});

  final MeditationSession session;

  @override
  State<_SetupSheet> createState() => _SetupSheetState();
}

class _SetupSheetState extends State<_SetupSheet> {
  late int _minutes = widget.session.durations.first;
  late ToneBackground _background = defaultBackgroundFor(widget.session);

  List<(ToneBackground, String)> get _backgrounds => switch (widget.session.kind) {
        MeditationKind.silent => const [
            (ToneBackground.none, 'بلا نغمة'),
            (ToneBackground.gammaBinaural, 'جاما مزدوجة (سماعات)'),
            (ToneBackground.gammaIsochronic, 'جاما نبضية'),
          ],
        MeditationKind.gamma => const [
            (ToneBackground.gammaBinaural, 'مزدوجة (سماعات)'),
            (ToneBackground.gammaIsochronic, 'نبضية (بلا سماعات)'),
          ],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.session.title,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('المدة', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in widget.session.durations)
                    ChoiceChip(
                      label: Text('$minutes د'),
                      selected: _minutes == minutes,
                      onSelected: (_) => setState(() => _minutes = minutes),
                    ),
                ],
              ),
              if (_backgrounds.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('الصوت في الخلفية', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (background, label) in _backgrounds)
                      ChoiceChip(
                        label: Text(label),
                        selected: _background == background,
                        onSelected: (_) => setState(() => _background = background),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(0, 52),
                  ),
                  onPressed: () => Navigator.of(context).pop(_SessionChoice(_minutes, _background)),
                  child: const Text('ابدأ الجلسة', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
