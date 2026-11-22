import '../../../l10n/app_localizations.dart';

enum CoachDomain { beliefs, emotions, goals, organization, budget, skills, relationships, work, digital }

extension CoachDomainLabel on CoachDomain {
  /// اسم المجال بلغة التطبيق.
  String label(AppLocalizations l10n) => switch (this) {
        CoachDomain.beliefs => l10n.coachDomainBeliefs,
        CoachDomain.emotions => l10n.coachDomainEmotions,
        CoachDomain.goals => l10n.coachDomainGoals,
        CoachDomain.organization => l10n.coachDomainOrganization,
        CoachDomain.budget => l10n.tourBudgetTitle,
        CoachDomain.skills => l10n.coachDomainSkills,
        CoachDomain.relationships => l10n.coachDomainRelationships,
        CoachDomain.work => l10n.coachDomainWork,
        CoachDomain.digital => l10n.coachDomainDigital,
      };

  /// الاسم العربي، لتعليمات المدرب العربية للذكاء الاصطناعي فقط (الواجهة تستعمل [label]).
  String get arabicLabel {
    switch (this) {
      case CoachDomain.beliefs:
        return 'المعتقدات';
      case CoachDomain.emotions:
        return 'المشاعر';
      case CoachDomain.goals:
        return 'الأهداف والتخطيط';
      case CoachDomain.organization:
        return 'التنظيم والتوازن';
      case CoachDomain.budget:
        return 'الميزانية';
      case CoachDomain.skills:
        return 'المهارات والتقنيات';
      case CoachDomain.relationships:
        return 'العلاقات';
      case CoachDomain.work:
        return 'العمل والمسار المهني';
      case CoachDomain.digital:
        return 'الحياة الرقمية';
    }
  }
}

class CoachQuestion {
  final String id;
  final CoachDomain domain;

  /// النص العربي (الأصل). سؤال المتابعة من الذكاء الاصطناعي نصه بلغة الرد نفسها.
  final String text;

  /// ترجمة إنجليزية لسؤال البنك (الحقل "en" في coach_questions.json).
  final String? textEn;
  final String? followUpPromptHint;

  const CoachQuestion({
    required this.id,
    required this.domain,
    required this.text,
    this.textEn,
    this.followUpPromptHint,
  });

  /// النص بلغة التطبيق [lang]؛ بلا ترجمة يُعرض الأصل.
  String textFor(String lang) => lang == 'en' ? textEn ?? text : text;

  factory CoachQuestion.fromJson(Map<String, dynamic> json) {
    return CoachQuestion(
      id: json['id'] as String,
      domain: CoachDomain.values.byName(json['domain'] as String),
      text: json['text'] as String,
      textEn: json['en'] as String?,
      followUpPromptHint: json['followUpPromptHint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain.name,
        'text': text,
        if (textEn != null) 'en': textEn,
        'followUpPromptHint': followUpPromptHint,
      };
}
