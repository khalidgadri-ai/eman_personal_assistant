import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_events.dart';
import 'core/config/app_contact.dart';
import 'core/config/app_locale.dart';
import 'core/services/contact_service.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/subscription_service.dart';
import 'core/theme/app_theme.dart';
import 'features/goals_and_tasks/goals_tasks_screen.dart';
import 'features/health_and_fitness/health_fitness_screen.dart';
import 'features/kitchen_and_home/kitchen_home_screen.dart';
import 'features/financial/financial_screen.dart';
import 'features/ai_assistant/ai_assistant_screen.dart';
import 'features/coach/coach_screen.dart';
import 'features/onboarding/app_tour_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reminders/reminder_service.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await _loadLanguage();
  runApp(const EmanLifeApp());
  unawaited(_startSubscriptionChecks());
  unawaited(_startReminders());
}

// لغة المستخدم قبل أول إطار، فلا تظهر الشاشة الأولى بلغة ثم تتبدل.
Future<void> _loadLanguage() async {
  try {
    AppLocale.choice.value = AppLocale.parse((await DatabaseService.getInstance()).getAppLanguage());
  } catch (e) {
    debugPrint('Language setting unavailable (${e.runtimeType})');
  }
}

// تهيئة الإشعارات ثم إعادة جدولة تذكيرات المستخدم من بياناته الحالية (فيصحّ أي تغيّر في توقيت الجهاز).
Future<void> _startReminders() async {
  await NotificationService.init();
  await ReminderService.syncAll();
}

// استماع مبكر لمشتريات Google Play: أي اشتراك لا يُؤكَّد خلال 3 أيام يُسترد تلقائيًا.
Future<void> _startSubscriptionChecks() async {
  try {
    final subscription = await SubscriptionService.getInstance();
    await subscription.restore();
  } catch (e) {
    debugPrint('Subscription startup check: $e');
  }
}

class EmanLifeApp extends StatelessWidget {
  const EmanLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocale.choice,
      builder: (context, choice, _) => MaterialApp(
        title: 'إيمان',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        locale: AppLocale.resolve(choice, WidgetsBinding.instance.platformDispatcher.locale),
        supportedLocales: AppLocale.supported,
        localizationsDelegates: AppLocale.delegates,
        home: const AppGate(),
      ),
    );
  }
}

enum _GateState { loading, onboarding, tour, ready }

Future<int> _readTourVersion() async => (await DatabaseService.getInstance()).getAppTourVersion();

/// أول تشغيل: شاشة الترحيب، ثم جولة التعريف الإجبارية (إن لم تُرَ على هذا الجهاز)، ثم التطبيق.
/// بعد "مسح كل بياناتي" يعيد قراءة الحالة فيعود الترحيب ثم الجولة، واستعادة نسخة احتياطية
/// تعيد بناء الشاشات ببياناتها (والجولة لا تعود لمن رآها: رقمها خارج النسخة).
class AppGate extends StatefulWidget {
  /// [readTourVersion] يُستبدل في الاختبارات فقط.
  const AppGate({super.key, this.readTourVersion = _readTourVersion});

  final Future<int> Function() readTourVersion;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  _GateState _state = _GateState.loading;

  /// أنهى الجولة في هذا التشغيل. إن فشل حفظ رقمها لا تُعاد عليه قبل التشغيل التالي.
  bool _tourDoneThisRun = false;

  @override
  void initState() {
    super.initState();
    AppEvents.dataErased.addListener(_onDataErased);
    AppEvents.dataRestored.addListener(_onDataChanged);
    _load();
  }

  @override
  void dispose() {
    AppEvents.dataErased.removeListener(_onDataErased);
    AppEvents.dataRestored.removeListener(_onDataChanged);
    super.dispose();
  }

  /// بعد المسح تعود الجولة مع الترحيب.
  void _onDataErased() {
    _tourDoneThisRun = false;
    _onDataChanged();
  }

