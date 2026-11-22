import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../../core/services/database_service.dart';
import '../../core/services/encrypted_boxes.dart';
import 'models/coach_question.dart';
import 'models/coach_signals.dart';
import 'tools/coach_tool_record.dart';
import '../../core/config/app_locale.dart';

class CoachSessionService {
  static const String _boxName = 'coach_sessions';

  /// وزن إضافي لمجال المحفّز: مع محفّز واحد تصبح فرصته 4 من 9 (حوالي 44٪) بدل 1 من 6.
  static const int signalBoost = 3;

  static CoachSessionService? _instance;
  static Box? _box;
  static DatabaseService? _db;
  static List<CoachQuestion>? _questionBank;

  CoachSessionService._();

  static Future<CoachSessionService> getInstance() async {
    _instance ??= CoachSessionService._();
    _box ??= await EncryptedBoxes.open(_boxName);
    if (_db == null) {
      try {
        _db = await DatabaseService.getInstance();
      } catch (e) {
        // بلا سجل «ظهر»: المدرب يعمل، ويعتمد على الجلسات المحفوظة فقط.
        debugPrint('CoachSessionService: shown-question history unavailable (${e.runtimeType})');
      }
    }
    _questionBank ??= await _loadQuestionBank();
    return _instance!;
  }

  /// يمسح الحالة المخزّنة بين الاختبارات، على نمط DatabaseService.resetForTesting.
  /// يُنسى الصندوق المفتوح (بعد مسح بيانات المستخدم يُفتح صندوق جديد عند الطلب).
  static void reset() {
    _instance = null;
    _box = null;
    _db = null;
  }

