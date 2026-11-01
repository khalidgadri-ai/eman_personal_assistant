import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<void> pumpSettings(WidgetTester tester, Future<void> Function() eraser) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: SettingsScreen(eraser: eraser)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('the "مسح كل بياناتي" button is there, with a warning before anything is deleted', (tester) async {
    var calls = 0;
    await pumpSettings(tester, () async => calls++);

    expect(find.text('مسح كل بياناتي'), findsOneWidget);
    await tester.tap(find.text('مسح كل بياناتي'));
    await tester.pumpAndSettle();

    expect(find.text('مسح كل بياناتي؟'), findsOneWidget);
    expect(find.textContaining('لا يمكن التراجع'), findsOneWidget);
    expect(calls, 0, reason: 'nothing is deleted before the user confirms');
  });

  testWidgets('cancel keeps everything', (tester) async {
    var calls = 0;
    await pumpSettings(tester, () async => calls++);

    await tester.tap(find.text('مسح كل بياناتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(find.text('مسح كل بياناتي؟'), findsNothing);
  });

  testWidgets('confirming runs the eraser exactly once', (tester) async {
    var calls = 0;
    await pumpSettings(tester, () async => calls++);

    await tester.tap(find.text('مسح كل بياناتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مسح كل شيء'));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('a failed erase says so in simple Arabic and leaves the screen usable', (tester) async {
    await pumpSettings(tester, () async => throw StateError('disk is read-only: secret path'));

    await tester.tap(find.text('مسح كل بياناتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مسح كل شيء'));
    await tester.pumpAndSettle();

    expect(find.text('تعذّر مسح البيانات. لم يُحذف شيء، حاول مرة أخرى.'), findsOneWidget);
    expect(find.textContaining('secret path'), findsNothing);
    // الزر ما زال يعمل بعد الفشل.
    await tester.tap(find.text('مسح كل بياناتي'));
    await tester.pumpAndSettle();
    expect(find.text('مسح كل بياناتي؟'), findsOneWidget);
  });

  testWidgets('a user who skipped the welcome sees "بدون اسم" and a hint, not someone else\'s data', (tester) async {
    await pumpSettings(tester, () async {});

    expect(find.text('بدون اسم'), findsOneWidget);
    expect(find.textContaining('تُحفظ مشفّرة على جهازك فقط'), findsOneWidget);
  });
}
