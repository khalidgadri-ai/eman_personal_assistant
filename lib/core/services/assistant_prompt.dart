import 'profile_service.dart';
import '../config/app_locale.dart';

/// تعليمات المساعد العام (system instruction). لا يوجد فيها أي معلومة مكتوبة مسبقًا عن
/// شخص بعينه: الاسم والاهتمامات والأهداف تأتي حصرًا مما أدخله المستخدم في شاشة الترحيب،
/// وبدونها تبقى التعليمات عامة تمامًا.
String buildAssistantSystemPrompt(UserProfile? profile, {String? lang}) {
  if ((lang ?? AppLocale.current.languageCode) == 'en') return _englishPrompt(profile);
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

/// نفس التعليمات بالإنجليزية. الاهتمامات محفوظة بنصها العربي، والموديل يفهمها، والرد بالإنجليزية.
String _englishPrompt(UserProfile? profile) {
  final buffer = StringBuffer(
    'You are a friendly, concise personal assistant who helps the user organise their day, tasks, '
    'health, kitchen and budget. Answer in clear English, in short bullet points. Do not assume '
    'anything about the user beyond what is stated here, and do not give medical diagnoses or '
    'binding financial advice.',
  );
  if (profile != null) {
    if (profile.name.isNotEmpty) buffer.write("\nThe user's name: ${_oneLine(profile.name)}.");
    if (profile.interests.isNotEmpty) {
      buffer.write("\nThe user's interests: ${profile.interests.map(_oneLine).join(', ')}.");
    }
    if (profile.goals.isNotEmpty) {
      buffer.write('\nGoals the user mentioned: ${profile.goals.map(_oneLine).join(', ')}.');
    }
  }
  return buffer.toString();
}

/// رسالة الترحيب الأولى في محادثة المساعد بلغة التطبيق؛ الاسم من ملف المستخدم فقط وإلا ترحيب عام.
String assistantGreeting(String name) {
  final t = AppLocale.texts;
  final hello = name.trim().isEmpty ? t.assistantHello : t.assistantHelloName(_oneLine(name));
  return '$hello ${t.assistantGreetingBody}';
}

// نص المستخدم يدخل التعليمات كسطر واحد حتى لا يبدو كأنه تعليمات جديدة.
String _oneLine(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
