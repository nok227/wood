import '../../domain/entities/sale_item_entity.dart';
import '../../domain/entities/sale_order_entity.dart';

class SaleOrderModel {
  final String id;
  final List<SaleItemEntity> items;
  final String paymentType;
  final double cashPaidAmount;
  final double transferPaidAmount;
  final double debtAmount;
  final double receivedAmount;
  final List<String> paymentImageUrls;
  final List<String> billImageUrls;
  final List<String> topUpImageUrls;
  final List<String> debtPaymentImageUrls;   // 🆕
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final DateTime? debtDate;
  final String? debtNote;
  final DateTime? appointmentDate;
  final String? note;
  final DateTime date;
  final bool isConfirmed;
  final bool isMismatch;
  final String? mismatchNote;
  final Map<int, int>? cashDenominations;

  SaleOrderModel({
    required this.id,
    required this.items,
    required this.paymentType,
    this.cashPaidAmount = 0,
    this.transferPaidAmount = 0,
    this.debtAmount = 0,
    this.receivedAmount = 0,
    this.paymentImageUrls = const [],
    this.billImageUrls = const [],
    this.topUpImageUrls = const [],
    this.debtPaymentImageUrls = const [],   // 🆕
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.debtDate,
    this.debtNote,
    this.appointmentDate,
    this.note,
    required this.date,
    this.isConfirmed = false,
    this.isMismatch = false,
    this.mismatchNote,
    this.cashDenominations,
  });

  static String _s(dynamic v, [String d = '']) => v == null ? d : v.toString();

  static String? _sOr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double _d(dynamic v, [double d = 0]) {
    if (v == null) return d;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? d;
  }

