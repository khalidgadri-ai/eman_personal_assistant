import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';
import 'database_service.dart';

class GeminiService {
  GenerativeModel? _model;

  GeminiService._();

  /// ✅ Factory async constructor — يقرأ المفتاح من DatabaseService أولاً
  /// ثم يستخدم المفتاح الثابت في AIConfig كـ fallback احتياطي
  static Future<GeminiService> create() async {
    final service = GeminiService._();
    final db = await DatabaseService.getInstance();
    final userKey = db.getGeminiApiKey();
    final activeKey = userKey.isNotEmpty ? userKey : AIConfig.apiKey;
    service._model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: activeKey,
    );
    return service;
  }

  /// ✅ Constructor بسيط للاستخدام المتزامن (يستخدم المفتاح الثابت مبدئياً)
  GeminiService() {
    _model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.apiKey,
    );
  }

  /// ✅ يُعيد تهيئة الموديل فور تحديث المستخدم لمفتاحه
  Future<void> resetModel(String newKey) async {
    final db = await DatabaseService.getInstance();
    await db.saveGeminiApiKey(newKey);
    _model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: newKey.trim(),
    );
  }

  /// يُرجع اسم المفتاح النشط (أول 12 حرفاً فقط للخصوصية)
  Future<String> getActiveKeyPreview() async {
    final db = await DatabaseService.getInstance();
    final key = db.getGeminiApiKey();
    if (key.isEmpty) return 'لم يُضبط مفتاح مخصص';
    return '${key.substring(0, key.length > 12 ? 12 : key.length)}...';
  }

  /// Sends a general text prompt to Gemini
  Future<String> askAssistant(String prompt) async {
    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'لم يتم استلام رد من المساعد الذكي.';
    } catch (e) {
      return 'حدث خطأ أثناء التواصل مع المساعد الذكي: $e';
    }
  }

  /// Analyzes an image with an optional text prompt (Multimodal Vision)
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String prompt,
  }) async {
    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ])
      ];
      final response = await _model!.generateContent(content);
      return response.text ?? 'لم أتمكن من تحليل الصورة.';
    } catch (e) {
      return 'حدث خطأ أثناء تحليل الصورة: $e';
    }
  }

  /// 🏋️‍♂️ Module 2: Visual Fitness & Muscle Targeting analysis
  Future<String> analyzeExerciseImage(Uint8List imageBytes) async {
    return analyzeImage(
      imageBytes: imageBytes,
      mimeType: 'image/jpeg',
      prompt: '''
أنت مدرب لياقة بدنية متخصص. قُم بتحليل صورة التمرين أو العضلة المستهدفة وتوفير:
1. اسم العضلة المستهدفة والتمرين.
2. التكنيك الصحيح لأداء التمرين بسلامة.
3. التكرارات والجولات المقترحة لليوم.
اجعل الإجابة مختصرة ومنظمة في نقاط باللغة العربية.
''',
    );
  }

  /// 🥗 Module 6: Culinary & Recipe Vault generator
  Future<String> suggestRecipes(List<String> ingredients) async {
    final prompt = '''
لدي المكونات التالية في المطبخ: ${ingredients.join(', ')}.
اقترح وصفة طعام شهية وسريعة التحضير تشمل:
- اسم الوجبة
- المقادير الدقيقة (الوزن والجرام)
- خطوات التحضير
- القيمة الغذائية التقريبية
''';
    return askAssistant(prompt);
  }

  /// 🎙️ Module 3: Hybrid Voice Note to Daily Tasks Parser
  Future<String> parseVoiceNoteToTasks(String voiceNoteTranscript) async {
    final prompt = '''
قم بتحليل النص التالي المستخرج من المذكرة الصوتية واستخرج منه قائمة بالمهام المحددة والمواعيد إن وجدت:
"$voiceNoteTranscript"

قم بتنسيق الإجابة كـ قائمة نقاط منظمة تحتوي كل نقطة على:
- المباشرة بالمهام الشخصية / المنزلية / احتياجات الأطفال
- الموعد المقترح
''';
    return askAssistant(prompt);
  }

  /// 💊 Module 10: Medication & Supplement Label Analysis
  Future<String> analyzeMedicationLabel(Uint8List imageBytes) async {
    return analyzeImage(
      imageBytes: imageBytes,
      mimeType: 'image/jpeg',
      prompt: '''
قم بقراءة وتحليل علبة الدواء أو المكمل الغذائي في هذه الصورة ووفر:
1. اسم الدواء/المكمل.
2. الجرعة الموصى بها وطريقة الاستخدام.
3. التنبيهات والتحذيرات الهامة.
''',
    );
  }

  /// 💰 Module 11: Budget & Financial Recommendations
  Future<String> getBudgetAdvice({
    required double salary,
    required double fixedExpenses,
    required double savingsGoal,
  }) async {
    final prompt = '''
الراتب: $salary ريال سعودي
الفواتير والالتزامات الثابتة: $fixedExpenses ريال سعودي
هدف الادخار الشهري: $savingsGoal ريال سعودي

اقترح توزيعاً مالياً ذكياً وموازنة للمصاريف الشخصية، التسوق، والسفر، والاشتراكات لضمان تحقيق الهدف المالي بأسلوب مريح.
قسّم الإجابة بشكل واضح بالأرقام والنسب المئوية.
''';
    return askAssistant(prompt);
  }
}
