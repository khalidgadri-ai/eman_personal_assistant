import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/database_service.dart';
import 'core/services/subscription_service.dart';
import 'core/theme/app_theme.dart';
import 'features/goals_and_tasks/goals_tasks_screen.dart';
import 'features/health_and_fitness/health_fitness_screen.dart';
import 'features/kitchen_and_home/kitchen_home_screen.dart';
import 'features/financial/financial_screen.dart';
import 'features/ai_assistant/ai_assistant_screen.dart';
import 'features/coach/coach_screen.dart';

Future<void> main() async {
  await Hive.initFlutter();
  runApp(const EmanLifeApp());
  unawaited(_startSubscriptionChecks());
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
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

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

  Future<void> _showFeedbackDialog() async {
    final feedbackController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('إرسال ملاحظات', style: TextStyle(color: AppTheme.textColor)),
            content: TextField(
              controller: feedbackController,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(
                hintText: 'شاركينا رأيك أو اقتراحك حول التطبيق...',
                hintStyle: TextStyle(color: AppTheme.subTextColor),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: AppTheme.subTextColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  final text = feedbackController.text.trim();
                  if (text.isEmpty) return;
                  final db = await DatabaseService.getInstance();
                  await db.saveFeedbackEntry(text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لك، تم إرسال ملاحظتك بنجاح!')),
                  );
                },
                child: const Text('إرسال', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
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
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'feedback_fab',
            tooltip: 'إرسال ملاحظات',
            backgroundColor: AppTheme.accentColor,
            onPressed: _showFeedbackDialog,
            child: const Icon(Icons.feedback_rounded, color: Colors.white),
          ),
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
              label: 'المطبخ والمنازل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'الميزانية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'Gemini AI',
            ),
          ],
        ),
      ),
    );
  }
}
