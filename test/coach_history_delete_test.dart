import 'package:eman_life_app/features/coach/coach_history_screen.dart';
import 'package:eman_life_app/features/coach/coach_session_service.dart';
import 'package:eman_life_app/features/coach/models/coach_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestStorage storage;

  setUp(() async {
    storage = await TestStorage.inMemory();
  });
  tearDown(() => storage.dispose());

  Future<CoachSessionService> coach() => CoachSessionService.getInstance();

  Future<void> save(CoachSessionService service, String id, String answer, DateTime date) {
    return service.saveSession(
      question: CoachQuestion(id: id, domain: CoachDomain.beliefs, text: 'سؤال $id'),
      answerText: answer,
      date: date,
    );
  }

  test('each session carries an id, and deleting one removes only that one', () async {
    final service = await coach();
    await save(service, 'q1', 'إجابة أولى', DateTime(2026, 10, 1));
    await save(service, 'q2', 'إجابة ثانية', DateTime(2026, 10, 2));

    final first = service.getSessions().last;
    final removed = await service.deleteSession(first['id'] as String);

    expect(removed!['answerText'], 'إجابة أولى');
    expect(service.getSessions().map((s) => s['answerText']), ['إجابة ثانية']);
  });

  test('a deleted session can be restored exactly as it was', () async {
    final service = await coach();
    await save(service, 'q1', 'إجابة خاصة', DateTime(2026, 10, 1, 21, 30));
    final session = service.getSessions().single;

    final removed = await service.deleteSession(session['id'] as String);
    expect(service.getSessions(), isEmpty);
    await service.restoreSession(removed!);

    final back = service.getSessions().single;
    expect(back['id'], session['id']);
    expect(back['answerText'], 'إجابة خاصة');
    expect(back['date'], DateTime(2026, 10, 1, 21, 30));
  });

  test('deleting an unknown id changes nothing', () async {
    final service = await coach();
    await save(service, 'q1', 'إجابة', DateTime(2026, 10, 1));

    expect(await service.deleteSession('999'), isNull);
    expect(await service.deleteSession('abc'), isNull);
    expect(service.getSessions(), hasLength(1));
  });

  testWidgets('the history screen deletes one session with an undo', (tester) async {
    // خدمة المدرب تقرأ ملف أسئلة من الأصول: إدخال/إخراج حقيقي يعلّق داخل testWidgets إلا في runAsync.
    final service = (await tester.runAsync(() async {
      final created = await coach();
      await save(created, 'q1', 'إجابة أولى', DateTime(2026, 10, 1));
      await save(created, 'q2', 'إجابة ثانية', DateTime(2026, 10, 2));
      return created;
    }))!;
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, const CoachHistoryScreen());
    expect(find.text('إجابة أولى'), findsOneWidget);
    expect(find.text('إجابة ثانية'), findsOneWidget);

    await tester.tap(find.byTooltip('حذف الجلسة').first);
    await tester.pumpAndSettle();
    expect(find.text('إجابة ثانية'), findsNothing, reason: 'the newest session is listed first');
    expect(find.text('إجابة أولى'), findsOneWidget);

    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(find.text('إجابة ثانية'), findsOneWidget);
    expect(service.getSessions(), hasLength(2));
  });
}
