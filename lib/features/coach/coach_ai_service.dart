import 'package:flutter/foundation.dart';
import '../../core/ai/ai_models.dart';
import '../../core/ai/ai_service.dart';
import 'coach_safety.dart';
import 'coach_session_service.dart';
import 'models/coach_question.dart';
import '../../core/config/app_locale.dart';
import '../../l10n/app_localizations.dart';

typedef CoachTextGenerator = Future<String> Function({
  required String systemPrompt,
  required String userContent,
});

sealed class CoachFollowUpResult {
  const CoachFollowUpResult();
}

class CrisisDetected extends CoachFollowUpResult {
  const CrisisDetected();
}

class FollowUpQuestion extends CoachFollowUpResult {
  final CoachQuestion question;
  const FollowUpQuestion(this.question);
}

class CoachAiService {
  static const String aiFollowUpId = 'ai_followup';
  static const String crisisSentinel = 'CRISIS_DETECTED';

  final CoachTextGenerator _generate;

  CoachAiService({CoachTextGenerator? generator})
      : _generate = generator ?? _generateWithProvider;

  /// تعليمات المدرب بلغة التطبيق [lang] (العربية افتراضيًا).
  static String buildSystemPrompt(CoachDomain domain, {String lang = 'ar'}) {
    if (lang == 'en') {
      return 'You are a life coach who uses Socratic questions only. Strictly forbidden: giving '
          'direct advice, suggesting a solution, psychoanalysing the user, or making any judgement. '
          "Your only task: read the user's last answer and ask exactly one short follow-up question "
          'that deepens their reflection on what they said, within the same area of '
          '${domain.label(lookupAppLocalizations(AppLocale.english))}. '
          'Reply with nothing but the question itself, in English.\n'
          "If you notice in the user's answer any sign of acute distress, despair, or possible "
          "self-harm — even if it doesn't match an obvious keyword — do not ask any question at "
          'all. Return only this exact word and nothing else: $crisisSentinel';
    }
    return 'أنت مدرب حياة يستخدم أسلوب الأسئلة السقراطية فقط. ممنوع تمامًا: تقديم '
        'نصيحة مباشرة، اقتراح حل، تحليل نفسي للمستخدم، أو إصدار أي حكم. مهمتك '
        'الوحيدة: اقرأ آخر إجابة من المستخدم واطرح سؤال متابعة واحد فقط، قصير، '
        'يعمّق تأمله فيما قاله، ضمن نفس مجال ${domain.arabicLabel}. '
        'لا ترد بأي شيء غير السؤال نفسه.\n'
        'إذا لاحظت في إجابة المستخدم أي إشارة ضيق نفسي حاد، يأس، أو احتمال '
        'إيذاء النفس — حتى لو لم تتطابق مع كلمة مفتاحية واضحة — لا تطرح أي سؤال '
        'إطلاقًا. أرجع فقط هذه الكلمة بالضبط ولا شيء غيرها: $crisisSentinel';
  }

  /// لا يُرسل أي نص للنموذج إذا احتوى إشارة أزمة، ويستبدل أي رد فيه نصيحة
  /// (أو أي فشل في الاتصال) بسؤال من البنك المحلي لنفس المجال.
  Future<CoachFollowUpResult> requestFollowUp({
    required CoachQuestion question,
    required String answer,
  }) async {
    final lang = AppLocale.current.languageCode;
    final userContent = lang == 'en'
        ? "Question: ${question.textFor(lang)}\nUser's answer: $answer"
        : 'السؤال: ${question.text}\nإجابة المستخدم: $answer';
    if (containsCrisisSignals(userContent)) return const CrisisDetected();

    try {
      final reply = (await _generate(
        systemPrompt: buildSystemPrompt(question.domain, lang: lang),
        userContent: userContent,
      ))
          .trim();
      // contains وليس == حتى لا يمر "CRISIS_DETECTED." أو `CRISIS_DETECTED`
      // من فلتر النصح ويُعرض للمستخدم كأنه سؤال.
      if (reply.toUpperCase().contains(crisisSentinel)) {
        return const CrisisDetected();
      }
      if (reply.isNotEmpty && !containsAdviceLanguage(reply)) {
        return FollowUpQuestion(CoachQuestion(
          id: aiFollowUpId,
          domain: question.domain,
          text: reply,
        ));
      }
    } catch (e) {
      debugPrint('CoachAiService: ${e.runtimeType}');
    }

    final sessions = await CoachSessionService.getInstance();
    return FollowUpQuestion(
      await sessions.showNextQuestion(question.domain, excludeId: question.id),
    );
  }

  // مزوّد المستخدم ومفتاحه فقط كما في AiService.create()، لكن عبر sendRaw: يحتاج المدرب
  // تعليمات نظام حقيقية وأن يرى أخطاء المزوّد (askAssistant يرجّع نص الخطأ كرد عادي).
  static Future<String> _generateWithProvider({
    required String systemPrompt,
    required String userContent,
  }) async {
    final service = await AiService.create(systemPrompt: systemPrompt);
    final reply = await service.sendRaw(AiRequest(messages: [AiMessage.user(userContent)]));
    return reply.text;
  }
}
