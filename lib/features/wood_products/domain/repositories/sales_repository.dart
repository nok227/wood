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

  Future<void> markDebtAsPaid(String id);

  /// 🆕 ຈ່າຍໜີ້ + ເພີ່ມຮູບ
  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  });
}