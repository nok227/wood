import '../entities/sale_entity.dart';

abstract class SalesRepository {
  Future<List<SaleEntity>> getSales();
  Future<void> addSale(SaleEntity sale);
  Future<void> updateSaleStatus(String id, bool isConfirmed);
  Future<void> deleteSale(String id);

  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  });

  /// 🆕 ປິດໜີ້ — ຕັ້ງ debtAmount = 0 + isConfirmed = true
  Future<void> markDebtAsPaid(String id);
}