  static double? _dOr(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int _i(dynamic v, [int d = 0]) {
    if (v == null) return d;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? d;
  }

  static bool _b(dynamic v) => v == true;

  static List<String> _strList(dynamic v) {
    if (v == null || v is! List) return [];
    return v
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static DateTime _date(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return DateTime.now();
  }

  static DateTime? _dateOr(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return null;
  }

  static Map<int, int>? _cashDenoms(dynamic v) {
    if (v == null) return null;
    try {
      final map = Map.from(v as Map);
      final out = <int, int>{};
      map.forEach((k, val) {
        final key = int.tryParse(k.toString());
        final c = _i(val, 0);
        if (key != null && key > 0 && c > 0) out[key] = c;
      });
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }

  static SaleItemEntity _itemFromMap(Map m) {
    return SaleItemEntity(
      itemId: _s(m['itemId']),
      productId: _s(m['productId']),
      productName: _s(m['productName']),
      woodType: _s(m['woodType']),
      productWidth: _dOr(m['productWidth']),
      productLength: _dOr(m['productLength']),
      productThickness: _dOr(m['productThickness']),
      productSizeUnit: _sOr(m['productSizeUnit']),
      unitPrice: _d(m['unitPrice']),
      quantity: _i(m['quantity'], 1),
      unit: _s(m['unit'], 'ຊິ້ນ'),
      discountPerUnit: _d(m['discountPerUnit']),
    );
  }

  static Map<String, dynamic> _itemToMap(SaleItemEntity e) => {
        'itemId': e.itemId,
        'productId': e.productId,
        'productName': e.productName,
        'woodType': e.woodType,
        'productWidth': e.productWidth,
        'productLength': e.productLength,
        'productThickness': e.productThickness,
        'productSizeUnit': e.productSizeUnit,
        'unitPrice': e.unitPrice,
        'quantity': e.quantity,
        'unit': e.unit,
        'discountPerUnit': e.discountPerUnit,
      };

  static List<SaleItemEntity> _itemsFromList(dynamic v) {
    if (v == null || v is! List) return [];
    return v.whereType<Map>().map(_itemFromMap).toList();
  }

  factory SaleOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return SaleOrderModel(
      id: docId,
      items: _itemsFromList(map['items']),
      paymentType: _s(map['paymentType'], 'cash'),
      cashPaidAmount: _d(map['cashPaidAmount']),
      transferPaidAmount: _d(map['transferPaidAmount']),
      debtAmount: _d(map['debtAmount']),
      receivedAmount: _d(map['receivedAmount']),
      paymentImageUrls: _strList(map['paymentImageUrls']),
      billImageUrls: _strList(map['billImageUrls']),
      topUpImageUrls: _strList(map['topUpImageUrls']),
      debtPaymentImageUrls: _strList(map['debtPaymentImageUrls']),   // 🆕
      customerName: _sOr(map['customerName']),
      customerPhone: _sOr(map['customerPhone']),
      customerAddress: _sOr(map['customerAddress']),
      debtDate: _dateOr(map['debtDate']),
      debtNote: _sOr(map['debtNote']),
      appointmentDate: _dateOr(map['appointmentDate']),
      note: _sOr(map['note']),
      date: _date(map['date']),
      isConfirmed: _b(map['isConfirmed']),
      isMismatch: _b(map['isMismatch']),
      mismatchNote: _sOr(map['mismatchNote']),
      cashDenominations: _cashDenoms(map['cashDenominations']),
    );
  }

  Map<String, dynamic> toMap() => {
        'items': items.map(_itemToMap).toList(),
        'paymentType': paymentType,
        'cashPaidAmount': cashPaidAmount,
        'transferPaidAmount': transferPaidAmount,
        'debtAmount': debtAmount,
        'receivedAmount': receivedAmount,
        'totalAmount': items.fold<double>(0, (s, e) => s + e.totalAmount),
        'discountTotal': items.fold<double>(0, (s, e) => s + e.discountAmount),
        'itemCount': items.length,
        'totalQuantity': items.fold<int>(0, (s, e) => s + e.quantity),
        'paymentImageUrls': paymentImageUrls,
        'billImageUrls': billImageUrls,
        'topUpImageUrls': topUpImageUrls,
        'debtPaymentImageUrls': debtPaymentImageUrls,   // 🆕
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'debtDate': debtDate?.toIso8601String(),
        'debtNote': debtNote,
        'appointmentDate': appointmentDate?.toIso8601String(),
        'note': note,
        'date': date.toIso8601String(),
        'isConfirmed': isConfirmed,
        'isMismatch': isMismatch,
        'mismatchNote': mismatchNote,
        'cashDenominations':
            cashDenominations?.map((k, v) => MapEntry(k.toString(), v)),
      };

  SaleOrderEntity toEntity() => SaleOrderEntity(
        id: id,
        items: items,
        paymentType: paymentType,
        cashPaidAmount: cashPaidAmount,
        transferPaidAmount: transferPaidAmount,
        debtAmount: debtAmount,
        receivedAmount: receivedAmount,
        paymentImageUrls: paymentImageUrls,
        billImageUrls: billImageUrls,
        topUpImageUrls: topUpImageUrls,
        debtPaymentImageUrls: debtPaymentImageUrls,   // 🆕
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        debtDate: debtDate,
        debtNote: debtNote,
        appointmentDate: appointmentDate,
        note: note,
        date: date,
        isConfirmed: isConfirmed,
        isMismatch: isMismatch,
        mismatchNote: mismatchNote,
        cashDenominations: cashDenominations,
      );

  static SaleOrderModel fromEntity(SaleOrderEntity e) => SaleOrderModel(
        id: e.id,
        items: e.items,
        paymentType: e.paymentType,
        cashPaidAmount: e.cashPaidAmount,
        transferPaidAmount: e.transferPaidAmount,
        debtAmount: e.debtAmount,
        receivedAmount: e.receivedAmount,
        paymentImageUrls: e.paymentImageUrls,
        billImageUrls: e.billImageUrls,
        topUpImageUrls: e.topUpImageUrls,
        debtPaymentImageUrls: e.debtPaymentImageUrls,   // 🆕
        customerName: e.customerName,
        customerPhone: e.customerPhone,
        customerAddress: e.customerAddress,
        debtDate: e.debtDate,
        debtNote: e.debtNote,
        appointmentDate: e.appointmentDate,
        note: e.note,
        date: e.date,
        isConfirmed: e.isConfirmed,
        isMismatch: e.isMismatch,
        mismatchNote: e.mismatchNote,
        cashDenominations: e.cashDenominations,
      );
}