import 'package:flutter/foundation.dart';
import 'ai_errors.dart';
import 'ai_models.dart';
import 'ai_provider.dart';
import 'ai_settings_service.dart';
import 'provider_presets.dart';

/// واجهة الذكاء الاصطناعي التي تستعملها الشاشات، فوق أي مزوّد (Gemini أو Claude أو أي خدمة
/// متوافقة مع OpenAI). كل قدرة دالة واحدة تبني تعليمات عربية وتسأل المزوّد المختار.
///
/// لا مفتاح مركزي أبدًا: بدون مزوّد ومفتاح أدخلهما المستخدم لا يوجد مزوّد و[isConfigured] = false.
/// أخطاء المزوّد تُعرض دائمًا رسائل عربية ثابتة من [AiFailure]، لا نص المزوّد الخام.
class AiService {
  AiService._(this._systemPrompt, this._builder);

  /// للاختبارات فقط: خدمة جاهزة بمزوّد وهمي، بدون شبكة ولا مفتاح.
  @visibleForTesting
  AiService.withProvider(
    AiProvider this._provider, {
    AiSupport images = AiSupport.yes,
    String? systemPrompt,
  })  : _systemPrompt = systemPrompt,
        _builder = buildAiProvider,
        _imageSupport = images;

  AiProvider? _provider;
  AiSupport _imageSupport = AiSupport.unknown;
  final String? _systemPrompt;
  final AiProviderBuilder _builder;

  static final String missingKeyMessage = AiFailure.missingKey.message;
  static final String emptyReplyMessage = AiFailure.emptyReply.message;
  static const String emptyImageReplyMessage = 'لم أتمكن من تحليل الصورة.';

  /// [systemPrompt] تعليمات اختيارية تُرسل مع كل طلب (مثل تعليمات المساعد العام).
  static Future<AiService> create({String? systemPrompt, AiProviderBuilder? builder}) async {
    final service = AiService._(systemPrompt, builder ?? buildAiProvider);
    await service._reload();
    return service;
  }

  Future<void> _reload() async {
    _provider = null;
    _imageSupport = AiSupport.unknown;
    try {
      final settings = await AiSettingsService.getInstance();
      final config = settings.selected;
      if (config == null) return;
      final key = await settings.readKey(config.id);
      if (key.isEmpty) return;
      config.validate();
      _provider = _builder(config, key);
      _imageSupport = config.images;
    } catch (e) {
      debugPrint('AiService: provider not ready (${e.runtimeType})');
    }
  }

  /// true فقط حين يوجد مزوّد مختار بإعداد صالح ومفتاح محفوظ.
  bool get isConfigured => _provider != null;

  AiSupport get imageSupport => _imageSupport;

  /// يحفظ مفتاح المزوّد الحالي (Gemini إن لم يُختر مزوّد بعد) ويعيد تهيئة المزوّد فورًا.
  /// مفتاح فارغ يحذفه. هذه هي الطريقة التي يفعّل بها المستخدم ميزات الذكاء الاصطناعي.
  Future<void> resetModel(String newKey) async {
    final settings = await AiSettingsService.getInstance();
    final config = settings.selected ?? settings.configFor(AiPresets.geminiId);
    await settings.saveKey(config.id, newKey);
    if (settings.selectedId == null && newKey.trim().isNotEmpty) await settings.save(config);
    await _reload();
  }

  /// آخر 4 أحرف فقط من المفتاح النشط؛ عرض أكثر من ذلك يسهّل تخمينه.
  Future<String> getActiveKeyPreview() async {
    final settings = await AiSettingsService.getInstance();
    final id = settings.selectedId;
    final preview = id == null ? '' : await settings.keyPreview(id);
    return preview.isEmpty ? 'لم يُضبط مفتاح' : preview;
  }

  /// طلب خام يرمي [AiException]؛ للمدرب الذي يحتاج تعليمات نظام وأخطاء حقيقية.
  Future<AiReply> sendRaw(AiRequest request) async {
    final provider = _provider;
    if (provider == null) throw const AiException(AiFailure.missingKey);
    final withSystem = request.systemPrompt != null || _systemPrompt == null
        ? request
        : AiRequest(
            messages: request.messages,
            systemPrompt: _systemPrompt,
            maxOutputTokens: request.maxOutputTokens,
          );
    final reply = await provider.send(withSystem);
    if (reply.text.trim().isEmpty) throw const AiException(AiFailure.emptyReply);
    return reply;
  }

