import '../../domain/entities/sale_entity.dart';

class SaleModel {
  final String id;
  final String productId;
  final String productName;
  final String paymentType;
  final double totalAmount;
  final int quantity;
  final double discountPerUnit;
  final double cashPaidAmount;
  final double transferPaidAmount;
  final double debtAmount;
  final double receivedAmount;
  final List<String> paymentImageUrls;
  final List<String> billImageUrls;
  final List<String> topUpImageUrls;
  final List<String> debtPaymentImageUrls;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final DateTime? debtDate;
  final String? debtNote;
  final DateTime? appointmentDate;
  final String? note;
  final DateTime date;
  final bool isConfirmed;
  final bool isMismatch;
  final String? mismatchNote;
  final Map<int, int>? cashDenominations;

  final double? productWidth;
  final double? productLength;
  final double? productThickness;
  final String? productSizeUnit;

  SaleModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.paymentType,
    required this.totalAmount,
    this.quantity = 1,
    this.discountPerUnit = 0,
    this.cashPaidAmount = 0,
    this.transferPaidAmount = 0,
    this.debtAmount = 0,
    this.receivedAmount = 0,
    this.paymentImageUrls = const [],
    this.billImageUrls = const [],
    this.topUpImageUrls = const [],
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.debtDate,
    this.debtNote,
    this.appointmentDate,
    this.debtPaymentImageUrls = const [],
    this.note,
    required this.date,
    this.isConfirmed = false,
    this.isMismatch = false,
    this.mismatchNote,
    this.cashDenominations,
    this.productWidth,
    this.productLength,
    this.productThickness,
    this.productSizeUnit,
  });

  static String _str(dynamic v, [String def = '']) =>
      v == null ? def : v.toString();

  static String? _strOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double _dbl(dynamic v, [double def = 0]) {
    if (v == null) return def;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? def;
  }

  static double? _dblOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int _int(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  static bool _bool(dynamic v) => v == true;

  static List<String> _strList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
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

  static DateTime? _dateOrNull(dynamic v) {
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
        final count = _int(val, 0);
        if (key != null && key > 0 && count > 0) out[key] = count;
      });
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, String docId) {
    final totalAmount = _dbl(map['totalAmount']);
    final paymentType = _str(map['paymentType'], 'cash');

    double cashPaid = _dbl(map['cashPaidAmount']);
    double transferPaid = _dbl(map['transferPaidAmount']);
    final debtAmount = _dbl(map['debtAmount']);

    if (cashPaid == 0 && transferPaid == 0 && debtAmount == 0) {
      if (paymentType == 'cash') {
        cashPaid = totalAmount;
      } else if (paymentType == 'transfer') {
        transferPaid = totalAmount;
      }
    }

    return SaleModel(
      id: docId,
      productId: _str(map['productId']),
      productName: _str(map['productName']),
      paymentType: paymentType,
      totalAmount: totalAmount,
      quantity: _int(map['quantity'], 1),
      discountPerUnit: _dbl(map['discountPerUnit']),
      cashPaidAmount: cashPaid,
      transferPaidAmount: transferPaid,
      debtAmount: debtAmount,
      receivedAmount: _dbl(map['receivedAmount']),
      paymentImageUrls: _strList(map['paymentImageUrls']),
      billImageUrls: _strList(map['billImageUrls']),
      topUpImageUrls: _strList(map['topUpImageUrls']),
      customerName: _strOrNull(map['customerName']),
      customerAddress: _strOrNull(map['customerAddress']),
      customerPhone: _strOrNull(map['customerPhone']),
      debtDate: _dateOrNull(map['debtDate']),
      debtNote: _strOrNull(map['debtNote']),
      appointmentDate: _dateOrNull(map['appointmentDate']),
      note: _strOrNull(map['note']),
      date: _date(map['date']),
      isConfirmed: _bool(map['isConfirmed']),
      isMismatch: _bool(map['isMismatch']),
      mismatchNote: _strOrNull(map['mismatchNote']),
      cashDenominations: _cashDenoms(map['cashDenominations']),
      productWidth: _dblOrNull(map['productWidth']),
      productLength: _dblOrNull(map['productLength']),
      productThickness: _dblOrNull(map['productThickness']),
      productSizeUnit: _strOrNull(map['productSizeUnit']),
      debtPaymentImageUrls: _strList(map['debtPaymentImageUrls']),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'paymentType': paymentType,
        'totalAmount': totalAmount,
        'quantity': quantity,
        'discountPerUnit': discountPerUnit,
        'cashPaidAmount': cashPaidAmount,
        'transferPaidAmount': transferPaidAmount,
        'debtAmount': debtAmount,
        'receivedAmount': receivedAmount,
        'paymentImageUrls': paymentImageUrls,
        'billImageUrls': billImageUrls,
        'topUpImageUrls': topUpImageUrls,
        'customerName': customerName,
        'debtPaymentImageUrls': debtPaymentImageUrls,
        'customerAddress': customerAddress,
        'customerPhone': customerPhone,
        'debtDate': debtDate?.toIso8601String(),
        'debtNote': debtNote,
        'appointmentDate': appointmentDate?.toIso8601String(),
        'note': note,
        'date': date.toIso8601String(),
        'isConfirmed': isConfirmed,
        'isMismatch': isMismatch,
        'mismatchNote': mismatchNote,
        'cashDenominations': cashDenominations?.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'productWidth': productWidth,
        'productLength': productLength,
        'productThickness': productThickness,
        'productSizeUnit': productSizeUnit,
      };

  static SaleModel fromEntity(SaleEntity e) => SaleModel(
        id: e.id,
        productId: e.productId,
        productName: e.productName,
        paymentType: e.paymentType,
        totalAmount: e.totalAmount,
        quantity: e.quantity,
        discountPerUnit: e.discountPerUnit,
        cashPaidAmount: e.cashPaidAmount,
        transferPaidAmount: e.transferPaidAmount,
        debtAmount: e.debtAmount,
        receivedAmount: e.receivedAmount,
        paymentImageUrls: e.paymentImageUrls,
        billImageUrls: e.billImageUrls,
        topUpImageUrls: e.topUpImageUrls,
        customerName: e.customerName,
        customerAddress: e.customerAddress,
        customerPhone: e.customerPhone,
        debtDate: e.debtDate,
        debtNote: e.debtNote,
        appointmentDate: e.appointmentDate,
        debtPaymentImageUrls: e.debtPaymentImageUrls,
        note: e.note,
        date: e.date,
        isConfirmed: e.isConfirmed,
        isMismatch: e.isMismatch,
        mismatchNote: e.mismatchNote,
        cashDenominations: e.cashDenominations,
        productWidth: e.productWidth,
        productLength: e.productLength,
        productThickness: e.productThickness,
        productSizeUnit: e.productSizeUnit,
      );

  SaleEntity toEntity() => SaleEntity(
        id: id,
        productId: productId,
        productName: productName,
        paymentType: paymentType,
        totalAmount: totalAmount,
        quantity: quantity,
        discountPerUnit: discountPerUnit,
        cashPaidAmount: cashPaidAmount,
        transferPaidAmount: transferPaidAmount,
        debtAmount: debtAmount,
        debtPaymentImageUrls: debtPaymentImageUrls,
        receivedAmount: receivedAmount,
        paymentImageUrls: paymentImageUrls,
        billImageUrls: billImageUrls,
        topUpImageUrls: topUpImageUrls,
        customerName: customerName,
        customerAddress: customerAddress,
        customerPhone: customerPhone,
        debtDate: debtDate,
        debtNote: debtNote,
        appointmentDate: appointmentDate,
        note: note,
        date: date,
        isConfirmed: isConfirmed,
        isMismatch: isMismatch,
        mismatchNote: mismatchNote,
        cashDenominations: cashDenominations,
        productWidth: productWidth,
        productLength: productLength,
        productThickness: productThickness,
        productSizeUnit: productSizeUnit,
      );
}