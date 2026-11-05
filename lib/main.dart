import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_events.dart';
import 'core/config/app_contact.dart';
import 'core/services/contact_service.dart';
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
import 'features/onboarding/onboarding_screen.dart';
import 'features/reminders/reminder_service.dart';

Future<void> main() async {
  await Hive.initFlutter();
  runApp(const EmanLifeApp());
  unawaited(_startSubscriptionChecks());
  unawaited(_startReminders());
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
    return MaterialApp(
      title: 'إيمان',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppGate(),
    );
  }
}

enum _GateState { loading, onboarding, ready }

/// أول تشغيل: يعرض شاشة الترحيب، وبعد إكمالها (أو "تخطي") يفتح التطبيق. بعد
/// "مسح كل بياناتي" يعيد قراءة الحالة فيعود الترحيب من جديد، واستعادة نسخة احتياطية تعيد
/// بناء الشاشات ببياناتها.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  _GateState _state = _GateState.loading;

  @override
  void initState() {
    super.initState();
    AppEvents.dataErased.addListener(_onDataChanged);
    AppEvents.dataRestored.addListener(_onDataChanged);
    _load();
  }

  @override
  void dispose() {
    AppEvents.dataErased.removeListener(_onDataChanged);
    AppEvents.dataRestored.removeListener(_onDataChanged);
    super.dispose();
  }

  /// بعد المسح أو استعادة نسخة احتياطية: إعادة قراءة الحالة (ترحيب أو التطبيق ببياناته الجديدة).
  void _onDataChanged() {
    setState(() => _state = _GateState.loading);
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
    if (!mounted) return;
    setState(() => _state = next);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _GateState.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
      _GateState.onboarding => OnboardingScreen(onFinished: _load),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('تواصل معنا', style: TextStyle(color: AppTheme.textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لم يُفتح تطبيق البريد. يمكنك مراسلتنا على هذا العنوان:',
                style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
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
              child: const Text('إغلاق', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: email));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('نسخ العنوان', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'coach_fab',
            tooltip: 'مدرب الحياة',
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
              tooltip: 'تواصل معنا',
              backgroundColor: AppTheme.accentColor,
              onPressed: _contactUs,
              child: const Icon(Icons.mail_outline_rounded, color: Colors.white),
            ),
          ],
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              label: 'الأهداف والمهام',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'الصحة واللياقة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen_rounded),
              label: 'المطبخ والمنزل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'الميزانية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'المساعد الذكي',
            ),
          ],
        ),
      ),
    );
  }
}
