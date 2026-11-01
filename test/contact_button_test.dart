import 'package:eman_life_app/core/config/app_contact.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_storage.dart';

void main() {
  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<void> pumpMain(WidgetTester tester, {String email = '', MailOpenerFake? opener}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: MainNavigationScreen(
          supportEmail: email,
          mailOpener: opener?.call ?? (_, _) async => true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('with no support email configured the contact button is hidden, not a dead button', (tester) async {
    await pumpMain(tester);

    expect(find.byIcon(Icons.mail_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.psychology_rounded), findsOneWidget, reason: 'the coach button stays');
    expect(AppContact.supportEmail, isA<String>());
  });

  testWidgets('the old developer-notes button is gone', (tester) async {
    await pumpMain(tester, email: 'support@example.com');

    expect(find.byIcon(Icons.feedback_rounded), findsNothing);
    expect(find.byTooltip('إرسال ملاحظات'), findsNothing);
  });

  testWidgets('with an email, "تواصل معنا" opens the mail app with the address and a subject', (tester) async {
    final opener = MailOpenerFake(opens: true);
    await pumpMain(tester, email: 'support@example.com', opener: opener);

    await tester.tap(find.byTooltip('تواصل معنا'));
    await tester.pumpAndSettle();

    expect(opener.calls, [('support@example.com', AppContact.subject)]);
    expect(find.byType(AlertDialog), findsNothing, reason: 'nothing else to say when the mail app opened');
  });

  testWidgets('without a mail app the address is shown and can be copied', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final opener = MailOpenerFake(opens: false);
    await pumpMain(tester, email: 'support@example.com', opener: opener);

    await tester.tap(find.byTooltip('تواصل معنا'));
    await tester.pumpAndSettle();

    expect(find.text('support@example.com'), findsOneWidget);
    await tester.tap(find.text('نسخ العنوان'));
    await tester.pumpAndSettle();
    expect(copied, 'support@example.com');
    expect(find.byType(AlertDialog), findsNothing);
  });

  test('developer notes saved by an older version are removed on the first start', () async {
    SharedPreferences.setMockInitialValues({
      'feedback_entries': '[{"text":"ملاحظة قديمة","date":"2026-01-01"}]',
      'daily_tasks': '[]',
    });
    DatabaseService.resetForTesting();

    await DatabaseService.getInstance();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('feedback_entries'), isFalse);
    expect(prefs.getString('daily_tasks'), '[]', reason: 'other data is untouched');
  });
}

/// يسجّل الاستدعاءات ويرجّع نتيجة ثابتة.
class MailOpenerFake {
  MailOpenerFake({required this.opens});

  final bool opens;
  final List<(String, String)> calls = [];

  Future<bool> call(String email, String subject) async {
    calls.add((email, subject));
    return opens;
  }
}
