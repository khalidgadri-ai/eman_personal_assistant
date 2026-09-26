import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eman_life_app/core/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DatabaseService.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  group('DatabaseService feedback entries', () {
    test('returns an empty list when nothing has been saved yet', () async {
      final db = await DatabaseService.getInstance();
      expect(db.getFeedbackEntries(), isEmpty);
    });

    test('saveFeedbackEntry appends and persists an entry', () async {
      final db = await DatabaseService.getInstance();

      await db.saveFeedbackEntry('التطبيق رائع لكن أتمنى إضافة تذكيرات صوتية');

      final entries = db.getFeedbackEntries();
      expect(entries, hasLength(1));
      expect(entries.first['text'], 'التطبيق رائع لكن أتمنى إضافة تذكيرات صوتية');
      expect(entries.first['date'], isNotNull);
    });

    test('multiple entries accumulate in order', () async {
      final db = await DatabaseService.getInstance();

      await db.saveFeedbackEntry('ملاحظة أولى');
      await db.saveFeedbackEntry('ملاحظة ثانية');

      final entries = db.getFeedbackEntries();
      expect(entries, hasLength(2));
      expect(entries[0]['text'], 'ملاحظة أولى');
      expect(entries[1]['text'], 'ملاحظة ثانية');
    });
  });
}