  @visibleForTesting
  static void resetForTesting() {
    reset();
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
      // وقت طويل في تطبيقات التواصل اليوم: مجال «الحياة الرقمية» هو الأقرب.
      weights[CoachDomain.digital] = weights[CoachDomain.digital]! + signalBoost;
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

  /// يختار سؤالًا من المجال لم يظهر في الدورة الحالية، **دون** أن يسجّله. للعرض استعمل
  /// [showNextQuestion]. الدورة: لا يتكرر سؤال حتى تظهر كل أسئلة مجاله.
  CoachQuestion pickQuestion(CoachDomain domain, {String? excludeId, Random? random}) {
    final inDomain = questionsForDomain(domain);
    if (inDomain.isEmpty) {
      throw StateError('No questions in the bank for domain ${domain.name}');
    }
    return chooseQuestion(
      inDomain: inDomain,
      shownIds: _shownHistory().map((e) => e.id).toList(),
      excludeId: excludeId,
      random: random ?? Random(),
    );
  }

  /// يختار سؤالًا ويسجّل أنه ظهر. فشل التسجيل لا يمنع عرض السؤال.
  Future<CoachQuestion> showNextQuestion(CoachDomain domain, {String? excludeId, Random? random}) async {
    final question = pickQuestion(domain, excludeId: excludeId, random: random);
    await recordShown(question);
    return question;
  }

  /// يسجّل أن [question] ظهر للمستخدم الآن. أسئلة المتابعة من الموديل (ليست من البنك) لا تُسجَّل.
  Future<void> recordShown(CoachQuestion question, {DateTime? at}) async {
    final db = _db;
    if (db == null || !(_bankIds.contains(question.id))) return;
    final history = _shownHistory()..add((id: question.id, at: at ?? DateTime.now()));
    final trimmed = history.length > historyLimit ? history.sublist(history.length - historyLimit) : history;
    try {
      await db.saveCoachSeenQuestions([
        for (final e in trimmed) {'id': e.id, 'at': e.at.toIso8601String()},
      ]);
    } catch (e) {
      debugPrint('CoachSessionService: could not record a shown question (${e.runtimeType})');
    }
  }

  /// آخر الأسئلة الظاهرة في المجال لا تُعاد في بداية دورة جديدة.
  static const int recentGuard = 10;

  /// أقصى عدد سجلات «ظهر» المحفوظة (أكبر من البنك كله بكثير).
  static const int historyLimit = 1000;

  /// قلب الاختيار، دالة صافية للاختبار. [shownIds] بترتيب الظهور (الأقدم أولًا)، من كل المجالات.
  @visibleForTesting
  static CoachQuestion chooseQuestion({
    required List<CoachQuestion> inDomain,
    required List<String> shownIds,
    required Random random,
    String? excludeId,
  }) {
    final ids = {for (final q in inDomain) q.id};
    final domainShown = shownIds.where(ids.contains).toList();

    // الدورة الحالية: تبدأ من جديد كلما ظهرت كل أسئلة المجال.
    var cycle = <String>{};
    for (final id in domainShown) {
      cycle.add(id);
      if (cycle.length == ids.length) cycle = <String>{};
    }

    final recent = <String>{};
    for (final id in domainShown.reversed) {
      if (recent.length >= recentGuard) break;
      recent.add(id);
    }

    var candidates = inDomain.where((q) => !cycle.contains(q.id) && q.id != excludeId).toList();
    final notRecent = candidates.where((q) => !recent.contains(q.id)).toList();
    if (notRecent.isNotEmpty) candidates = notRecent;
    if (candidates.isEmpty) {
      final others = inDomain.where((q) => q.id != excludeId).toList();
      candidates = others.isEmpty ? inDomain : others;
    }
    return candidates[random.nextInt(candidates.length)];
  }

  Set<String> get _bankIds => {for (final q in _questionBank ?? const <CoachQuestion>[]) q.id};

  /// سجل «ظهر» بترتيب الظهور. أول مرة (المفتاح غير محفوظ) يُبنى من الجلسات القديمة.
  List<({String id, DateTime at})> _shownHistory() {
    final stored = _db?.getCoachSeenQuestions();
    if (stored == null) return _historyFromSessions();
    final history = <({String id, DateTime at})>[];
    for (final entry in stored) {
      final id = entry['id'];
      final at = DateTime.tryParse('${entry['at']}');
      if (id is String && at != null) history.add((id: id, at: at));
    }
    return history;
  }

  List<({String id, DateTime at})> _historyFromSessions() {
    final bank = _bankIds;
    final history = <({String id, DateTime at})>[];
    for (final entry in (_box?.values ?? const Iterable.empty())) {
      if (entry is! Map) continue;
      final id = entry['questionId'];
      final date = entry['date'];
      if (id is String && date is DateTime && bank.contains(id)) history.add((id: id, at: date));
    }
    history.sort((a, b) => a.at.compareTo(b.at));
    return history;
  }

  /// يحذف جلسة واحدة ويرجّعها (بمفتاحها) لاستعمالها في "تراجع". null إن لم توجد.
  Future<Map<String, dynamic>?> deleteSession(String id) async {
    final key = int.tryParse(id);
    final current = key == null ? null : _box?.get(key);
    if (key == null || current is! Map) return null;
    await _box!.delete(key);
    return {...Map<String, dynamic>.from(current), 'id': id};
  }

  Future<void> restoreSession(Map<String, dynamic> session) async {
    final key = int.tryParse('${session['id']}');
    if (key == null) return;
    await _box?.put(key, {
      for (final e in session.entries)
        if (e.key != 'id') e.key: e.value,
    });
  }

  Future<void> saveSession({
    required CoachQuestion question,
    String? answerText,
    DateTime? date,
  }) async {
    await _box?.add({
      'questionId': question.id,
      'domain': question.domain.name,
      'questionText': question.textFor(AppLocale.current.languageCode),
      'answerText': answerText,
      'date': date ?? DateTime.now(),
    });
  }

  /// كل جلسة أسئلة معها `id` (مفتاح السجل) لحذفها أو إعادتها. سجلات الأدوات (بحقل `kind`) لا تدخل.
  List<Map<String, dynamic>> getSessions({CoachDomain? domain}) {
    final entries = (_box?.toMap().entries ?? const <MapEntry<dynamic, dynamic>>[])
        .where((e) => e.value is Map && (e.value as Map)['kind'] == null)
        .map((e) => {...Map<String, dynamic>.from(e.value as Map), 'id': '${e.key}'});
    final filtered = domain == null
        ? entries
        : entries.where((e) => e['domain'] == domain.name);
    final list = filtered.toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return list;
  }

  // --- سجلات أدوات المدرب ---

  /// العادات الجارية لجدولة تذكيرها اليومي. يفتح الصندوق وحده بلا ملف الأسئلة، لأن المزامنة تعمل
  /// عند كل تشغيل وبعد كل تغيير.
  static Future<List<CoachToolRecord>> activeHabits(DateTime now) async {
    _box ??= await EncryptedBoxes.open(_boxName);
    return [
      for (final e in _box!.toMap().entries)
        if (CoachToolRecord.tryParse('${e.key}', e.value) case final r? when habitIsActive(r, now)) r,
    ];
  }


  /// يحفظ سجل أداة ويرجّعه بمفتاحه.
  Future<CoachToolRecord> saveToolRecord(CoachToolRecord record) async {
    final box = _box;
    if (box == null) return record;
    final key = await box.add(record.toMap());
    return CoachToolRecord.tryParse('$key', box.get(key)) ?? record;
  }

  Future<void> updateToolRecord(CoachToolRecord record) async {
    final key = int.tryParse(record.id);
    if (key == null) return;
    await _box?.put(key, record.toMap());
  }

  /// سجلات الأدوات، الأحدث أولًا. [kind] لتصفية أداة واحدة.
  List<CoachToolRecord> toolRecords({CoachToolKind? kind}) {
    final records = <CoachToolRecord>[
      for (final e in (_box?.toMap().entries ?? const <MapEntry<dynamic, dynamic>>[]))
        if (CoachToolRecord.tryParse('${e.key}', e.value) case final r? when kind == null || r.kind == kind) r,
    ]..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }
}
