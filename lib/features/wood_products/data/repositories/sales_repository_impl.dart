import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SaleEntity>> getSales() => remoteDataSource.getSales();

  @override
  Future<void> addSale(SaleEntity sale) async {
    final m = SaleModel(
      id: sale.id,
      productId: sale.productId,
      productName: sale.productName,
      paymentType: sale.paymentType,
      totalAmount: sale.totalAmount,
      quantity: sale.quantity,
      discountPerUnit: sale.discountPerUnit,
      cashPaidAmount: sale.cashPaidAmount,
      transferPaidAmount: sale.transferPaidAmount,
      debtAmount: sale.debtAmount,
      receivedAmount: sale.receivedAmount,
      paymentImageUrls: sale.paymentImageUrls,
      billImageUrls: sale.billImageUrls,
      topUpImageUrls: sale.topUpImageUrls,
      customerName: sale.customerName,
      customerAddress: sale.customerAddress,
      customerPhone: sale.customerPhone,
      debtDate: sale.debtDate,
      debtNote: sale.debtNote,
      appointmentDate: sale.appointmentDate,
      note: sale.note,
      date: sale.date,
      isConfirmed: sale.isConfirmed,
      isMismatch: sale.isMismatch,
      mismatchNote: sale.mismatchNote,
      cashDenominations: sale.cashDenominations,
      // 📐 ຂະໜາດ
      productWidth: sale.productWidth,
      productLength: sale.productLength,
      productThickness: sale.productThickness,
      productSizeUnit: sale.productSizeUnit,
    );
    await remoteDataSource.addSale(m);
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