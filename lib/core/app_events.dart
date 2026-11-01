import 'package:flutter/foundation.dart';

/// إشارات على مستوى التطبيق كله.
abstract final class AppEvents {
  /// يُزاد بعد "مسح كل بياناتي": البوابة تعيد قراءة الحالة وتعرض شاشة الترحيب من جديد.
  static final ValueNotifier<int> dataErased = ValueNotifier<int>(0);

  /// يُزاد بعد استعادة نسخة احتياطية: البوابة تعيد بناء الشاشات لتقرأ البيانات المستعادة.
  static final ValueNotifier<int> dataRestored = ValueNotifier<int>(0);
}
