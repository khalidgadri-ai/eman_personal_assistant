import 'package:eman_life_app/core/utils/arabic_text.dart';
import 'package:eman_life_app/core/utils/ids.dart';
import 'package:eman_life_app/core/utils/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseQuantity', () {
    test('plain, decimal and Arabic-Indic numbers', () {
      expect(parseQuantity('2'), 2);
      expect(parseQuantity('2.5'), 2.5);
      expect(parseQuantity('٢٫٥'), 2.5);
      expect(parseQuantity('  ١٠  '), 10);
      expect(parseQuantity('1,000'), 1000, reason: 'a comma is a thousands separator');
    });

    test('fractions in every common spelling', () {
      expect(parseQuantity('1/2'), 0.5);
      expect(parseQuantity('1 1/2'), 1.5);
      expect(parseQuantity('½'), 0.5);
      expect(parseQuantity('1½'), 1.5);
      expect(parseQuantity('¾'), 0.75);
      expect(parseQuantity('٣/٤'), 0.75);
      expect(parseQuantity('⅓'), closeTo(0.3333, 0.001));
    });

    test('rejects anything that is not a quantity', () {
      expect(parseQuantity(''), isNull);
      expect(parseQuantity('كثير'), isNull);
      expect(parseQuantity('حسب الذوق'), isNull);
      expect(parseQuantity('1/0'), isNull);
      expect(parseQuantity('-2'), isNull);
      expect(parseQuantity('2 كجم'), isNull, reason: 'units are split off first');
      expect(parseQuantity('1.2.3'), isNull);
    });
  });

  group('formatQuantity', () {
    test('whole numbers have no decimals', () {
      expect(formatQuantity(2), '2');
      expect(formatQuantity(2.0000001), '2');
      expect(formatQuantity(0), '0');
    });

    test('common fractions use their glyph', () {
      expect(formatQuantity(0.5), '½');
      expect(formatQuantity(1.5), '1½');
      expect(formatQuantity(2.25), '2¼');
      expect(formatQuantity(0.75), '¾');
      expect(formatQuantity(1 / 3), '⅓');
    });

    test('other values keep at most two decimals, trimmed', () {
      expect(formatQuantity(2.4), '2.4');
      expect(formatQuantity(2.45), '2.45');
      expect(formatQuantity(2.456), '2.46');
      expect(formatQuantity(0.1), '0.1');
    });

    test('invalid values give nothing', () {
      expect(formatQuantity(double.nan), '');
      expect(formatQuantity(-1), '');
    });

    test('what is shown parses back to the same amount', () {
      for (final v in <double>[0.5, 1.5, 2.25, 0.75, 3, 7.4, 12.5]) {
        expect(parseQuantity(formatQuantity(v)), closeTo(v, 0.001), reason: '$v');
      }
    });
  });

  group('splitQuantityText / joinQuantity', () {
    test('splits an amount from its unit', () {
      expect(splitQuantityText('2 كجم').amount, 2);
      expect(splitQuantityText('2 كجم').unit, 'كجم');
      expect(splitQuantityText('٣ لتر').amount, 3);
      expect(splitQuantityText('1/2 كوب').amount, 0.5);
      expect(splitQuantityText('1 1/2 ملعقة').amount, 1.5);
      expect(splitQuantityText('1 1/2 ملعقة').unit, 'ملعقة');
      expect(splitQuantityText('½ كوب').unit, 'كوب');
      expect(splitQuantityText('5').unit, '');
    });

    test('text without a leading number is all unit', () {
      final parts = splitQuantityText('كثير');
      expect(parts.amount, isNull);
      expect(parts.unit, 'كثير');
      expect(splitQuantityText('').amount, isNull);
    });

    test('joinQuantity is the reverse', () {
      expect(joinQuantity(2, 'كجم'), '2 كجم');
      expect(joinQuantity(1.5, 'كوب'), '1½ كوب');
      expect(joinQuantity(3, ''), '3');
    });
  });

  group('normalizeArabicName / sameArabicItem', () {
    test('writing variants of one name are equal', () {
      expect(sameArabicItem('الطماطم', 'طماطم'), isTrue);
      expect(sameArabicItem('طَمَاطِم', 'طماطم'), isTrue);
      expect(sameArabicItem('أرز', 'ارز'), isTrue);
      expect(sameArabicItem('حليب  ', 'حليب'), isTrue);
      expect(sameArabicItem('مكرونة', 'مكرونه'), isTrue);
    });

    test('a whole word of a longer name matches it, a mere substring does not', () {
      expect(sameArabicItem('زيت زيتون', 'زيت'), isTrue);
      expect(sameArabicItem('زيت', 'زيت زيتون'), isTrue);
      expect(sameArabicItem('ملح', 'ملحق'), isFalse);
      expect(sameArabicItem('سكر', 'سكر بني ناعم'), isTrue);
    });

    test('different things and blanks never match', () {
      expect(sameArabicItem('أرز', 'سكر'), isFalse);
      expect(sameArabicItem('', 'أرز'), isFalse);
      expect(sameArabicItem('', ''), isFalse);
    });
  });

  test('newId never repeats, even in a tight loop', () {
    final ids = {for (var i = 0; i < 5000; i++) newId()};
    expect(ids, hasLength(5000));
  });
}
