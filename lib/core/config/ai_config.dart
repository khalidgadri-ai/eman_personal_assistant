class AIConfig {
  /// اقتراح ابتدائي لموديل Gemini في إعداد المزوّد؛ **المستخدم يغيّره** من شاشة الإعدادات أو
  /// يجلبه من المزوّد، ولا يوجد موديل مثبّت في الاستدعاءات. هذا الملف الوحيد المسموح بحمل الاسم.
  ///
  /// المصدر: https://ai.google.dev/gemini-api/docs/models (Gemini 3.8 Flash، "New Stable").
  /// الاسم القديم gemini-2.0-flash أُغلق في 1 يونيو 2026
  /// (https://ai.google.dev/gemini-api/docs/deprecations)، فأي طلب به يفشل.
  /// عند تغيير الاسم راجع الصفحتين ولا تخمّن الاسم.
  static const String modelName = 'gemini-3.8-flash';
}
