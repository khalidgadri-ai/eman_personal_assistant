import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:usage_stats/usage_stats.dart';
import 'models/social_app.dart';

/// أنواع UsageEvents.Event في Android التي نحتاجها فقط.
abstract final class UsageEventType {
  static const int resumed = 1; // MOVE_TO_FOREGROUND / ACTIVITY_RESUMED
  static const int paused = 2; // MOVE_TO_BACKGROUND / ACTIVITY_PAUSED
  static const int screenOff = 16; // SCREEN_NON_INTERACTIVE
  static const int shutdown = 26; // DEVICE_SHUTDOWN
}

class UsageEventRecord {
  final String packageName;
  final int type;
  final DateTime time;

  const UsageEventRecord(this.packageName, this.type, this.time);
}

/// وقت المقدمة لكل حزمة داخل [start, end] من أحداث النظام. نحسبه من الأحداث بدل
/// queryAndAggregateUsageStats لأن حاويات Android اليومية لا تبدأ عند منتصف الليل.
Map<String, Duration> foregroundTimeByPackage(
  Iterable<UsageEventRecord> events,
  DateTime start,
  DateTime end,
) {
  final inWindow = events.where((e) => !e.time.isBefore(start) && !e.time.isAfter(end)).toList()
    ..sort((a, b) => a.time.compareTo(b.time));
  final totals = <String, Duration>{};
  final openSince = <String, DateTime>{};
  final seen = <String>{};

  void close(String package, DateTime at) {
    final since = openSince.remove(package);
    if (since != null) totals[package] = (totals[package] ?? Duration.zero) + at.difference(since);
  }

  for (final event in inWindow) {
    switch (event.type) {
      case UsageEventType.resumed:
        openSince.putIfAbsent(event.packageName, () => event.time);
        seen.add(event.packageName);
      case UsageEventType.paused:
        // أول حدث اليوم "إيقاف" = التطبيق كان مفتوحًا عند منتصف الليل.
        if (seen.add(event.packageName)) openSince[event.packageName] = start;
        close(event.packageName, event.time);
      case UsageEventType.screenOff || UsageEventType.shutdown:
        for (final package in openSince.keys.toList()) {
          close(package, event.time);
        }
    }
  }
  for (final package in openSince.keys.toList()) {
    close(package, end);
  }
  return totals;
}

List<SocialAppUsage> socialUsageFrom(Map<String, Duration> byPackage) {
  return [
    for (final app in socialApps)
      SocialAppUsage(
        app,
        app.packages
            .fold(Duration.zero, (sum, package) => sum + (byPackage[package] ?? Duration.zero))
            .inMinutes,
      ),
  ];
}

int totalMinutes(List<SocialAppUsage> usage) => usage.fold(0, (sum, u) => sum + u.minutes);

/// دقائق استخدام تطبيقات التواصل اليوم فقط، عبر صلاحية Usage Access في Android.
/// لا تسجيل دخول، ولا محتوى أو إشعارات، ولا إرسال لأي خادم: رقم واحد لكل تطبيق يُحفظ في Hive.
class UsageService {
  static const String _boxName = 'app_usage';
  static const String _snapshotKey = 'today';

  static final Set<String> _socialPackages = {for (final app in socialApps) ...app.packages};

  static Future<UsageService>? _instance;

  final Box _box;

  UsageService._(this._box);

  static Future<UsageService> getInstance() => _instance ??= _open();

  static Future<UsageService> _open() async => UsageService._(await Hive.openBox(_boxName));

  @visibleForTesting
  static void resetForTesting() => _instance = null;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await UsageStats.checkUsagePermission() ?? false;
  }

  /// يفتح صفحة "الوصول إلى بيانات الاستخدام" في إعدادات Android؛ المستخدم هو من يفعّلها.
  Future<void> openPermissionSettings() async {
    if (isSupported) await UsageStats.grantUsagePermission();
  }

  /// دقائق اليوم (منذ منتصف الليل) لكل تطبيق تواصل. تُقرأ من النظام إن كانت الصلاحية مفعّلة،
  /// وإلا تُرجع آخر قراءة محفوظة لنفس اليوم أو أصفارًا. لا تطلب الصلاحية ولا تفتح الإعدادات.
  Future<List<SocialAppUsage>> getDailyUsageByApp({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final midnight = DateTime(current.year, current.month, current.day);
    if (!await hasPermission()) return _snapshotFor(midnight);

    final raw = await UsageStats.queryEvents(midnight, current);
    final usage = socialUsageFrom(foregroundTimeByPackage(_relevantEvents(raw), midnight, current));
    await saveSnapshot(midnight, usage);
    return usage;
  }

  // أحداث بقية التطبيقات تُستبعد هنا مباشرة ولا تُحفظ في أي مكان.
  static Iterable<UsageEventRecord> _relevantEvents(List<EventUsageInfo> raw) sync* {
    for (final event in raw) {
      final type = int.tryParse(event.eventType ?? '');
      final millis = int.tryParse(event.timeStamp ?? '');
      final package = event.packageName;
      if (type == null || millis == null || package == null) continue;
      final isDeviceEvent = type == UsageEventType.screenOff || type == UsageEventType.shutdown;
      if (!isDeviceEvent && !_socialPackages.contains(package)) continue;
      yield UsageEventRecord(package, type, DateTime.fromMillisecondsSinceEpoch(millis));
    }
  }

  @visibleForTesting
  Future<void> saveSnapshot(DateTime day, List<SocialAppUsage> usage) {
    return _box.put(_snapshotKey, {
      'day': _dayKey(day),
      'minutes': {for (final u in usage) u.app.id: u.minutes},
    });
  }

  List<SocialAppUsage> _snapshotFor(DateTime day) {
    final raw = _box.get(_snapshotKey);
    final minutes = raw is Map && raw['day'] == _dayKey(day) ? raw['minutes'] as Map : const {};
    return [for (final app in socialApps) SocialAppUsage(app, (minutes[app.id] as int?) ?? 0)];
  }

  static String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';
}
