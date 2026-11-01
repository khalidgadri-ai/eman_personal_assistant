import 'package:eman_life_app/core/widgets/entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/widget_helpers.dart';

void main() {
  Map<String, String>? result;
  var closed = false;

  Future<void> openDialog(WidgetTester tester, List<EntryField> fields) async {
    result = null;
    closed = false;
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showEntryDialog(context, title: 'نافذة', fields: fields);
                closed = true;
              },
              child: const Text('افتح'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();
  }

  testWidgets('returns trimmed single-line values and the first option of a dropdown', (tester) async {
    await openDialog(tester, const [
      EntryField(key: 'name', label: 'الاسم', required: true),
      EntryField(key: 'kind', label: 'النوع', options: ['أ', 'ب']),
      EntryField(key: 'note', label: 'ملاحظة'),
    ]);

    await fillDialog(tester, {'الاسم': '   كلمة   كثيرة\n المسافات  '});

    expect(closed, isTrue);
    expect(result, {'name': 'كلمة كثيرة المسافات', 'kind': 'أ', 'note': ''});
  });

  testWidgets('a required field left empty shows an error and keeps the dialog open', (tester) async {
    await openDialog(tester, const [EntryField(key: 'name', label: 'الاسم', required: true)]);

    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    expect(closed, isFalse);

    await fillDialog(tester, {'الاسم': 'تم'});
    expect(closed, isTrue);
    expect(result, {'name': 'تم'});
  });

  testWidgets('a field made only of spaces counts as empty', (tester) async {
    await openDialog(tester, const [EntryField(key: 'name', label: 'الاسم', required: true)]);

    await fillDialog(tester, {'الاسم': '     '});

    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    expect(closed, isFalse);
  });

  testWidgets('cancel returns null', (tester) async {
    await openDialog(tester, const [EntryField(key: 'name', label: 'الاسم')]);

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, isNull);
  });

  testWidgets('a validator error blocks closing and clears when the user types again', (tester) async {
    await openDialog(tester, [
      EntryField(
        key: 'n',
        label: 'رقم',
        validator: (value) => int.tryParse(value) == null ? 'أدخل رقمًا' : null,
      ),
    ]);

    await fillDialog(tester, {'رقم': 'abc'});
    expect(find.text('أدخل رقمًا'), findsOneWidget);
    expect(closed, isFalse);

    await tester.enterText(find.widgetWithText(TextField, 'رقم'), '12');
    await tester.pump();
    expect(find.text('أدخل رقمًا'), findsNothing);
  });

  testWidgets('the maximum length is enforced even for pasted text', (tester) async {
    await openDialog(tester, const [EntryField(key: 'name', label: 'الاسم', maxLength: 10)]);

    await fillDialog(tester, {'الاسم': 'ن' * 300});

    expect(result!['name'], 'ن' * 10);
  });

  testWidgets('a multi-line field keeps inner line breaks but trims the ends', (tester) async {
    await openDialog(tester, const [EntryField(key: 'text', label: 'نص', maxLines: 3)]);

    await fillDialog(tester, {'نص': '\n  سطر 1\nسطر 2  \n'});

    expect(result!['text'], 'سطر 1\nسطر 2');
  });
}
