import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'ai_errors.dart';
import 'ai_models.dart';

enum AiProviderKind { openAiCompatible, anthropic, gemini }

/// إعداد مزوّد واحد (غير سرّي). المفتاح لا يدخل هنا أبدًا: يُحفظ وحده في التخزين الآمن.
class AiProviderConfig {
  const AiProviderConfig({
    required this.id,
    required this.kind,
    required this.baseUrl,
    required this.model,
    this.images = AiSupport.unknown,
  });

  final String id;
  final AiProviderKind kind;
  final String baseUrl;
  final String model;
  final AiSupport images;

  AiProviderConfig copyWith({String? baseUrl, String? model, AiSupport? images}) {
    return AiProviderConfig(
      id: id,
      kind: kind,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      images: images ?? this.images,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'baseUrl': baseUrl,
        'model': model,
        'images': images.name,
      };

  static AiProviderConfig? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final baseUrl = raw['baseUrl'];
    final model = raw['model'];
    if (id is! String || baseUrl is! String || model is! String) return null;
    final kind = AiProviderKind.values.where((k) => k.name == raw['kind']).firstOrNull;
    if (kind == null) return null;
    final images = AiSupport.values.where((s) => s.name == raw['images']).firstOrNull;
    return AiProviderConfig(
      id: id,
      kind: kind,
      baseUrl: baseUrl,
      model: model,
      images: images ?? AiSupport.unknown,
    );
  }

  /// يرمي [AiException] إن كان العنوان غير آمن أو اسم الموديل غير صالح.
  void validate() {
    validateBaseUrl(baseUrl);
    validateModelName(model);
  }
}

/// https فقط (v1): المفتاح يسافر في ترويسة الطلب فلا يجوز إرساله بلا تشفير. بلا بيانات
/// دخول ولا استعلام ولا جزء داخل العنوان.
Uri validateBaseUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const AiException(AiFailure.insecureUrl);
  }
  return uri;
}

final RegExp _modelNamePattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:/@-]{0,99}$');

String validateModelName(String raw) {
  final model = raw.trim();
  if (!_modelNamePattern.hasMatch(model)) throw const AiException(AiFailure.invalidModelName);
  return model;
}

/// يلصق [path] بعنوان القاعدة (الذي قد يحمل مسارًا مثل /v1) بلا شرطات مكررة.
Uri joinBaseUrl(String baseUrl, String path, {Map<String, String>? query}) {
  final base = validateBaseUrl(baseUrl);
  final basePath = base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path;
  return base.replace(path: '$basePath$path', queryParameters: query);
}

/// مزوّد ذكاء اصطناعي واحد بمفتاح واحد. كل محوّل (OpenAI-متوافق، Anthropic، Gemini) يرث منه.
abstract class AiProvider {
  AiProvider(this.config, this.apiKey, {http.Client? client}) : _client = client ?? http.Client();

  final AiProviderConfig config;
  final String apiKey;
  final http.Client _client;

  /// موديلات "التفكير" مع تعليمات نظام طويلة قد تحتاج أكثر من دقيقة قبل أول رد.
  static const Duration chatTimeout = Duration(seconds: 120);
  static const Duration listTimeout = Duration(seconds: 20);

  Future<AiReply> send(AiRequest request);

  Future<List<AiModelInfo>> listModels();

  /// طلب صغير جدًا. الرد الفارغ لا يُعدّ فشلًا: موديلات التفكير قد تستهلك حدّ الرموز كله.
  Future<void> testConnection() async {
    try {
      await send(const AiRequest(
        messages: [AiMessage.user('رد بكلمة واحدة فقط: تم')],
        maxOutputTokens: 64,
      ));
    } on AiException catch (e) {
      if (e.failure != AiFailure.emptyReply) rethrow;
    }
  }

  /// طلب POST بجسم JSON. أخطاء الشبكة والحالة تتحول إلى [AiException] دائمًا.
  Future<Map<String, dynamic>> postJson(
    Uri url,
    Map<String, String> headers,
    Map<String, Object?> body, {
    bool hadImages = false,
  }) {
    return _call(
      () => _client.post(
        url,
        headers: {...headers, 'content-type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode(body)),
      ),
      chatTimeout,
      hadImages,
    );
  }

  Future<Map<String, dynamic>> getJson(Uri url, Map<String, String> headers) {
    return _call(() => _client.get(url, headers: headers), listTimeout, false);
  }

  Future<Map<String, dynamic>> _call(
    Future<http.Response> Function() request,
    Duration timeout,
    bool hadImages,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      // الإنترنت يعمل غالبًا والمزوّد بطيء؛ لا نقول للمستخدم إن الإنترنت مقطوع.
      throw const AiException(AiFailure.timeout);
    } catch (e) {
      if (isNetworkError(e)) throw const AiException(AiFailure.network);
      throw const AiException(AiFailure.unknown);
    }
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw classifyHttpFailure(response.statusCode, text, hadImages: hadImages);
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // يسقط إلى الخطأ أدناه.
    }
    throw AiException(AiFailure.unknown, statusCode: response.statusCode);
  }
}
