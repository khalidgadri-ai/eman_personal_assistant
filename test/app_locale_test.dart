import 'dart:io';

import 'package:eman_life_app/core/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('with the app locale the date picker speaks Arabic, right to left', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: AppLocale.locale,
      supportedLocales: AppLocale.supported,
      localizationsDelegates: AppLocale.delegates,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDatePicker(
            context: context,
            initialDate: DateTime(2026, 11, 21),
            firstDate: DateTime(2026),
            lastDate: DateTime(2027),
          ),
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Select date'), findsNothing);
    expect(find.text('اختيار التاريخ'), findsOneWidget);
    expect(find.text('الإلغاء'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(DatePickerDialog))), TextDirection.rtl);
  });

  test('the app itself uses the Arabic locale and its delegates', () {
    final main = File('lib/main.dart').readAsStringSync();

    expect(main, contains('locale: AppLocale.locale'));
    expect(main, contains('supportedLocales: AppLocale.supported'));
    expect(main, contains('localizationsDelegates: AppLocale.delegates'));
  });
}
