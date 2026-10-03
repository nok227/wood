import '../../domain/entities/account_transaction.dart';

class AccountTransactionModel {
  final String id;
  final String type;
  final String paymentType;
  final List<AccountItem> items;
  final String? note;
  final DateTime date;

  AccountTransactionModel({
    required this.id,
    required this.type,
    required this.paymentType,
    required this.items,
    this.note,
    required this.date,
  });

  static String _s(dynamic v, [String def = '']) =>
      v == null ? def : v.toString();

  static String? _sOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double _d(dynamic v, [double def = 0]) {
    if (v == null) return def;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? def;
  }

  static List<AccountItem> _items(dynamic v) {
    if (v == null || v is! List) return [];
    return v
        .whereType<Map>()
        .map((m) => AccountItem(
              name: _s(m['name']),
              price: _d(m['price']),
            ))
        .toList();
  }

  factory AccountTransactionModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return AccountTransactionModel(
      id: docId,
      type: _s(map['type'], 'in'),
      paymentType: _s(map['paymentType'], 'cash'),
      items: _items(map['items']),
      note: _sOrNull(map['note']),
      date: map['date'] != null
          ? (map['date'] is String
              ? DateTime.tryParse(map['date']) ?? DateTime.now()
              : (map['date'] as dynamic).toDate())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'paymentType': paymentType,
        'items': items
            .map((i) => {'name': i.name, 'price': i.price})
            .toList(),
        'note': note,
        'date': date.toIso8601String(),
      };

  AccountTransaction toEntity() => AccountTransaction(
        id: id,
        type: type,
        paymentType: paymentType,
        items: items,
        note: note,
        date: date,
      );
}