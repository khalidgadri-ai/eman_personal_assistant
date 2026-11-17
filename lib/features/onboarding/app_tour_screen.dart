import 'package:flutter/material.dart';
import '../../core/ai/ai_settings_service.dart';
import '../../core/ai/provider_presets.dart';
import '../../core/services/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_provider_screen.dart';
import '../../core/widgets/api_key_guide.dart';
import '../../core/widgets/page_dots.dart';

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

const List<_TourPage> _pages = [
  _TourPage(
    icon: Icons.explore_rounded,
    title: 'جولة قصيرة',
    lines: [
      'سنعرّفك على التطبيق في 10 صفحات قصيرة.',
      'في كل صفحة فكرة واحدة فقط.',
      'يمكنك الرجوع لأي صفحة بزر «رجوع».',
    ],
  ),
  _TourPage(
    icon: Icons.task_alt_rounded,
    title: 'الأهداف والمهام',
    lines: [
      'اكتب مهمة صغيرة واحدة بزر «+».',
      'حين تنتهي منها، ضع علامة ✓ بجانبها.',
    ],
    example: 'مثال: «اشترِ الخبز».',
  ),
  _TourPage(
    icon: Icons.stairs_rounded,
    title: 'قسّم الكبير إلى صغير',
    lines: [
      'الهدف الكبير يصبح سهلًا إذا قسّمته.',
      'حرّك شريط التقدّم كلما أنجزت جزءًا.',
    ],
    example: 'مثال: «ترتيب البيت» هدف شهري، و«ترتيب غرفة النوم» هدف أسبوعي، '
        'و«ترتيب درج واحد» مهمة اليوم.',
  ),
  _TourPage(
    icon: Icons.notifications_active_rounded,
    title: 'التذكير',
    lines: [
      'يمكنك أن تضع وقتًا للمهمة أو للدواء فيصلك تنبيه.',
      'حين يسألك الجوال عن الإشعارات اضغط «السماح».',
      'قد يتأخر التنبيه دقائق قليلة.',
    ],
  ),
  _TourPage(
    icon: Icons.fitness_center_rounded,
    title: 'الصحة واللياقة',
    lines: ['سجّل تمارينك، ومواعيد أدويتك، وروتين العناية.'],
    example: 'مثال: دواء الصباح الساعة 8.',
  ),
  _TourPage(
    icon: Icons.kitchen_rounded,
    title: 'المطبخ والمنزل',
    lines: [
      'وصفاتك، وما عندك في البيت، وقائمة المشتريات، وجدول الغسيل.',
      'ما ينقص من البيت يمكنك نقله إلى المشتريات.',
    ],
  ),
  _TourPage(
    icon: Icons.account_balance_wallet_rounded,
    title: 'الميزانية',
    lines: [
      'اكتب دخلك ومصاريفك الثابتة مرة واحدة، فيحسب لك التطبيق كم يمكنك أن تصرف اليوم.',
      'كل الأرقام تبقى على جوالك.',
    ],
  ),
  _TourPage(
    icon: Icons.smart_toy_rounded,
    title: 'المدرب والمساعد الذكي',
    lines: [
      'زر المدرب (أيقونة الرأس في أسفل وسط الشاشة) يسألك أسئلة تساعدك تفكّر وترتّب أمورك.',
      'أما المساعد الذكي فيجيب أسئلتك، لكنه يحتاج مفتاحًا: الصفحة التالية تشرح كيف تحصل عليه.',
    ],
  ),
  _TourPage(
    icon: Icons.vpn_key_rounded,
    title: 'مفتاح الذكاء الاصطناعي',
    lines: [],
  ),
  _TourPage(
    icon: Icons.flag_rounded,
    title: 'ابدأ بخطوة واحدة',
    lines: [
      'لا تحاول ترتيب كل شيء اليوم.',
      'اختر شيئًا صغيرًا واحدًا وابدأ به.',
      'يمكنك إعادة هذه الجولة من الإعدادات.',
    ],
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

  static int get pageCount => _pages.length;

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  int _page = 0;
  bool _finishing = false;

  bool get _isLast => _page == _pages.length - 1;

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
    setState(() => _finishing = true);
    try {
      final db = await DatabaseService.getInstance();
      await db.saveAppTourVersion(AppTour.version);
    } catch (e) {
      // لا نحبس المستخدم: يكمل، وقد تظهر الجولة مرة أخرى في التشغيل التالي.
      debugPrint('AppTourScreen: could not save the tour version (${e.runtimeType})');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر حفظ إنهاء الجولة على جهازك.')),
        );
      }
    }
    if (!mounted) return;
    widget.onFinished?.call();
  }

  Future<void> _addKeyNow() async {
    final saved = await widget.addKey(context);
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ تم حفظ المفتاح')));
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: widget.mandatory
            ? null
            : AppBar(
                title: const Text('جولة التعريف بالتطبيق'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    tooltip: 'إغلاق',
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
                  'صفحة ${_page + 1} من ${_pages.length}',
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                PageDots(page: _page, count: _pages.length),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('tour_page_$_page'),
                    // بعرض الشاشة كله حتى يبدأ النص من الحافة اليمنى في كل الصفحات.
                    child: SizedBox(width: double.infinity, child: _buildPage(page)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildButtons(),
              ],
            ),
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
          child: const Text('أضف المفتاح الآن', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _next,
          child: const Text('سأضيفه لاحقًا', style: TextStyle(color: AppTheme.subTextColor, fontSize: 16)),
        ),
      ),
    ];
  }

  Widget _buildButtons() {
    final String nextLabel;
    if (!_isLast) {
      nextLabel = 'التالي';
    } else {
      nextLabel = widget.mandatory ? 'ابدأ استعمال التطبيق' : 'إنهاء';
    }
    return Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: _page == 0 ? null : _back,
          child: const Text('رجوع'),
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
