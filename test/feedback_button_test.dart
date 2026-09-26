import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eman_life_app/main.dart';
import 'package:eman_life_app/core/services/database_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpAppAndSettleInit(WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    // Let the async service initialization (SharedPreferences/GeminiService) resolve
    // before interacting, without pumpAndSettle (some screens show an indeterminate
    // spinner briefly, which pumpAndSettle can't wait out).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('feedback button is visible on the main screen', (tester) async {
    await pumpAppAndSettleInit(tester);

    expect(find.byIcon(Icons.feedback_rounded), findsOneWidget);
  });

  testWidgets('tapping the feedback button opens the feedback dialog', (tester) async {
    await pumpAppAndSettleInit(tester);

    await tester.tap(find.byIcon(Icons.feedback_rounded));
    await tester.pumpAndSettle();

    expect(find.text('إرسال ملاحظات'), findsOneWidget);
    final dialogTextField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(dialogTextField, findsOneWidget);
    expect(
      (tester.widget(dialogTextField) as TextField).decoration?.hintText,
      'شاركينا رأيك أو اقتراحك حول التطبيق...',
    );
  });

  testWidgets('submitting empty feedback keeps the dialog open', (tester) async {
    await pumpAppAndSettleInit(tester);

    await tester.tap(find.byIcon(Icons.feedback_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إرسال'));
    await tester.pumpAndSettle();

    expect(find.text('إرسال ملاحظات'), findsOneWidget);
  });

  testWidgets('submitting feedback text saves it and shows a confirmation', (tester) async {
    await pumpAppAndSettleInit(tester);

    await tester.tap(find.byIcon(Icons.feedback_rounded));
    await tester.pumpAndSettle();

    final dialogTextField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogTextField, 'ميزة رائعة، شكراً لكم!');
    await tester.tap(find.text('إرسال'));
    await tester.pumpAndSettle();

    // Dialog closed, confirmation SnackBar shown.
    expect(find.text('إرسال ملاحظات'), findsNothing);
    expect(find.text('شكراً لك، تم إرسال ملاحظتك بنجاح!'), findsOneWidget);

    final db = await DatabaseService.getInstance();
    final entries = db.getFeedbackEntries();
    expect(entries, hasLength(1));
    expect(entries.first['text'], 'ميزة رائعة، شكراً لكم!');
  });
}
