import '../../domain/entities/sale_order_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../models/sale_order_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SaleOrderEntity>> getSaleOrders() =>
      remoteDataSource.getSaleOrders();

  @override
  Future<void> addSaleOrder(SaleOrderEntity order) async {
    await remoteDataSource.addSaleOrder(SaleOrderModel.fromEntity(order));
  }

  @override
  Future<void> updateSaleStatus(String id, bool isConfirmed) =>
      remoteDataSource.updateSaleStatus(id, isConfirmed);

  @override
  Future<void> deleteSale(String id) => remoteDataSource.deleteSale(id);

  @override
  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  }) =>
      remoteDataSource.updateMismatchStatus(
        id,
        isMismatch: isMismatch,
        mismatchNote: mismatchNote,
      );

  @override
  Future<void> markDebtAsPaid(String id) =>
      remoteDataSource.markDebtAsPaid(id);

  @override
  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  }) =>
      remoteDataSource.payDebt(
        id,
        paymentType: paymentType,
        imageUrl: imageUrl,
        paidAmount: paidAmount,
      );

  @override
  Future<void> updateSaleImages(
    String id, {
    required List<String> paymentImageUrls,
    required List<String> billImageUrls,
    required List<String> topUpImageUrls,
  }) =>
      remoteDataSource.updateSaleImages(
        id,
        paymentImageUrls: paymentImageUrls,
        billImageUrls: billImageUrls,
        topUpImageUrls: topUpImageUrls,
      );
}