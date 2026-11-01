import '../../../core/utils/ids.dart';

/// موعد غسيل أسبوعي: اليوم ونوع الغسيل وتعليمات العناية.
class LaundryEntry {
  const LaundryEntry({required this.id, required this.day, required this.type, this.care = ''});

  final String id;
  final String day;
  final String type;
  final String care;

  LaundryEntry copyWith({String? day, String? type, String? care}) {
    return LaundryEntry(id: id, day: day ?? this.day, type: type ?? this.type, care: care ?? this.care);
  }

  Map<String, dynamic> toMap() => {'id': id, 'day': day, 'type': type, 'care': care};

  factory LaundryEntry.fromMap(Map map) {
    final id = map['id'];
    return LaundryEntry(
      id: id is String && id.isNotEmpty ? id : newId(),
      day: '${map['day'] ?? ''}',
      type: '${map['type'] ?? ''}',
      care: '${map['care'] ?? ''}',
    );
  }
}