  /// بعد المسح أو استعادة نسخة احتياطية: إعادة قراءة الحالة (ترحيب أو التطبيق ببياناته الجديدة).
  void _onDataChanged() {
    setState(() => _state = _GateState.loading);
    _load();
  }

  void _onTourFinished() {
    _tourDoneThisRun = true;
    _load();
  }

  Future<void> _load() async {
    var next = _GateState.ready;
    try {
      final profile = await ProfileService.getInstance();
      if (!profile.onboarded) next = _GateState.onboarding;
    } catch (e) {
      // ملف مشفّر تعذّر فتحه: لا نحبس المستخدم خارج التطبيق.
      debugPrint('AppGate: profile unavailable (${e.runtimeType})');
    }
    if (next == _GateState.ready && !_tourDoneThisRun) {
      try {
        if (!AppTour.isSeen(await widget.readTourVersion())) next = _GateState.tour;
      } catch (e) {
        // تعذّرت القراءة: يفتح التطبيق مباشرة بدل أن يحبس المستخدم في الجولة.
        debugPrint('AppGate: tour state unavailable (${e.runtimeType})');
      }
    }
    if (!mounted) return;
    setState(() => _state = next);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _GateState.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
      _GateState.onboarding => OnboardingScreen(onFinished: _load),
      _GateState.tour => AppTourScreen(mandatory: true, onFinished: _onTourFinished),
      _GateState.ready => const MainNavigationScreen(),
    };
  }
}

class MainNavigationScreen extends StatefulWidget {
  /// [supportEmail] و[mailOpener] يُستبدلان في الاختبارات فقط. بلا بريد دعم يختفي زر "تواصل معنا".
  const MainNavigationScreen({
    super.key,
    this.supportEmail = AppContact.supportEmail,
    this.mailOpener = openMailApp,
  });

  final String supportEmail;
  final MailOpener mailOpener;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  /// تبويب المساعد الذكي: خانة الكتابة في أسفله، فلا تظهر فوقها الأزرار العائمة.
  static const int _assistantTab = 4;

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    GoalsTasksScreen(),
    HealthFitnessScreen(),
    KitchenHomeScreen(),
    FinancialScreen(),
    AIAssistantScreen(),
  ];

  /// يفتح تطبيق البريد برسالة جديدة. لو لم يوجد تطبيق بريد يظهر العنوان ليُنسخ.
  Future<void> _contactUs() async {
    final email = widget.supportEmail;
    final opened = await widget.mailOpener(email, AppContact.subject);
    if (opened || !mounted) return;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(l10n.contactUs, style: const TextStyle(color: AppTheme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contactMailFailed,
              style: const TextStyle(color: AppTheme.subTextColor, height: 1.6),
            ),
            const SizedBox(height: 8),
            SelectableText(
              email,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: AppTheme.accentColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close, style: const TextStyle(color: AppTheme.subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: email));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(l10n.copyAddress, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _currentIndex == _assistantTab
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'coach_fab',
                  tooltip: l10n.coachTooltip,
                  backgroundColor: AppTheme.primaryColor,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CoachScreen()),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white),
                ),
                if (widget.supportEmail.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'contact_fab',
                    tooltip: l10n.contactUs,
                    backgroundColor: AppTheme.accentColor,
                    onPressed: _contactUs,
                    child: const Icon(Icons.mail_outline_rounded, color: Colors.white),
                  ),
                ],
              ],
            ),
      // الاتجاه من لغة التطبيق (MaterialApp): من اليمين للعربية ومن اليسار للإنجليزية.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_alt_rounded),
            label: l10n.navGoals,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_rounded),
            label: l10n.navHealth,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.kitchen_rounded),
            label: l10n.navKitchen,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.navBudget,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_rounded),
            label: l10n.navAssistant,
          ),
        ],
      ),
    );
  }
}
