import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

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
}
