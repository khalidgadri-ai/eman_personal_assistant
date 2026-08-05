import 'package:flutter_test/flutter_test.dart';
import 'package:eman_life_app/main.dart';

void main() {
  testWidgets('App loads correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmanLifeApp());
    expect(find.byType(EmanLifeApp), findsOneWidget);
  });
}
