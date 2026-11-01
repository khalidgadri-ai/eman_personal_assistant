import '../../../core/utils/ids.dart';

/// بند في قائمة المشتريات. [source] يوضح من أين جاء: وصفة أو "نفد من المؤونة".
class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.qty = '',
    this.done = false,
    this.source = '',
  });

  final String id;
  final String name;
  final String qty;
  final bool done;
  final String source;

  ShoppingItem copyWith({String? name, String? qty, bool? done, String? source}) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      done: done ?? this.done,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'qty': qty,
        'done': done,
        'source': source,
      };

  factory ShoppingItem.fromMap(Map map) {
    final id = map['id'];
    return ShoppingItem(
      id: id is String && id.isNotEmpty ? id : newId(),
      name: '${map['name'] ?? ''}',
      qty: '${map['qty'] ?? ''}',
      done: map['done'] == true,
      source: '${map['source'] ?? ''}',
    );
  }
}
