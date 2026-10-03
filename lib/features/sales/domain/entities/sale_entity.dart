import 'sale_item_entity.dart';
import 'sale_order_entity.dart';

class SaleEntity {
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

  SaleEntity({
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
    this.debtPaymentImageUrls = const [],
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.debtDate,
    this.debtNote,
    this.appointmentDate,
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

  double get changeAmount {
    if (receivedAmount > totalAmount) {
      return receivedAmount - totalAmount;
    }
    if (debtAmount <= 0) {
      final applied = cashPaidAmount + transferPaidAmount;
      if (applied > totalAmount) return applied - totalAmount;
    }
    return 0;
  }

  bool get hasDebt => debtAmount > 0;
  bool get hasTopUp => topUpImageUrls.isNotEmpty;
  bool get hasDebtPayment => debtPaymentImageUrls.isNotEmpty;
  bool get isMixed => cashPaidAmount > 0 && transferPaidAmount > 0;
  bool get isFullyPaid => debtAmount <= 0;

  bool get hasAppointment => appointmentDate != null;

  bool get hasProductSize =>
      productWidth != null &&
      productLength != null &&
      productThickness != null &&
      productSizeUnit != null;

  String? get slipImageUrl {
    if (paymentImageUrls.isEmpty) return null;
    return paymentImageUrls.first;
  }
}

extension SaleEntityToOrderX on SaleEntity {
  SaleOrderEntity toOrderEntity() {
    final q = quantity <= 0 ? 1 : quantity;
    final unitPrice = (totalAmount + discountPerUnit * q) / q;

    return SaleOrderEntity(
      id: id,
      source: SaleOrderSource.legacy,
      items: [
        SaleItemEntity(
          itemId: 'legacy_$id',
          productId: productId,
          productName: productName,
          woodType: '',
          productWidth: productWidth,
          productLength: productLength,
          productThickness: productThickness,
          productSizeUnit: productSizeUnit,
          unitPrice: unitPrice,
          quantity: q,
          unit: 'ຊິ້ນ',
          discountPerUnit: discountPerUnit,
        ),
      ],
      paymentType: paymentType,
      cashPaidAmount: cashPaidAmount,
      transferPaidAmount: transferPaidAmount,
      debtAmount: debtAmount,
      receivedAmount: receivedAmount,
      paymentImageUrls: paymentImageUrls,
      billImageUrls: billImageUrls,
      topUpImageUrls: topUpImageUrls,
      debtPaymentImageUrls: debtPaymentImageUrls,
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
  }
}