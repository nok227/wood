class SaleEntity {
  final String id;
  final String productId;
  final String productName;
  final String paymentType; // 'cash' | 'transfer' | 'mixed'

  final double totalAmount;
  final int quantity;
  final double discountPerUnit;

  // 💵 ຈຳນວນເງິນທີ່ຈ່າຍຕົວຈິງ (ແບ່ງໄດ້)
  final double cashPaidAmount;      // ສົດທີ່ຈ່າຍ
  final double transferPaidAmount;  // ໂອນທີ່ຈ່າຍ
  final double debtAmount;          // ຕິດໜີ້ (0 = ຈ່າຍເຕັມ)

  // ສົດທີ່ຮັບມາ (ສຳລັບຄິດເງິນທອນ)
  final double receivedAmount;

  // 🖼️ ຮູບພາບ
  final List<String> paymentImageUrls; // ຮູບສົດ / ສະລິບ
  final List<String> billImageUrls;    // ຮູບໃບບິນ
  final List<String> topUpImageUrls;   // ຮູບເງິນເຕີມ (ສົດ/ສະລິບ)

  // 👤 ຂໍ້ມູນລູກຄ້າ (ຕິດໜີ້)
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

  double get changeAmount =>
      receivedAmount > totalAmount ? receivedAmount - totalAmount : 0;

  bool get hasDebt => debtAmount > 0;
  bool get hasTopUp => topUpImageUrls.isNotEmpty;
  bool get isMixed => cashPaidAmount > 0 && transferPaidAmount > 0;

  /// ✅ ຈ່າຍເຕັມຈຳນວນແລ້ວ (ບໍ່ມີໜີ້)
  bool get isFullyPaid => debtAmount <= 0;

  String? get slipImageUrl {
    if (paymentImageUrls.isEmpty) return null;
    return paymentImageUrls.first;
  }
}