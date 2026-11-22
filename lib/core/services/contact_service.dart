import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// يفتح تطبيق البريد برسالة جديدة إلى [email]. يرجّع false إن لم يوجد تطبيق بريد أو فشل الفتح،
/// ليعرض التطبيق العنوان للنسخ بدل أن يفشل بصمت.
typedef MailOpener = Future<bool> Function(String email, String subject);

/// يفتح رابطًا في المتصفح خارج التطبيق. يرجّع false إن فشل الفتح.
typedef LinkOpener = Future<bool> Function(Uri url);

Future<bool> openExternalLink(Uri url) async {
  try {
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openExternalLink: ${e.runtimeType}');
    return false;
  }
}

Future<bool> openMailApp(String email, String subject) async {
  try {
    // الموضوع يُرمَّز بـ %20 لا بـ + (بعض تطبيقات البريد تعرض + حرفيًا).
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openMailApp: ${e.runtimeType}');
    return false;
  }
}
