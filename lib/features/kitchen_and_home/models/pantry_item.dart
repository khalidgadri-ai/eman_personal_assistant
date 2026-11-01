import '../../../core/utils/ids.dart';
import '../../../core/utils/quantity.dart';

/// صنف في المؤونة أو المستلزمات المنزلية (مواد غذائية، تنظيف...). الكمية نص حر مثل "2 كجم".
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    this.qty = '',
    required this.category,
    this.pinned = false,
  });

  final String id;
  final String name;
  final String qty;
  final String category;
  final bool pinned;

  PantryItem copyWith({String? name, String? qty, String? category, bool? pinned}) {
    return PantryItem(
      id: id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      category: category ?? this.category,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'qty': qty,
        'category': category,
        'pinned': pinned,
      };

  /// الأصناف المحفوظة قبل المعرّفات والتثبيت تُقرأ كما هي وتأخذ معرّفًا جديدًا.
  factory PantryItem.fromMap(Map map) {
    final id = map['id'];
    return PantryItem(
      id: id is String && id.isNotEmpty ? id : newId(),
      name: '${map['name'] ?? ''}',
      qty: '${map['qty'] ?? ''}',
      category: '${map['category'] ?? 'أخرى'}',
      pinned: map['pinned'] == true,
    );
  }

  /// هل يمكن زيادة الكمية ونقصانها بزر؟ الكمية الفارغة أو التي تبدأ برقم نعم؛ "كثير" لا.
  bool get canAdjust => qty.trim().isEmpty || splitQuantityText(qty).amount != null;

  /// الكمية بعد إضافة [delta] (لا تنزل عن صفر) مع الإبقاء على وحدتها. null إن لم تكن رقمية.
  String? adjusted(int delta) {
    if (!canAdjust) return null;
    final parts = qty.trim().isEmpty ? (amount: 0.0 as double?, unit: '') : splitQuantityText(qty);
    final next = ((parts.amount ?? 0) + delta).clamp(0, 1000000).toDouble();
    return joinQuantity(next, parts.unit);
  }
}
