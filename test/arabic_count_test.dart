import 'package:eman_life_app/core/utils/arabic_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('days follow the Arabic number rules', () {
    expect(arabicCount(1, ArabicNoun.day), 'يوم واحد');
    expect(arabicCount(2, ArabicNoun.day), 'يومان');
    expect(arabicCount(3, ArabicNoun.day), '3 أيام');
    expect(arabicCount(10, ArabicNoun.day), '10 أيام');
    expect(arabicCount(11, ArabicNoun.day), '11 يومًا');
    expect(arabicCount(31, ArabicNoun.day), '31 يومًا');
    expect(arabicCount(100, ArabicNoun.day), '100 يوم');
    expect(arabicCount(102, ArabicNoun.day), '102 يوم');
    expect(arabicCount(105, ArabicNoun.day), '105 أيام');
    expect(arabicCount(0, ArabicNoun.day), '0 يوم');
  });

  test('minutes and pages use their own forms', () {
    expect(arabicCount(5, ArabicNoun.minute), '5 دقائق');
    expect(arabicCount(15, ArabicNoun.minute), '15 دقيقة');
    expect(arabicCount(2, ArabicNoun.minute), 'دقيقتان');
    expect(arabicCount(604, ArabicNoun.page), '604 صفحات');
    expect(arabicCount(1, ArabicNoun.page), 'صفحة واحدة');
    expect(arabicCount(20, ArabicNoun.page), '20 صفحة');
  });
}
