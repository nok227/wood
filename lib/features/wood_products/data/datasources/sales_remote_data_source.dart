import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale_entity.dart';
import '../models/sale_model.dart';

class SalesRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'sales';

  Future<List<SaleEntity>> getSales() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => SaleModel.fromMap(d.data(), d.id).toEntity())
        .toList();
  }

  Future<void> addSale(SaleModel sale) async {
    await _firestore.collection(_collection).doc(sale.id).set(sale.toMap());
  }

  Future<void> updateSaleStatus(String id, bool isConfirmed) async {
    await _firestore.collection(_collection).doc(id).update({
      'isConfirmed': isConfirmed,
      if (isConfirmed) 'isMismatch': false,
      if (isConfirmed) 'mismatchNote': null,
    });
  }

  Future<void> deleteSale(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'isMismatch': isMismatch,
      'mismatchNote': isMismatch ? mismatchNote : null,
      if (isMismatch) 'isConfirmed': false,
    });
  }

  Future<void> markDebtAsPaid(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'debtAmount': 0,
      'isConfirmed': true,
      'isMismatch': false,
      'mismatchNote': null,
    });
  }

  /// 🆕 ຈ່າຍໜີ້ + ເພີ່ມຮູບ
  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'debtAmount': 0,
      'isConfirmed': true,
      'isMismatch': false,
      'mismatchNote': null,
      'paymentImageUrls': FieldValue.arrayUnion([imageUrl]),
      if (paymentType == 'cash')
        'cashPaidAmount': FieldValue.increment(paidAmount),
      if (paymentType == 'transfer')
        'transferPaidAmount': FieldValue.increment(paidAmount),
    });
  }

  /// 🖼️ ອັບເດດຮູບພາບທັງໝົດ (ບໍ່ປ່ຽນຂໍ້ມູນອື່ນ)
  Future<void> updateSaleImages(
    String id, {
    required List<String> paymentImageUrls,
    required List<String> billImageUrls,
    required List<String> topUpImageUrls,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'paymentImageUrls': paymentImageUrls,
      'billImageUrls': billImageUrls,
      'topUpImageUrls': topUpImageUrls,
    });
  }
}