  /// Sends a general text prompt to the selected provider.
  Future<String> askAssistant(String prompt) async {
    if (!isConfigured) return missingKeyMessage;
    try {
      return (await sendRaw(AiRequest(messages: [AiMessage.user(prompt)]))).text;
    } catch (e) {
      return aiFriendlyError(e);
    }
  }

  /// Analyzes an image with an optional text prompt (Multimodal Vision).
  /// الأخطاء تعود رسالة عربية ثابتة؛ لمن يحتاج التمييز بين الخطأ والرد استعمل [analyzeImageStrict].
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String prompt,
  }) async {
    try {
      return await analyzeImageStrict(imageBytes: imageBytes, mimeType: mimeType, prompt: prompt);
    } on AiException catch (e) {
      return e.failure == AiFailure.emptyReply ? emptyImageReplyMessage : aiFriendlyError(e);
    } catch (e) {
      return aiFriendlyError(e);
    }
  }

  /// مثل [analyzeImage] لكنه يرمي [AiException] عند الفشل. الموديل المعلَّم بأنه لا يدعم الصور
  /// لا يُرسل إليه شيء: يُخبَر المستخدم بدل أن تفشل المحاولة.
  Future<String> analyzeImageStrict({
    required Uint8List imageBytes,
    required String mimeType,
    required String prompt,
  }) async {
    if (!isConfigured) throw const AiException(AiFailure.missingKey);
    if (_imageSupport == AiSupport.no) throw const AiException(AiFailure.imageUnsupported);
    final reply = await sendRaw(AiRequest(messages: [
      AiMessage.user(prompt, images: [AiImage(imageBytes, mimeType)]),
    ]));
    return reply.text;
  }

  /// تعليمات تحليل صورة تمرين: JSON فقط، فيُملأ نموذج "حفظ كتمرين" مسبقًا ويراجعه المستخدم.
  static const String exerciseAnalysisPrompt = '''
أنت مدرب لياقة بدنية متخصص. حلّل صورة التمرين أو العضلة المستهدفة وأرجع JSON فقط (بلا أي نص قبله أو بعده وبلا علامات ```) بهذا الشكل:
{"name": "اسم التمرين", "muscles": "العضلات المستهدفة", "steps": ["الخطوة الأولى", "الخطوة الثانية"], "sets": 3, "reps": "10-12", "notes": "نصائح التكنيك والسلامة"}
اكتب القيم بالعربية باختصار. إن لم تكن الصورة تمرينًا أو عضلة فأرجع {"name": "", "notes": "سبب عدم التعرف"}.
''';

  /// 🏋️‍♂️ Module 2: Visual Fitness & Muscle Targeting analysis
  Future<String> analyzeExerciseImage(Uint8List imageBytes) async {
    return analyzeImage(imageBytes: imageBytes, mimeType: 'image/jpeg', prompt: exerciseAnalysisPrompt);
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
- المهمة (شخصية أو منزلية أو عائلية)
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

  static String _plainNumber(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  /// 💰 اقتراح حدود الفئات للميزانية. يُرسل أربعة أرقام فقط (الدخل ومجموع الثابتة والادخار
  /// والمتاح) بلا أسماء المصروفات ولا المصاريف المسجَّلة، **ولا يُستدعى إلا بعد موافقة صريحة
  /// من المستخدم في كل مرة** (انظر `BudgetSuggestionScreen`). الرد JSON تُحلّله
  /// `BudgetSuggestion.tryParse` كبيانات غير موثوقة.
  Future<String> suggestBudgetLimits({
    required double income,
    required double fixedTotal,
    required double savings,
    required double available,
    required String currencyName,
  }) async {
    final prompt = '''
أنت مساعد مالي شخصي. أرجع JSON فقط (بلا أي نص قبله أو بعده وبلا علامات ```) بهذا الشكل:
{"limits": {"food": 0, "transport": 0, "entertainment": 0, "bills": 0, "shopping": 0, "other": 0}, "note": "جملة أو جملتان تشرحان التوزيع"}
المفاتيح بالإنجليزية كما هي: food طعام، transport مواصلات، entertainment ترفيه، bills فواتير متغيرة، shopping تسوق، other أخرى.
القيم حدود صرف شهرية بعملة ($currencyName)، ومجموعها لا يتجاوز المتاح للصرف.

الدخل الشهري: ${_plainNumber(income)}
مجموع المصروفات الثابتة: ${_plainNumber(fixedTotal)}
هدف الادخار الشهري: ${_plainNumber(savings)}
المتاح للصرف: ${_plainNumber(available)}
''';
    return askAssistant(prompt);
  }
}
