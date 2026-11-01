import 'dart:typed_data';

/// هل يدعم الموديل الصور؟ "غير معروف" يعني أن المزوّد لا يخبرنا والمستخدم لم يحدد.
enum AiSupport { yes, no, unknown }

enum AiRole { user, assistant }

class AiImage {
  const AiImage(this.bytes, this.mimeType);

  final Uint8List bytes;
  final String mimeType;
}

class AiMessage {
  const AiMessage.user(this.text, {this.images = const []}) : role = AiRole.user;
  const AiMessage.assistant(this.text)
      : role = AiRole.assistant,
        images = const [];

  final AiRole role;
  final String text;
  final List<AiImage> images;
}

class AiRequest {
  const AiRequest({required this.messages, this.systemPrompt, this.maxOutputTokens});

  final List<AiMessage> messages;
  final String? systemPrompt;

  /// تستعمله Anthropic وحدها لأنه إلزامي عندها؛ غيرها يتجاهله حتى لا نكسر موديلات التفكير.
  final int? maxOutputTokens;

  bool get hasImages => messages.any((m) => m.images.isNotEmpty);
}

class AiReply {
  const AiReply(this.text);

  final String text;
}

class AiModelInfo {
  const AiModelInfo({required this.id, this.label, this.supportsImages = AiSupport.unknown});

  final String id;
  final String? label;
  final AiSupport supportsImages;
}
