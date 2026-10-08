import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../../core/services/database_service.dart';
import 'coach_safety.dart';
import 'coach_session_service.dart';
import 'models/coach_question.dart';

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
      : _generate = generator ?? _generateWithGemini;

  static String buildSystemPrompt(CoachDomain domain) {
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
    final userContent = 'السؤال: ${question.text}\nإجابة المستخدم: $answer';
    if (containsCrisisSignals(userContent)) return const CrisisDetected();

    try {
      final reply = (await _generate(
        systemPrompt: buildSystemPrompt(question.domain),
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
      debugPrint('CoachAiService: $e');
    }

    final sessions = await CoachSessionService.getInstance();
    return FollowUpQuestion(
      sessions.pickQuestion(question.domain, excludeId: question.id),
    );
  }

  // مفتاح المستخدم فقط كما في GeminiService.create()، لكن بدون askAssistant لأنه
  // يرجّع نص الخطأ كرد عادي ولا يدعم systemInstruction.
  static Future<String> _generateWithGemini({
    required String systemPrompt,
    required String userContent,
  }) async {
    final db = await DatabaseService.getInstance();
    final userKey = db.getGeminiApiKey();
    if (userKey.isEmpty) throw StateError('لا يوجد مفتاح Gemini للمستخدم');
    final model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: userKey,
      systemInstruction: Content.system(systemPrompt),
    );
    final response = await model.generateContent([Content.text(userContent)]);
    return response.text ?? '';
  }
}
