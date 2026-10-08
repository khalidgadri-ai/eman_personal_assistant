import '../awareness/usage_service.dart';
import '../budget/budget_service.dart';
import '../budget/models/expense_entry.dart';
import 'coach_safety.dart';
import 'coach_session_service.dart';
import 'models/coach_question.dart';
import 'models/coach_signals.dart';

/// محفّزات محلية بالكامل: تقرأ بيانات الجهاز فقط (Hive وإحصاءات استخدام Android)، بدون إنترنت أو AI.
class CoachSignalService {
  static const Duration budgetWindow = Duration(days: 7);
  static const int unplannedExpenseThreshold = 3;
  static const int socialMinutesThreshold = 120;

  final DateTime Function() _now;

  CoachSignalService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  Future<CoachSignals> getSignals() async {
    return CoachSignals(
      budget: await getBudgetSignal(),
      usage: await getUsageSignal(),
      reflection: await getReflectionSignal(),
    );
  }

  /// إجمالي دقائق تطبيقات التواصل اليوم تجاوز ساعتين. لا يطلب الصلاحية ولا يفتح الإعدادات:
  /// بدونها يعتمد على آخر قراءة محفوظة لليوم (أو لا شيء).
  Future<bool> getUsageSignal() async {
    final usage = await UsageService.getInstance();
    final today = await usage.getDailyUsageByApp(now: _now());
    return totalMinutes(today) > socialMinutesThreshold;
  }

  /// صرف "غير مخطط" = فئة "أخرى" أو بدون ملاحظة، خلال آخر 7 أيام.
  Future<bool> getBudgetSignal() async {
    final budget = await BudgetService.getInstance();
    final unplanned = budget
        .getExpensesSince(_now().subtract(budgetWindow))
        .where((e) => e.category == ExpenseCategory.other || e.note == null);
    return unplanned.length >= unplannedExpenseThreshold;
  }

  /// كلمة مشتركة بين آخر إجابتين متتاليتين في سجل جلسات المدرب؛ مجالها هو مجال أحدث إجابة.
  Future<ReflectionSignal?> getReflectionSignal() async {
    final sessions = await CoachSessionService.getInstance();
    final answered = sessions
        .getSessions()
        .where((s) => (s['answerText'] as String?)?.trim().isNotEmpty ?? false)
        .take(2)
        .toList();
    if (answered.length < 2) return null;

    final previous = _topicWords(answered[1]['answerText'] as String).toSet();
    final shared = _topicWords(answered[0]['answerText'] as String)
        .where(previous.contains)
        .toSet()
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    if (shared.isEmpty) return null;

    return ReflectionSignal(
      topic: shared.first,
      domain: CoachDomain.values.byName(answered[0]['domain'] as String),
    );
  }
}

final RegExp _nonLetters = RegExp(r'[^\p{L}]+', unicode: true);

const List<String> _articlePrefixes = ['وال', 'بال', 'فال', 'كال', 'لل', 'ال'];

final Set<String> _stopWords = {
  'انا', 'انت', 'انتي', 'احنا', 'نحن', 'هو', 'هي', 'هم', 'اللي', 'الذي', 'التي',
  'هذا', 'هذي', 'هذه', 'ذلك', 'تلك', 'هذاك', 'كان', 'كانت', 'يكون', 'تكون',
  'صار', 'صارت', 'كنت', 'عشان', 'علشان', 'لأن', 'لكن', 'بس', 'مع', 'على', 'عن',
  'في', 'من', 'إلى', 'حتى', 'اذا', 'إذا', 'لما', 'لين', 'وش', 'ايش', 'ليش', 'كيف',
  'متى', 'وين', 'مين', 'شي', 'شيء', 'كل', 'كثير', 'واجد', 'وايد', 'مرة', 'جدا',
  'شوي', 'يعني', 'الحين', 'للحين', 'اليوم', 'امس', 'بعد', 'قبل', 'عند', 'عندي',
  'فيه', 'فيها', 'منه', 'منها', 'عليه', 'عليها', 'ابي', 'ابغى', 'ودي', 'احس',
  'حسيت', 'اشوف', 'شفت', 'اقدر', 'ممكن', 'لازم', 'نفسي', 'نفس', 'ايضا', 'برضو',
  'طيب', 'زين', 'إلا', 'غير', 'بين', 'ثم', 'او', 'ولا', 'لا', 'ما', 'لم', 'لن',
  'قد', 'هل', 'انه', 'انها', 'اني', 'انو', 'اكثر', 'اقل', 'اسوي', 'سويت', 'قلت',
  'اقول', 'قال', 'يقول', 'تقول', 'اعرف', 'ادري', 'عارف',
}.map(normalizeArabic).toSet();

List<String> _topicWords(String text) {
  final words = <String>[];
  for (final raw in normalizeArabic(text).split(_nonLetters)) {
    if (raw.isEmpty || _stopWords.contains(raw)) continue;
    final stem = _stem(raw);
    if (stem.length >= 3 && !_stopWords.contains(stem)) words.add(stem);
  }
  return words;
}

// "الشغل" و"بالشغل" و"شغلي" كلها تصير "شغل".
String _stem(String word) {
  var stem = word;
  for (final prefix in _articlePrefixes) {
    if (stem.startsWith(prefix) && stem.length - prefix.length >= 3) {
      stem = stem.substring(prefix.length);
      break;
    }
  }
  if (stem.length >= 4 && stem.endsWith('ي')) {
    stem = stem.substring(0, stem.length - 1);
  }
  return stem;
}
