enum CoachDomain { beliefs, emotions, goals, organization, budget, skills }

extension CoachDomainLabel on CoachDomain {
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
    }
  }
}

class CoachQuestion {
  final String id;
  final CoachDomain domain;
  final String text;
  final String? followUpPromptHint;

  const CoachQuestion({
    required this.id,
    required this.domain,
    required this.text,
    this.followUpPromptHint,
  });

  factory CoachQuestion.fromJson(Map<String, dynamic> json) {
    return CoachQuestion(
      id: json['id'] as String,
      domain: CoachDomain.values.byName(json['domain'] as String),
      text: json['text'] as String,
      followUpPromptHint: json['followUpPromptHint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain.name,
        'text': text,
        'followUpPromptHint': followUpPromptHint,
      };
}
