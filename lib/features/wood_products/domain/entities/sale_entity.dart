class SaleEntity {
  final String id;
  final String productId;
  final String productName;
  final String paymentType; // 'cash' | 'transfer' | 'mixed'

  final double totalAmount;
  final int quantity;
  final double discountPerUnit;

  // 💵 ຈຳນວນເງິນທີ່ຈ່າຍຕົວຈິງ (ແບ່ງໄດ້)
  final double cashPaidAmount;
  final double transferPaidAmount;
  final double debtAmount;

  // ສົດທີ່ຮັບມາ
  final double receivedAmount;

  // 🖼️ ຮູບພາບ
  final List<String> paymentImageUrls;
  final List<String> billImageUrls;
  final List<String> topUpImageUrls;

  // 👤 ຂໍ້ມູນລູກຄ້າ (ຕິດໜີ້)
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final DateTime? debtDate;
  final String? debtNote;

  // 🆕 ນັດວັນຈ່າຍໜີ້
  final DateTime? appointmentDate;

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
    this.appointmentDate,
    this.note,
    required this.date,
    this.isConfirmed = false,
    this.isMismatch = false,
    this.mismatchNote,
    this.cashDenominations,
  });

  /// 💰 ເງິນທອນ — ຄຳນວນຈາກ receivedAmount ກ່ອນ
  /// ຖ້າບໍ່ມີ → fallback ຄຳນວນຈາກ cashPaid + transferPaid
  ///
  /// ເຫດຜົນ: ໃນການຂາຍສົດ ຖ້າລູກຄ້າຈ່າຍເກີນ
  ///   - receivedAmount = 100000 (ຮັບມາຕອນຂາຍ)
  ///   - cashPaidAmount  = 80000  (ຍອດທີ່ຫັກຈາກສິນຄ້າ — capped ບໍ່ໃຫ້ເກີນ total)
  /// ສະນັ້ນ ຕ້ອງໃຊ້ receivedAmount ເປັນຫຼັກ
  double get changeAmount {
    // ── ກໍລະນີມີ receivedAmount → ໃຊ້ອັນນີ້ກ່ອນ ──
    if (receivedAmount > totalAmount) {
      return receivedAmount - totalAmount;
    }
    // ── Fallback: ຄຳນວນຈາກ cashPaid + transferPaid ລວມ ──
    // (ກໍລະນີເກົ່າທີ່ບໍ່ມີ receivedAmount ຫຼື ຖືກ 0)
    if (debtAmount <= 0) {
      final applied = cashPaidAmount + transferPaidAmount;
      if (applied > totalAmount) return applied - totalAmount;
    }
    return 0;
  }

  bool get hasDebt => debtAmount > 0;
  bool get hasTopUp => topUpImageUrls.isNotEmpty;
  bool get isMixed => cashPaidAmount > 0 && transferPaidAmount > 0;
  bool get isFullyPaid => debtAmount <= 0;

  /// 🆕 ມີນັດວັນຈ່າຍບໍ
  bool get hasAppointment => appointmentDate != null;

  String? get slipImageUrl {
    if (paymentImageUrls.isEmpty) return null;
    return paymentImageUrls.first;
  }
}