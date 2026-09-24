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
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final DateTime? debtDate;
  final String? debtNote;
  final String? note;
  final DateTime date;
  final bool isConfirmed;
  final bool isMismatch;
  final String? mismatchNote;
  final Map<int, int>? cashDenominations;

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
    this.note,
    required this.date,
    this.isConfirmed = false,
    this.isMismatch = false,
    this.mismatchNote,
    this.cashDenominations,
  });

  // ── Safe parsers ──
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
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return DateTime.now();
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

  // ══════════════════════════════════════════════
  // Map → Model (super safe ສຳລັບຂໍ້ມູນເກົ່າ/ໃໝ່)
  // ══════════════════════════════════════════════
  factory SaleModel.fromMap(Map<String, dynamic> map, String docId) {
    final totalAmount = _dbl(map['totalAmount']);
    final paymentType = _str(map['paymentType'], 'cash');

    double cashPaid = _dbl(map['cashPaidAmount']);
    double transferPaid = _dbl(map['transferPaidAmount']);
    final debtAmount = _dbl(map['debtAmount']);

    // Backward-compatible: ຂໍ້ມູນເກົ່າທີ່ບໍ່ມີຟິວໃໝ່
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
      debtDate: map['debtDate'] != null
          ? DateTime.tryParse(map['debtDate'].toString())
          : null,
      debtNote: _strOrNull(map['debtNote']),
      note: _strOrNull(map['note']),
      date: _date(map['date']),
      isConfirmed: _bool(map['isConfirmed']),
      isMismatch: _bool(map['isMismatch']),
      mismatchNote: _strOrNull(map['mismatchNote']),
      cashDenominations: _cashDenoms(map['cashDenominations']),
    );
  }

  // ══════════════════════════════════════════════
  // Model → Map
  // ══════════════════════════════════════════════
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
        'customerAddress': customerAddress,
        'customerPhone': customerPhone,
        'debtDate': debtDate?.toIso8601String(),
        'debtNote': debtNote,
        'note': note,
        'date': date.toIso8601String(),
        'isConfirmed': isConfirmed,
        'isMismatch': isMismatch,
        'mismatchNote': mismatchNote,
        // ✅ ປ່ຽນ key ເປັນ String ກັນ Firebase error
        'cashDenominations': cashDenominations
            ?.map((k, v) => MapEntry(k.toString(), v)),
      };

  // ══════════════════════════════════════════════
  // Model → Entity
  // ══════════════════════════════════════════════
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
        receivedAmount: receivedAmount,
        paymentImageUrls: paymentImageUrls,
        billImageUrls: billImageUrls,
        topUpImageUrls: topUpImageUrls,
        customerName: customerName,
        customerAddress: customerAddress,
        customerPhone: customerPhone,
        debtDate: debtDate,
        debtNote: debtNote,
        note: note,
        date: date,
        isConfirmed: isConfirmed,
        isMismatch: isMismatch,
        mismatchNote: mismatchNote,
        cashDenominations: cashDenominations,
      );
}