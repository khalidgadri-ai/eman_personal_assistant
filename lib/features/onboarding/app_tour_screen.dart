import 'package:flutter/material.dart';
import '../../core/ai/ai_settings_service.dart';
import '../../core/ai/provider_presets.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/api_key_guide.dart';
import '../../core/widgets/page_dots.dart';
import '../../l10n/l10n.dart';

/// رقم الجولة الحالية. رفعه يُظهر جولة جديدة لمن رأى القديمة.
abstract final class AppTour {
  static const int version = 1;

  /// الجولة «مرئية» إذا كان الرقم المحفوظ يساوي الحالي أو أكبر.
  static bool isSeen(int savedVersion) => savedVersion >= version;
}

/// يفتح شاشة المزوّد ويرجّع true إن صار المزوّد مضبوطًا بمفتاح بعد الرجوع.
typedef AddKeyFlow = Future<bool> Function(BuildContext context);

Future<bool> _openProviderScreen(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AiProviderScreen()),
  );
  try {
    final settings = await AiSettingsService.getInstance();
    final selected = settings.selected;
    return selected != null && await settings.hasKey(selected.id);
  } catch (e) {
    debugPrint('AppTourScreen: AI settings unavailable (${e.runtimeType})');
    return false;
  }
}

class _TourPage {
  const _TourPage({required this.icon, required this.title, required this.lines, this.example});

  final IconData icon;
  final String title;
  final List<String> lines;
  final String? example;
}

/// صفحة المفتاح لها محتوى خاص (الدليل والأزرار)، فتُعرف برقمها.
const int _keyPageIndex = 8;

/// عدد صفحات الجولة. نص كل صفحة في ملفات اللغات ([_pages]).
const int _pageCount = 10;

List<_TourPage> _pages(AppLocalizations l10n) => [
      _TourPage(
        icon: Icons.explore_rounded,
        title: l10n.tourIntroTitle,
        lines: [l10n.tourIntro1, l10n.tourIntro2, l10n.tourIntro3],
      ),
      _TourPage(
        icon: Icons.task_alt_rounded,
        title: l10n.tourTasksTitle,
        lines: [l10n.tourTasks1, l10n.tourTasks2],
        example: l10n.tourTasksExample,
      ),
      _TourPage(
        icon: Icons.stairs_rounded,
        title: l10n.tourGoalsTitle,
        lines: [l10n.tourGoals1, l10n.tourGoals2],
        example: l10n.tourGoalsExample,
      ),
      _TourPage(
        icon: Icons.notifications_active_rounded,
        title: l10n.tourRemindersTitle,
        lines: [l10n.tourReminders1, l10n.tourReminders2, l10n.tourReminders3],
      ),
      _TourPage(
        icon: Icons.fitness_center_rounded,
        title: l10n.tourHealthTitle,
        lines: [l10n.tourHealth1],
        example: l10n.tourHealthExample,
      ),
      _TourPage(
        icon: Icons.kitchen_rounded,
        title: l10n.tourKitchenTitle,
        lines: [l10n.tourKitchen1, l10n.tourKitchen2],
      ),
      _TourPage(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.tourBudgetTitle,
        lines: [l10n.tourBudget1, l10n.tourBudget2],
      ),
      _TourPage(
        icon: Icons.smart_toy_rounded,
        title: l10n.tourCoachTitle,
        lines: [l10n.tourCoach1, l10n.tourCoach2],
      ),
      _TourPage(
        icon: Icons.vpn_key_rounded,
        title: l10n.tourKeyTitle,
        lines: const [],
      ),
      _TourPage(
        icon: Icons.flag_rounded,
        title: l10n.tourStartTitle,
        lines: [l10n.tourStart1, l10n.tourStart2, l10n.tourStart3],
      ),
    ];

/// جولة التعريف بالتطبيق: صفحات بملء الشاشة، صفحة لكل فكرة.
///
/// [mandatory] من البوابة: بلا تخطٍ ولا إغلاق، وآخر صفحة تحفظ [AppTour.version] ثم تستدعي
/// [onFinished]. وبدونه (من الإعدادات): زر إغلاق، وآخر صفحة تغلق الشاشة.
class AppTourScreen extends StatefulWidget {
  const AppTourScreen({
    super.key,
    required this.mandatory,
    this.onFinished,
    this.linkOpener = openExternalLink,
    this.addKey = _openProviderScreen,
  });

  final bool mandatory;
  final VoidCallback? onFinished;

  /// يُستبدلان في الاختبارات فقط.
  final LinkOpener linkOpener;
  final AddKeyFlow addKey;

  static int get pageCount => _pageCount;

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  int _page = 0;
  bool _finishing = false;

  bool get _isLast => _page == _pageCount - 1;

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() => _page++);
  }

  void _back() {
    if (_page > 0) setState(() => _page--);
  }

  Future<void> _finish() async {
    if (!widget.mandatory) {
      Navigator.of(context).pop();
      return;
    }
    if (_finishing) return;
    final failed = context.l10n.tourSaveFailed;
    setState(() => _finishing = true);
    try {
      final db = await DatabaseService.getInstance();
      await db.saveAppTourVersion(AppTour.version);
    } catch (e) {
      // لا نحبس المستخدم: يكمل، وقد تظهر الجولة مرة أخرى في التشغيل التالي.
      debugPrint('AppTourScreen: could not save the tour version (${e.runtimeType})');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failed)));
      }
    }
    if (!mounted) return;
    widget.onFinished?.call();
  }

  Future<void> _addKeyNow() async {
    final saved = await widget.addKey(context);
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.tourKeySaved)));
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final page = _pages(l10n)[_page];
    return Scaffold(
      appBar: widget.mandatory
          ? null
          : AppBar(
              title: Text(l10n.settingsTour),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  tooltip: l10n.close,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              Text(
                l10n.tourPageOf(_page + 1, _pageCount),
                style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 8),
              PageDots(page: _page, count: _pageCount),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey('tour_page_$_page'),
                  // بعرض الشاشة كله حتى يبدأ النص من حافة بداية السطر في كل الصفحات.
                  child: SizedBox(width: double.infinity, child: _buildPage(page)),
                ),
              ),
              const SizedBox(height: 8),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_TourPage page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Icon(page.icon, size: 64, color: AppTheme.accentColor),
        const SizedBox(height: 16),
        Text(
          page.title,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final line in page.lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line, style: const TextStyle(color: AppTheme.textColor, fontSize: 17, height: 1.7)),
          ),
        if (page.example case final example?)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(example, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 15, height: 1.7)),
          ),
        if (_page == _keyPageIndex) ..._buildKeyPage(),
      ],
    );
  }

  List<Widget> _buildKeyPage() {
    return [
      ApiKeyGuide(preset: AiPresets.byId(AiPresets.geminiId), linkOpener: widget.linkOpener),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            minimumSize: const Size(0, 48),
          ),
          onPressed: _addKeyNow,
          child: Text(context.l10n.tourAddKeyNow, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _next,
          child: Text(context.l10n.tourAddKeyLater, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 16)),
        ),
      ),
    ];
  }

  Widget _buildButtons() {
    final l10n = context.l10n;
    final String nextLabel;
    if (!_isLast) {
      nextLabel = l10n.next;
    } else {
      nextLabel = widget.mandatory ? l10n.tourFinishFirstRun : l10n.tourFinish;
    }
    return Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: _page == 0 ? null : _back,
          child: Text(l10n.back),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            minimumSize: const Size(120, 48),
          ),
          onPressed: _finishing ? null : _next,
          child: Text(nextLabel, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
