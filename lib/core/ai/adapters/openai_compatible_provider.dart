import 'dart:convert';

import '../ai_errors.dart';
import '../ai_models.dart';
import '../ai_provider.dart';

/// يغطي كل خدمة تتبع صيغة OpenAI للمحادثة: OpenAI وxAI وOpenRouter وGroq وDeepSeek وMistral
/// وأي خادم آخر بعنوان https. `{baseUrl}/chat/completions` و`{baseUrl}/models`.
class OpenAiCompatibleProvider extends AiProvider {
  OpenAiCompatibleProvider(super.config, super.apiKey, {super.client});

  Map<String, String> get _headers => {'Authorization': 'Bearer $apiKey'};

  @override
  Future<AiReply> send(AiRequest request) async {
    final model = validateModelName(config.model);
    final body = <String, Object?>{
      'model': model,
      'messages': [
        if (request.systemPrompt != null) {'role': 'system', 'content': request.systemPrompt},
        for (final m in request.messages) _message(m),
      ],
    };
    final json = await postJson(
      joinBaseUrl(config.baseUrl, '/chat/completions'),
      _headers,
      body,
      hadImages: request.hasImages,
    );
    return AiReply(_replyText(json));
  }

  Map<String, Object?> _message(AiMessage m) {
    final role = m.role == AiRole.user ? 'user' : 'assistant';
    if (m.images.isEmpty) return {'role': role, 'content': m.text};
    return {
      'role': role,
      'content': [
        {'type': 'text', 'text': m.text},
        for (final image in m.images)
          {
            'type': 'image_url',
            'image_url': {'url': 'data:${image.mimeType};base64,${base64Encode(image.bytes)}'},
          },
      ],
    };
  }

  String _replyText(Map<String, dynamic> json) {
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw const AiException(AiFailure.emptyReply);
    }
    final choice = choices.first as Map;
    final message = choice['message'];
    final content = message is Map ? message['content'] : null;
    final text = switch (content) {
      String s => s,
      List parts => parts
          .whereType<Map>()
          .map((p) => p['text'])
          .whereType<String>()
          .join('\n'),
      _ => '',
    };
    if (text.trim().isNotEmpty) return text;
    final refusal = message is Map ? message['refusal'] : null;
    if (choice['finish_reason'] == 'content_filter' || (refusal is String && refusal.isNotEmpty)) {
      throw const AiException(AiFailure.blocked);
    }
    throw const AiException(AiFailure.emptyReply);
  }

  @override
  Future<List<AiModelInfo>> listModels() async {
    final json = await getJson(joinBaseUrl(config.baseUrl, '/models'), _headers);
    final data = json['data'];
    if (data is! List) return const [];
    final models = <AiModelInfo>[];
    for (final item in data) {
      if (item is! Map || item['id'] is! String) continue;
      models.add(AiModelInfo(
        id: item['id'] as String,
        label: item['name'] is String ? item['name'] as String : null,
        supportsImages: _imageSupport(item),
      ));
    }
    models.sort((a, b) => a.id.compareTo(b.id));
    return models;
  }

  /// OpenRouter يذكر وسائط الإدخال لكل موديل؛ غيره لا يذكرها فيبقى "غير معروف".
  AiSupport _imageSupport(Map item) {
    final architecture = item['architecture'];
    final modalities = architecture is Map ? architecture['input_modalities'] : null;
    if (modalities is! List) return AiSupport.unknown;
    return modalities.contains('image') ? AiSupport.yes : AiSupport.no;
  }
}
