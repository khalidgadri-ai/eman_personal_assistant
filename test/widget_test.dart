import 'package:flutter_test/flutter_test.dart';
import 'package:eman_life_app/main.dart';

void main() {
  testWidgets('App loads correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    expect(find.byType(EmanLifeApp), findsOneWidget);
  });

  testWidgets('life coach entry button is on the main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    expect(find.byTooltip('مدرب الحياة'), findsOneWidget);
  });
}
