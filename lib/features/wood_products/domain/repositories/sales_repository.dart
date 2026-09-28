import '../entities/sale_entity.dart';
import '../entities/sale_order_entity.dart';

abstract class SalesRepository {
  Future<List<SaleOrderEntity>> getSaleOrders();
  Future<void> addSaleOrder(SaleOrderEntity order);
  Future<void> updateSaleStatus(String id, bool isConfirmed);
  Future<void> deleteSale(String id);

  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  });

  Future<void> markDebtAsPaid(String id);

  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  });

  Future<void> updateSaleImages(
    String id, {
    required List<String> paymentImageUrls,
    required List<String> billImageUrls,
    required List<String> topUpImageUrls,
  });
}