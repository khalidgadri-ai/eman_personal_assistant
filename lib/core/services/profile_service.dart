import 'package:hive/hive.dart';
import 'encrypted_boxes.dart';

/// ما يكتبه المستخدم عن نفسه في شاشة الترحيب: لا شيء منه مكتوب مسبقًا في التطبيق.
class UserProfile {
  static const int maxNameLength = 40;
  static const int maxItemLength = 80;
  static const int maxInterests = 12;
  static const int maxGoals = 8;

  final String name;
  final List<String> interests;
  final List<String> goals;

  const UserProfile({this.name = '', this.interests = const [], this.goals = const []});

  /// ينظّف المدخلات: مسافات وأسطر زائدة، تكرار، وأطوال وأعداد قصوى. القص يتم على
  /// الأحرف الكاملة حتى لا ينكسر إيموجي في المنتصف.
  factory UserProfile.sanitized({
    String name = '',
    Iterable<String> interests = const [],
    Iterable<String> goals = const [],
  }) {
    return UserProfile(
      name: _clean(name, maxNameLength),
      interests: _cleanList(interests, maxInterests),
      goals: _cleanList(goals, maxGoals),
    );
  }

  bool get isEmpty => name.isEmpty && interests.isEmpty && goals.isEmpty;

  Map<String, dynamic> toMap() => {'name': name, 'interests': interests, 'goals': goals};

  factory UserProfile.fromMap(Map map) {
    List<String> list(Object? value) =>
        value is List ? value.whereType<String>().toList() : const <String>[];
    return UserProfile(
      name: (map['name'] as String?) ?? '',
      interests: list(map['interests']),
      goals: list(map['goals']),
    );
  }

  static String _clean(String input, int max) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    return String.fromCharCodes(cleaned.runes.take(max));
  }

  static List<String> _cleanList(Iterable<String> input, int maxCount) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in input) {
      final item = _clean(raw, maxItemLength);
      if (item.isEmpty || !seen.add(item)) continue;
      result.add(item);
      if (result.length == maxCount) break;
    }
    return result;
  }
}

/// الملف الشخصي في صندوق Hive مشفّر. وجود الملف = أُكمل الترحيب (حتى لو كان فارغًا
/// لأن المستخدم اختار "تخطي")، فلا تظهر شاشة الترحيب مرة ثانية.
class ProfileService {
  static const String _boxName = 'profile';
  static const String _profileKey = 'profile';

  static ProfileService? _instance;
  static Box? _box;

  ProfileService._();

  static Future<ProfileService> getInstance() async {
    _instance ??= ProfileService._();
    _box ??= await EncryptedBoxes.open(_boxName);
    return _instance!;
  }

  /// يُنسى الصندوق المفتوح (بعد مسح بيانات المستخدم يُفتح صندوق جديد عند الطلب).
  static void reset() {
    _instance = null;
    _box = null;
  }

  bool get onboarded => _box!.containsKey(_profileKey);

  /// null قبل إكمال الترحيب.
  UserProfile? get profile {
    final raw = _box!.get(_profileKey);
    return raw is Map ? UserProfile.fromMap(raw) : null;
  }

  Future<void> save(UserProfile profile) async {
    final clean = UserProfile.sanitized(
      name: profile.name,
      interests: profile.interests,
      goals: profile.goals,
    );
    await _box!.put(_profileKey, clean.toMap());
  }
}
