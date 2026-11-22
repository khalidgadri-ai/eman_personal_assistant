import '../../../l10n/app_localizations.dart';

/// أدوات المدرب: تمارين قصيرة بخطوات، نتيجتها تُحفظ في صندوق `coach_sessions` المشفّر نفسه
/// (حقل `kind`)، فتدخل النسخة الاحتياطية و«مسح كل بياناتي» تلقائيًا.
enum CoachToolKind {
  wheel,
  emotion,
  belief,
  innerVoice,
  decision,
  habit;

  /// الأدوات الأربع الأخيرة بالاشتراك (نفس اشتراك «عمّق أكثر» والتأمل)؛ العجلة والمشاعر مجانيتان.
  bool get isPremium => this != wheel && this != emotion;
}

/// سجل أداة واحد كما يُحفظ. [data] نتيجة الأداة (أرقام ومعرّفات ونصوص المستخدم)، و[step] الخطوة
/// الصغيرة التي التزم بها المستخدم إن وُجدت؛ المدرب يسأل عنها في مرة لاحقة ([followedUp]).
class CoachToolRecord {
  const CoachToolRecord({
    required this.id,
    required this.kind,
    required this.date,
    required this.data,
    this.step,
    this.followedUp = false,
    this.stepDone,
  });

  /// مفتاح السجل في الصندوق، فارغ قبل الحفظ.
  final String id;
  final CoachToolKind kind;
  final DateTime date;
  final Map<String, dynamic> data;
  final String? step;
  final bool followedUp;

  /// جواب المتابعة: أُنجزت الخطوة أم لا. null قبل السؤال.
  final bool? stepDone;

  bool get hasStep => (step ?? '').trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'date': date,
        'data': data,
        if (hasStep) 'step': step!.trim(),
        'followedUp': followedUp,
        'stepDone': ?stepDone,
      };

  /// يقرأ سجلًا محفوظًا بحذر؛ null لأي سجل ليس أداة أو تالف (السجلات القديمة أسئلة بلا `kind`).
  static CoachToolRecord? tryParse(String id, Object? raw) {
    if (raw is! Map) return null;
    final kind = CoachToolKind.values.where((k) => k.name == raw['kind']).firstOrNull;
    final date = raw['date'];
    final data = raw['data'];
    if (kind == null || date is! DateTime || data is! Map) return null;
    final step = raw['step'];
    final done = raw['stepDone'];
    return CoachToolRecord(
      id: id,
      kind: kind,
      date: date,
      data: Map<String, dynamic>.from(data),
      step: step is String ? step : null,
      followedUp: raw['followedUp'] == true,
      stepDone: done is bool ? done : null,
    );
  }

  CoachToolRecord copyWith({bool? followedUp, bool? stepDone}) => CoachToolRecord(
        id: id,
        kind: kind,
        date: date,
        data: data,
        step: step,
        followedUp: followedUp ?? this.followedUp,
        stepDone: stepDone ?? this.stepDone,
      );
}

/// آخر خطوة لم يُسأل عنها بعد، بشرط أن تكون من يوم سابق (لا يُسأل عنها في يوم حفظها).
/// تُعرض فقط الخطوة الأحدث: إن أُجيب عنها فلا يُسأل عن خطوات أقدم.
CoachToolRecord? pendingFollowUp(List<CoachToolRecord> records, DateTime now) {
  final withSteps = records.where((r) => r.hasStep).toList()..sort((a, b) => b.date.compareTo(a.date));
  if (withSteps.isEmpty) return null;
  final latest = withSteps.first;
  final today = DateTime(now.year, now.month, now.day);
  if (latest.followedUp || !latest.date.isBefore(today)) return null;
  return latest;
}

// --- عجلة الحياة ---

/// مجالات العجلة الثمانية. تُحفظ بأسمائها الإنجليزية الثابتة وتُعرض بلغة التطبيق.
enum WheelArea { health, work, money, family, relationships, growth, spirit, fun }

extension WheelAreaLabel on WheelArea {
  String label(AppLocalizations l10n) => switch (this) {
        WheelArea.health => l10n.wheelHealth,
        WheelArea.work => l10n.wheelWork,
        WheelArea.money => l10n.wheelMoney,
        WheelArea.family => l10n.wheelFamily,
        WheelArea.relationships => l10n.wheelRelationships,
        WheelArea.growth => l10n.wheelGrowth,
        WheelArea.spirit => l10n.wheelSpirit,
        WheelArea.fun => l10n.wheelFun,
      };
}

/// درجات العجلة من سجل محفوظ (0-10)؛ مجال مفقود أو قيمة غير صالحة تُهمل.
Map<WheelArea, int> wheelScores(CoachToolRecord record) {
  final raw = record.data['scores'];
  if (raw is! Map) return const {};
  return {
    for (final area in WheelArea.values)
      if (raw[area.name] case final int v when v >= 0 && v <= 10) area: v,
  };
}

/// المجال الأضعف (أول الأقل درجة بترتيب المجالات): الاختيار الافتراضي لمجال التركيز.
WheelArea lowestArea(Map<WheelArea, int> scores) {
  var best = WheelArea.values.first;
  for (final area in WheelArea.values) {
    if ((scores[area] ?? 10) < (scores[best] ?? 10)) best = area;
  }
  return best;
}

// --- تسمية المشاعر ---

enum Feeling {
  happy,
  calm,
  grateful,
  hopeful,
  proud,
  tired,
  anxious,
  stressed,
  sad,
  lonely,
  angry,
  frustrated,
  afraid,
  guilty,
  bored,
  overwhelmed,
}

