import 'profile_service.dart';

/// تعليمات المساعد العام (system instruction). لا يوجد فيها أي معلومة مكتوبة مسبقًا عن
/// شخص بعينه: الاسم والاهتمامات والأهداف تأتي حصرًا مما أدخله المستخدم في شاشة الترحيب،
/// وبدونها تبقى التعليمات عامة تمامًا.
String buildAssistantSystemPrompt(UserProfile? profile) {
  final buffer = StringBuffer(
    'أنت مساعد شخصي ودود ومختصر، تساعد المستخدم في تنظيم يومه ومهامه وصحته ومطبخه '
    'وميزانيته. أجب بالعربية الواضحة وبنقاط مختصرة. لا تفترض أي معلومة عن المستخدم '
    'غير المذكورة هنا، ولا تقدّم تشخيصًا طبيًا ولا نصيحة مالية ملزمة.',
  );
  if (profile != null) {
    if (profile.name.isNotEmpty) buffer.write('\nاسم المستخدم: ${_oneLine(profile.name)}.');
    if (profile.interests.isNotEmpty) {
      buffer.write('\nاهتمامات المستخدم: ${profile.interests.map(_oneLine).join('، ')}.');
    }
    if (profile.goals.isNotEmpty) {
      buffer.write('\nأهداف ذكرها المستخدم: ${profile.goals.map(_oneLine).join('، ')}.');
    }
  }
  return buffer.toString();
}

/// رسالة الترحيب الأولى في محادثة المساعد؛ الاسم من ملف المستخدم فقط وإلا ترحيب عام.
String assistantGreeting(String name) {
  final hello = name.trim().isEmpty ? 'أهلًا بك!' : 'أهلًا بك يا ${_oneLine(name)}!';
  return '$hello أنا مساعدك الذكي. كيف أساعدك في تنظيم يومك، أو اقتراح '
      'وجبات، أو مراجعة تمارينك؟\n\n'
      '🔑 للبدء يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحك الخاص من أيقونة المفتاح في الأعلى.';
}

// نص المستخدم يدخل التعليمات كسطر واحد حتى لا يبدو كأنه تعليمات جديدة.
String _oneLine(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
