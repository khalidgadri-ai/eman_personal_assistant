import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// سبب فشل طلب الذكاء الاصطناعي. الرسالة عربية ثابتة: نص الخطأ الخام من المزوّد لا يُعرض
/// ولا يُسجَّل، والمفتاح لا يظهر في أي رسالة.
enum AiFailure {
  missingKey('يلزم إعداد مزوّد الذكاء الاصطناعي ومفتاحه من الإعدادات أولًا.'),
  invalidKey('المفتاح غير صالح أو منتهي. يرجى تحديثه من إعدادات مزوّد الذكاء الاصطناعي ثم إعادة المحاولة.'),
  modelNotFound(
    'الموديل المختار غير موجود أو أُوقف. يرجى تحديث قائمة الموديلات من الإعدادات واختيار موديل آخر.',
  ),
  rateLimited(
    'تم بلوغ حد الاستخدام أو الرصيد لدى المزوّد. يرجى الانتظار قليلًا أو مراجعة الحساب لديه ثم إعادة المحاولة.',
  ),
  busy('خدمة المزوّد مشغولة الآن. يرجى المحاولة بعد قليل.'),
  network('تعذّر الاتصال بالإنترنت. يرجى التحقق من الشبكة ثم إعادة المحاولة.'),
  badRequest('رفض المزوّد الطلب. قد لا يدعم الموديل هذا النوع من الطلبات، فجرّب موديلًا آخر.'),
  imageUnsupported(
    'الموديل المختار لا يدعم الصور. يرجى اختيار موديل يدعمها من إعدادات مزوّد الذكاء الاصطناعي.',
  ),
  blocked('تعذّر تكوين رد لهذا الطلب. جرّب صياغة مختلفة.'),
  unsupportedLocation('خدمة المزوّد غير متاحة في بلدك حاليًا.'),
  insecureUrl('عنوان المزوّد يجب أن يبدأ بـ https:// ويكون عنوانًا صحيحًا.'),
  invalidModelName('اسم الموديل غير صالح. يُسمح بالحروف والأرقام والرموز - _ . : / @ فقط.'),
  emptyReply('لم يتم استلام رد من المساعد الذكي.'),
  unknown('حدث خطأ غير متوقع مع المساعد الذكي. يرجى المحاولة مرة أخرى بعد قليل.');

  const AiFailure(this.message);
  final String message;
}

class AiException implements Exception {
  const AiException(this.failure, {this.statusCode});

  final AiFailure failure;
  final int? statusCode;

  String get message => failure.message;

  @override
  String toString() => 'AiException(${failure.name}${statusCode == null ? '' : ', $statusCode'})';
}

/// يحوّل أي استثناء إلى رسالة عربية ثابتة. يُسجَّل نوع الاستثناء وحده.
String aiFriendlyError(Object error) {
  if (error is AiException) {
    debugPrint('AI error: ${error.failure.name} ${error.statusCode ?? ''}');
    return error.message;
  }
  debugPrint('AI error: ${error.runtimeType}');
  if (isNetworkError(error)) return AiFailure.network.message;
  return AiFailure.unknown.message;
}

bool isNetworkError(Object error) =>
    error is TimeoutException ||
    error is SocketException ||
    error is http.ClientException ||
    error is HandshakeException ||
    error is TlsException;

/// يصنّف ردًا فاشلًا من المزوّد برمز الحالة أولًا ثم بمطابقة محدودة لحقول الخطأ (الرسالة والنوع
/// والحالة فقط). الجسم الخام لا يُرجَع ولا يُطبع.
AiException classifyHttpFailure(int status, String body, {bool hadImages = false}) {
  final text = _errorFields(body).toLowerCase();
  bool has(List<String> needles) => needles.any(text.contains);
  AiException fail(AiFailure f) => AiException(f, statusCode: status);

  if (has(['user location is not supported', 'location is not supported'])) {
    return fail(AiFailure.unsupportedLocation);
  }
  // Gemini يردّ 400 (لا 401) عند مفتاح خاطئ.
  if (status == 401 ||
      has([
        'api key not valid',
        'api_key_invalid',
        'invalid api key',
        'incorrect api key',
        'invalid x-api-key',
        'authentication_error',
        'unauthenticated',
      ])) {
    return fail(AiFailure.invalidKey);
  }
  if (status == 404 ||
      has([
        'model_not_found',
        'model not found',
        'not_found_error',
        'does not exist',
        'no longer available',
        'has been shut down',
        'decommissioned',
        'deprecated',
      ])) {
    return fail(AiFailure.modelNotFound);
  }
  if (status == 403 || has(['permission_denied', 'permission denied'])) {
    return fail(AiFailure.invalidKey);
  }
  if (status == 429 ||
      has([
        'rate limit',
        'rate_limit',
        'quota',
        'resource_exhausted',
        'insufficient_quota',
        'credit balance',
      ])) {
    return fail(AiFailure.rateLimited);
  }
  if (status >= 500 || has(['overloaded'])) return fail(AiFailure.busy);
  if (hadImages &&
      (status == 400 || status == 413 || status == 415 || status == 422) &&
      has(['image', 'vision', 'multimodal', 'media type', 'modalit'])) {
    return fail(AiFailure.imageUnsupported);
  }
  if (has(['safety', 'blocked', 'content_filter', 'content policy', 'prohibited'])) {
    return fail(AiFailure.blocked);
  }
  if (status == 400 || status == 413 || status == 415 || status == 422) {
    return fail(AiFailure.badRequest);
  }
  return fail(AiFailure.unknown);
}

/// حقول الخطأ فقط (message/type/status/code) من جسم JSON، أو أول جزء قصير من النص إن لم يكن JSON.
String _errorFields(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final error = decoded['error'];
      final parts = <String>[];
      void take(Object? source) {
        if (source is Map) {
          for (final key in const ['message', 'type', 'status', 'code']) {
            final v = source[key];
            if (v is String || v is num) parts.add('$v');
          }
        } else if (source is String) {
          parts.add(source);
        }
      }

      take(error);
      take(decoded);
      return parts.join(' | ');
    }
  } catch (_) {
    // ليس JSON: نستعمل بداية النص فقط.
  }
  return body.length > 300 ? body.substring(0, 300) : body;
}
