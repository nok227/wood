import 'sale_item_entity.dart';

enum SaleOrderSource { order, legacy }

class SaleOrderEntity {
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
  final List<String> debtPaymentImageUrls;

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

  final SaleOrderSource source;

  SaleOrderEntity({
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
    this.debtPaymentImageUrls = const [],
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
    this.source = SaleOrderSource.order,
  });

  double get grossAmount => items.fold(0, (s, e) => s + e.grossAmount);
  double get discountTotal => items.fold(0, (s, e) => s + e.discountAmount);
  double get totalAmount => items.fold(0, (s, e) => s + e.totalAmount);
  int get totalQuantity => items.fold(0, (s, e) => s + e.quantity);
  int get itemCount => items.length;

  bool get hasDebt => debtAmount > 0;
  bool get hasDebtPayment => debtPaymentImageUrls.isNotEmpty;
  bool get isMixed => cashPaidAmount > 0 && transferPaidAmount > 0;
  bool get hasMultiItems => items.length > 1;
  bool get hasDiscount => discountTotal > 0;
  bool get isFullyPaid => debtAmount <= 0;
  bool get hasAppointment => appointmentDate != null;

  double get changeAmount {
    if (receivedAmount > totalAmount) return receivedAmount - totalAmount;
    if (debtAmount <= 0) {
      final applied = cashPaidAmount + transferPaidAmount;
      if (applied > totalAmount) return applied - totalAmount;
    }
    return 0;
  }

  String? get slipImageUrl {
    if (paymentImageUrls.isEmpty) return null;
    return paymentImageUrls.first;
  }

  String get primaryProductName =>
      items.isEmpty ? 'ລາຍການໄມ້' : items.first.productName;

  String get shortSummary {
    if (items.isEmpty) return 'ລາຍການໄມ້';
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} +${items.length - 1} ລາຍການ';
  }
}