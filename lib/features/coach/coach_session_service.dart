import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'models/coach_question.dart';
import 'models/coach_signals.dart';

class CoachSessionService {
  static const String _boxName = 'coach_sessions';
  static const Duration _noRepeatWindow = Duration(days: 14);

  /// وزن إضافي لمجال المحفّز: مع محفّز واحد تصبح فرصته 4 من 9 (حوالي 44٪) بدل 1 من 6.
  static const int signalBoost = 3;

  static CoachSessionService? _instance;
  static Box? _box;
  static List<CoachQuestion>? _questionBank;

  CoachSessionService._();

  static Future<CoachSessionService> getInstance() async {
    _instance ??= CoachSessionService._();
    _box ??= await Hive.openBox(_boxName);
    _questionBank ??= await _loadQuestionBank();
    return _instance!;
  }

  /// يمسح الحالة المخزّنة بين الاختبارات، على نمط DatabaseService.resetForTesting.
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _box = null;
    _questionBank = null;
  }

  static Future<List<CoachQuestion>> _loadQuestionBank() async {
    final raw = await rootBundle.loadString('assets/coach_questions.json');
    final List decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => CoachQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// بدون محفّزات: كل المجالات بوزن متساوٍ.
  static Map<CoachDomain, int> domainWeights(CoachSignals signals) {
    final weights = {for (final domain in CoachDomain.values) domain: 1};
    if (signals.budget) {
      weights[CoachDomain.budget] = weights[CoachDomain.budget]! + signalBoost;
    }
    if (signals.usage) {
      weights[CoachDomain.organization] = weights[CoachDomain.organization]! + signalBoost;
    }
    final reflection = signals.reflection;
    if (reflection != null) {
      weights[reflection.domain] = weights[reflection.domain]! + signalBoost;
    }
    return weights;
  }

  static CoachDomain pickDomain(CoachSignals signals, {Random? random}) {
    final weights = domainWeights(signals);
    final total = weights.values.fold(0, (sum, weight) => sum + weight);
    var roll = (random ?? Random()).nextInt(total);
    for (final entry in weights.entries) {
      if (roll < entry.value) return entry.key;
      roll -= entry.value;
    }
    throw StateError('unreachable: roll exceeded total weight');
  }

  List<CoachQuestion> questionsForDomain(CoachDomain domain) {
    return (_questionBank ?? const []).where((q) => q.domain == domain).toList();
  }

  /// يختار سؤالًا من نفس المجال لم يُسأل خلال آخر 14 يوم إن أمكن.
  /// إذا استُخدمت كل الأسئلة ضمن هذي النافذة، يرجّع الأقدم استخدامًا بدل التعطل.
  CoachQuestion pickQuestion(CoachDomain domain, {String? excludeId}) {
    final inDomain = questionsForDomain(domain);
    final withoutExcluded = inDomain.where((q) => q.id != excludeId).toList();
    final candidates = withoutExcluded.isEmpty ? inDomain : withoutExcluded;
    if (candidates.isEmpty) {
      throw StateError('لا توجد أسئلة محفوظة لهذا المجال: ${domain.name}');
    }

    final now = DateTime.now();
    final recentIds = (_box?.values ?? const Iterable.empty())
        .cast<Map>()
        .where((entry) =>
            entry['domain'] == domain.name &&
            now.difference(entry['date'] as DateTime) < _noRepeatWindow)
        .map((entry) => entry['questionId'] as String)
        .toSet();

    final fresh = candidates.where((q) => !recentIds.contains(q.id)).toList();
    if (fresh.isNotEmpty) {
      return fresh[Random().nextInt(fresh.length)];
    }

    return _leastRecentlyUsed(candidates);
  }

  CoachQuestion _leastRecentlyUsed(List<CoachQuestion> candidates) {
    final lastUsed = <String, DateTime>{};
    for (final entry in (_box?.values ?? const Iterable.empty()).cast<Map>()) {
      final id = entry['questionId'] as String;
      final date = entry['date'] as DateTime;
      final existing = lastUsed[id];
      if (existing == null || date.isAfter(existing)) {
        lastUsed[id] = date;
      }
    }

    final sorted = List<CoachQuestion>.from(candidates)
      ..sort((a, b) {
        final aDate = lastUsed[a.id];
        final bDate = lastUsed[b.id];
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return -1;
        if (bDate == null) return 1;
        return aDate.compareTo(bDate);
      });
    return sorted.first;
  }

  Future<void> saveSession({
    required CoachQuestion question,
    String? answerText,
    DateTime? date,
  }) async {
    await _box?.add({
      'questionId': question.id,
      'domain': question.domain.name,
      'questionText': question.text,
      'answerText': answerText,
      'date': date ?? DateTime.now(),
    });
  }

  List<Map<String, dynamic>> getSessions({CoachDomain? domain}) {
    final entries = (_box?.values ?? const Iterable.empty())
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e));
    final filtered = domain == null
        ? entries
        : entries.where((e) => e['domain'] == domain.name);
    final list = filtered.toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return list;
  }
}
