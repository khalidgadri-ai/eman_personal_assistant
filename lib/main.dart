import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/goals_and_tasks/goals_tasks_screen.dart';
import 'features/health_and_fitness/health_fitness_screen.dart';
import 'features/kitchen_and_home/kitchen_home_screen.dart';
import 'features/financial/financial_screen.dart';
import 'features/ai_assistant/ai_assistant_screen.dart';

void main() {
  runApp(const EmanLifeApp());
}

class EmanLifeApp extends StatelessWidget {
  const EmanLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إدارة الحياة المتكامل',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
