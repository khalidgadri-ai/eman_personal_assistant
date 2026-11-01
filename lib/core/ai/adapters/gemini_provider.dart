import 'dart:convert';

import '../ai_errors.dart';
import '../ai_models.dart';
import '../ai_provider.dart';

/// Gemini عبر REST مباشرة (حزمة google_generative_ai مهجورة وتفشل في قيم الرد الجديدة).
/// المفتاح في ترويسة `x-goog-api-key` لا في الرابط، حتى لا يتسرب إلى السجلات.
class GeminiProvider extends AiProvider {
  GeminiProvider(super.config, super.apiKey, {super.client});

  Map<String, String> get _headers => {'x-goog-api-key': apiKey};

  /// أسماء الموديلات تأتي من المزوّد بالبادئة `models/`؛ نقبل الشكلين.
  String _modelPath(String model) {
    final clean = validateModelName(model);
    return clean.startsWith('models/') ? clean : 'models/$clean';
  }

  @override
  Future<AiReply> send(AiRequest request) async {
    final body = <String, Object?>{
      if (request.systemPrompt != null)
        'systemInstruction': {
          'parts': [
            {'text': request.systemPrompt},
          ],
        },
      'contents': [for (final m in request.messages) _content(m)],
    };
    final json = await postJson(
      joinBaseUrl(config.baseUrl, '/v1beta/${_modelPath(config.model)}:generateContent'),
      _headers,
      body,
      hadImages: request.hasImages,
    );
    return AiReply(_replyText(json));
  }

  Map<String, Object?> _content(AiMessage m) {
    return {
      'role': m.role == AiRole.user ? 'user' : 'model',
      'parts': [
        {'text': m.text},
        for (final image in m.images)
          {
            'inlineData': {'mimeType': image.mimeType, 'data': base64Encode(image.bytes)},
          },
      ],
    };
  }

  static const Set<String> _blockedFinishReasons = {
    'SAFETY',
    'RECITATION',
    'PROHIBITED_CONTENT',
    'BLOCKLIST',
    'SPII',
    'IMAGE_SAFETY',
  };

  String _replyText(Map<String, dynamic> json) {
    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty || candidates.first is! Map) {
      final feedback = json['promptFeedback'];
      if (feedback is Map && feedback['blockReason'] != null) {
        throw const AiException(AiFailure.blocked);
      }
      throw const AiException(AiFailure.emptyReply);
    }
    final candidate = candidates.first as Map;
    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;
    // أجزاء "التفكير" ليست جزءًا من الجواب.
    final text = parts is List
        ? parts
            .whereType<Map>()
            .where((p) => p['thought'] != true)
            .map((p) => p['text'])
            .whereType<String>()
            .join()
        : '';
    if (text.trim().isNotEmpty) return text;
    if (_blockedFinishReasons.contains(candidate['finishReason'])) {
      throw const AiException(AiFailure.blocked);
    }
    throw const AiException(AiFailure.emptyReply);
  }

  @override
  Future<List<AiModelInfo>> listModels() async {
    final models = <AiModelInfo>[];
    String? pageToken;
    // الصفحة الواحدة تكفي عادة؛ الحدّ الأعلى يمنع حلقة لا تنتهي من خادم غريب.
    for (var page = 0; page < 5; page++) {
      final json = await getJson(
        joinBaseUrl(config.baseUrl, '/v1beta/models', query: {
          'pageSize': '1000',
          'pageToken': ?pageToken,
        }),
        _headers,
      );
      final data = json['models'];
      if (data is List) {
        for (final item in data) {
          if (item is! Map || item['name'] is! String) continue;
          final methods = item['supportedGenerationMethods'];
          if (methods is List && !methods.contains('generateContent')) continue;
          final name = item['name'] as String;
          models.add(AiModelInfo(
            id: name.startsWith('models/') ? name.substring(7) : name,
            label: item['displayName'] is String ? item['displayName'] as String : null,
            supportsImages: AiSupport.yes,
          ));
        }
      }
      final next = json['nextPageToken'];
      if (next is! String || next.isEmpty) break;
      pageToken = next;
    }
    models.sort((a, b) => a.id.compareTo(b.id));
    return models;
  }
}