extension FeelingLabel on Feeling {
  String label(AppLocalizations l10n) => switch (this) {
        Feeling.happy => l10n.feelingHappy,
        Feeling.calm => l10n.feelingCalm,
        Feeling.grateful => l10n.feelingGrateful,
        Feeling.hopeful => l10n.feelingHopeful,
        Feeling.proud => l10n.feelingProud,
        Feeling.tired => l10n.feelingTired,
        Feeling.anxious => l10n.feelingAnxious,
        Feeling.stressed => l10n.feelingStressed,
        Feeling.sad => l10n.feelingSad,
        Feeling.lonely => l10n.feelingLonely,
        Feeling.angry => l10n.feelingAngry,
        Feeling.frustrated => l10n.feelingFrustrated,
        Feeling.afraid => l10n.feelingAfraid,
        Feeling.guilty => l10n.feelingGuilty,
        Feeling.bored => l10n.feelingBored,
        Feeling.overwhelmed => l10n.feelingOverwhelmed,
      };
}

enum BodySpot { head, throat, chest, stomach, shoulders, hands, whole, unsure }

extension BodySpotLabel on BodySpot {
  String label(AppLocalizations l10n) => switch (this) {
        BodySpot.head => l10n.bodyHead,
        BodySpot.throat => l10n.bodyThroat,
        BodySpot.chest => l10n.bodyChest,
        BodySpot.stomach => l10n.bodyStomach,
        BodySpot.shoulders => l10n.bodyShoulders,
        BodySpot.hands => l10n.bodyHands,
        BodySpot.whole => l10n.bodyWhole,
        BodySpot.unsure => l10n.bodyUnsure,
      };
}

enum FeelingNeed { rest, talk, movement, quiet, solve, write, nothing }

extension FeelingNeedLabel on FeelingNeed {
  String label(AppLocalizations l10n) => switch (this) {
        FeelingNeed.rest => l10n.needRest,
        FeelingNeed.talk => l10n.needTalk,
        FeelingNeed.movement => l10n.needMovement,
        FeelingNeed.quiet => l10n.needQuiet,
        FeelingNeed.solve => l10n.needSolve,
        FeelingNeed.write => l10n.needWrite,
        FeelingNeed.nothing => l10n.needNothing,
      };
}

/// من هذه الشدة فأكثر يُعرض اقتراح جلسة «تنفّس هادئ».
const int strongFeelingIntensity = 7;

Feeling? recordFeeling(CoachToolRecord r) => Feeling.values.where((f) => f.name == r.data['feeling']).firstOrNull;

int recordIntensity(CoachToolRecord r) => switch (r.data['intensity']) {
      final int v when v >= 1 && v <= 10 => v,
      _ => 0,
    };

/// الشعور الأكثر تكرارًا في آخر [days] يومًا، أو null إن لم يُسجَّل شيء.
Feeling? mostFrequentFeeling(List<CoachToolRecord> records, DateTime now, {int days = 30}) {
  final since = now.subtract(Duration(days: days));
  final counts = <Feeling, int>{};
  for (final r in records) {
    if (r.kind != CoachToolKind.emotion || r.date.isBefore(since)) continue;
    final f = recordFeeling(r);
    if (f != null) counts[f] = (counts[f] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

// --- الصوت الداخلي ---

enum InnerVoiceType { worrier, critic, hopeless, perfectionist }

extension InnerVoiceTypeLabel on InnerVoiceType {
  String label(AppLocalizations l10n) => switch (this) {
        InnerVoiceType.worrier => l10n.voiceWorrier,
        InnerVoiceType.critic => l10n.voiceCritic,
        InnerVoiceType.hopeless => l10n.voiceHopeless,
        InnerVoiceType.perfectionist => l10n.voicePerfectionist,
      };
}

// --- تغيير عادة: عدّاد 21 يومًا ---

const int habitDays = 21;

/// مفتاح يوم ثابت `yyyy-MM-dd` لعلامات الإنجاز.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// رقم اليوم في المتابعة: 1 يوم البدء، و21 آخر يوم. أكبر من 21 بعد انتهائها.
int habitDayNumber(CoachToolRecord r, DateTime now) {
  final start = DateTime(r.date.year, r.date.month, r.date.day);
  final today = DateTime(now.year, now.month, now.day);
  // بالأيام التقويمية لا بالساعات، فلا يربكها تغيير التوقيت الصيفي.
  return DateTime.utc(today.year, today.month, today.day)
          .difference(DateTime.utc(start.year, start.month, start.day))
          .inDays +
      1;
}

Set<String> habitCheckins(CoachToolRecord r) => {
      if (r.data['checkins'] case final List list)
        for (final d in list)
          if (d is String) d,
    };

/// الأيام المنجزة داخل الأيام الـ21 فقط.
int habitDoneCount(CoachToolRecord r) {
  final start = DateTime(r.date.year, r.date.month, r.date.day);
  final days = {for (var i = 0; i < habitDays; i++) dayKey(DateTime(start.year, start.month, start.day + i))};
  return habitCheckins(r).where(days.contains).length;
}

/// عادة جارية: لم تُوقف ولم تتجاوز يومها الـ21. تذكيرها اليومي يعمل ما دامت جارية.
bool habitIsActive(CoachToolRecord r, DateTime now) =>
    r.kind == CoachToolKind.habit && r.data['stopped'] != true && habitDayNumber(r, now) <= habitDays;
