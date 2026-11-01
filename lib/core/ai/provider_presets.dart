import 'package:http/http.dart' as http;
import '../config/ai_config.dart';
import 'adapters/anthropic_provider.dart';
import 'adapters/gemini_provider.dart';
import 'adapters/openai_compatible_provider.dart';
import 'ai_models.dart';
import 'ai_provider.dart';

/// مزوّد جاهز في القائمة: عنوان القاعدة ورابط إنشاء المفتاح فقط، **بلا اسم موديل**
/// (أسماء الموديلات تتغير وتُوقَف؛ المستخدم يكتب الاسم أو يجلبه من المزوّد).
/// العناوين تُراجَع على مراجع المزوّدين الرسمية قبل كل إصدار.
class AiProviderPreset {
  const AiProviderPreset({
    required this.id,
    required this.label,
    required this.kind,
    required this.baseUrl,
    required this.keyUrl,
    this.images = AiSupport.unknown,
    this.defaultModel = '',
    this.editableUrl = false,
  });

  final String id;
  final String label;
  final AiProviderKind kind;
  final String baseUrl;
  final String keyUrl;
  final AiSupport images;

  /// اقتراح ابتدائي فقط (لـ Gemini)، والمستخدم يغيّره.
  final String defaultModel;

  /// "مخصص" وحده يسمح بتعديل العنوان؛ الجاهز مقفل حتى لا يُرسل المفتاح إلى مضيف بخطأ إملائي.
  final bool editableUrl;

  AiProviderConfig get defaultConfig => AiProviderConfig(
        id: id,
        kind: kind,
        baseUrl: baseUrl,
        model: defaultModel,
        images: images,
      );
}

abstract final class AiPresets {
  static const String geminiId = 'gemini';
  static const String customId = 'custom';

  static const List<AiProviderPreset> all = [
    AiProviderPreset(
      id: geminiId,
      label: 'Google Gemini',
      kind: AiProviderKind.gemini,
      baseUrl: 'https://generativelanguage.googleapis.com',
      keyUrl: 'https://aistudio.google.com/app/apikey',
      images: AiSupport.yes,
      defaultModel: AIConfig.modelName,
    ),
    AiProviderPreset(
      id: 'openai',
      label: 'OpenAI (ChatGPT)',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://api.openai.com/v1',
      keyUrl: 'https://platform.openai.com/api-keys',
    ),
    AiProviderPreset(
      id: 'anthropic',
      label: 'Anthropic (Claude)',
      kind: AiProviderKind.anthropic,
      baseUrl: 'https://api.anthropic.com',
      keyUrl: 'https://console.anthropic.com/settings/keys',
      images: AiSupport.yes,
    ),
    AiProviderPreset(
      id: 'xai',
      label: 'xAI (Grok)',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://api.x.ai/v1',
      keyUrl: 'https://console.x.ai',
    ),
    AiProviderPreset(
      id: 'openrouter',
      label: 'OpenRouter',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://openrouter.ai/api/v1',
      keyUrl: 'https://openrouter.ai/keys',
    ),
    AiProviderPreset(
      id: 'groq',
      label: 'Groq',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://api.groq.com/openai/v1',
      keyUrl: 'https://console.groq.com/keys',
    ),
    AiProviderPreset(
      id: 'deepseek',
      label: 'DeepSeek',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://api.deepseek.com',
      keyUrl: 'https://platform.deepseek.com/api_keys',
    ),
    AiProviderPreset(
      id: 'mistral',
      label: 'Mistral',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: 'https://api.mistral.ai/v1',
      keyUrl: 'https://console.mistral.ai/api-keys',
    ),
    AiProviderPreset(
      id: customId,
      label: 'مخصص (متوافق مع OpenAI)',
      kind: AiProviderKind.openAiCompatible,
      baseUrl: '',
      keyUrl: '',
      editableUrl: true,
    ),
  ];

  static AiProviderPreset byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);

  static bool exists(String id) => all.any((p) => p.id == id);
}

/// يبني المحوّل المناسب لنوع المزوّد. [client] للاختبارات فقط.
typedef AiProviderBuilder = AiProvider Function(AiProviderConfig config, String apiKey);

AiProvider buildAiProvider(AiProviderConfig config, String apiKey, {http.Client? client}) {
  return switch (config.kind) {
    AiProviderKind.openAiCompatible => OpenAiCompatibleProvider(config, apiKey, client: client),
    AiProviderKind.anthropic => AnthropicProvider(config, apiKey, client: client),
    AiProviderKind.gemini => GeminiProvider(config, apiKey, client: client),
  };
}
