import 'dart:convert';

import '../ai_errors.dart';
import '../ai_models.dart';
import '../ai_provider.dart';

/// Claude عبر Messages API: `POST /v1/messages` و`GET /v1/models`.
class AnthropicProvider extends AiProvider {
  AnthropicProvider(super.config, super.apiKey, {super.client});

  static const String apiVersion = '2023-06-01';

  /// حدّ الرد حين لا يحدده الطلب؛ Anthropic ترفض الطلب بدونه.
  static const int defaultMaxTokens = 4096;

  Map<String, String> get _headers => {'x-api-key': apiKey, 'anthropic-version': apiVersion};

  @override
  Future<AiReply> send(AiRequest request) async {
    final model = validateModelName(config.model);
    final body = <String, Object?>{
      'model': model,
      'max_tokens': request.maxOutputTokens ?? defaultMaxTokens,
      if (request.systemPrompt != null) 'system': request.systemPrompt,
      'messages': [for (final m in request.messages) _message(m)],
    };
    final json = await postJson(
      joinBaseUrl(config.baseUrl, '/v1/messages'),
      _headers,
      body,
      hadImages: request.hasImages,
    );
    return AiReply(_replyText(json));
  }

  Map<String, Object?> _message(AiMessage m) {
    return {
      'role': m.role == AiRole.user ? 'user' : 'assistant',
      'content': [
        for (final image in m.images)
          {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': image.mimeType,
              'data': base64Encode(image.bytes),
            },
          },
        {'type': 'text', 'text': m.text},
      ],
    };
  }

  String _replyText(Map<String, dynamic> json) {
    final content = json['content'];
    final text = content is List
        ? content
            .whereType<Map>()
            .where((b) => b['type'] == 'text')
            .map((b) => b['text'])
            .whereType<String>()
            .join('\n')
        : '';
    if (text.trim().isNotEmpty) return text;
    if (json['stop_reason'] == 'refusal') throw const AiException(AiFailure.blocked);
    throw const AiException(AiFailure.emptyReply);
  }

  @override
  Future<List<AiModelInfo>> listModels() async {
    final json = await getJson(
      joinBaseUrl(config.baseUrl, '/v1/models', query: {'limit': '1000'}),
      _headers,
    );
    final data = json['data'];
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map && item['id'] is String)
          AiModelInfo(
            id: item['id'] as String,
            label: item['display_name'] is String ? item['display_name'] as String : null,
            supportsImages: AiSupport.yes,
          ),
    ];
  }
}
