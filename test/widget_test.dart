import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  testWidgets('App loads correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    expect(find.byType(EmanLifeApp), findsOneWidget);
  });

  testWidgets('life coach entry button is on the main screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const MainNavigationScreen()),
    );
    expect(find.byTooltip('مدرب الحياة'), findsOneWidget);
  });

  testWidgets('the floating buttons leave the message box of the assistant tab uncovered',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(supportEmail: 'help@example.com'),
      ),
    );
    Future<void> openTab(String label) async {
      await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(label)));
      await settle(tester);
    }

    await openTab('المساعد الذكي');
    expect(find.byTooltip('مدرب الحياة'), findsNothing);
    expect(find.byTooltip('تواصل معنا'), findsNothing);

    await openTab('الميزانية');
    expect(find.byTooltip('مدرب الحياة'), findsOneWidget);
    expect(find.byTooltip('تواصل معنا'), findsOneWidget);
  });
}
