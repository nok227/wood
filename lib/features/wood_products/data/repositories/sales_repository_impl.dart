import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SaleEntity>> getSales() async {
    return await remoteDataSource.getSales();
  }

  @override
  Future<void> addSale(SaleEntity sale) async {
    final saleModel = SaleModel(
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
      note: sale.note,
      date: sale.date,
      isConfirmed: sale.isConfirmed,
      isMismatch: sale.isMismatch,
      mismatchNote: sale.mismatchNote,
      cashDenominations: sale.cashDenominations,
    );
    await remoteDataSource.addSale(saleModel);
  }

  @override
  Future<void> updateSaleStatus(String id, bool isConfirmed) async {
    await remoteDataSource.updateSaleStatus(id, isConfirmed);
  }

  @override
  Future<void> deleteSale(String id) async {
    await remoteDataSource.deleteSale(id);
  }

  @override
  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  }) async {
    await remoteDataSource.updateMismatchStatus(
      id,
      isMismatch: isMismatch,
      mismatchNote: mismatchNote,
    );
  }

  @override
  Future<void> markDebtAsPaid(String id) async {
    await remoteDataSource.markDebtAsPaid(id);
  }
}