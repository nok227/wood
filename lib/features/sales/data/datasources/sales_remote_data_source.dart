import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_order_entity.dart';
import '../models/sale_model.dart';
import '../models/sale_order_model.dart';

class SalesRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'sales';
  static const String _orderCollection = 'sale_orders';

  Future<List<SaleOrderEntity>> getSaleOrders() async {
    final results = await Future.wait([
      _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .get(),
      _firestore
          .collection(_orderCollection)
          .orderBy('date', descending: true)
          .get(),
    ]);

    final legacy = results[0].docs
        .map(
          (d) => SaleModel.fromMap(d.data(), d.id).toEntity().toOrderEntity(),
        )
        .toList();

    final orders = results[1].docs
        .map((d) => SaleOrderModel.fromMap(d.data(), d.id).toEntity())
        .toList();

    final all = [...legacy, ...orders];
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  Future<void> addSaleOrder(SaleOrderModel order) async {
    await _firestore
        .collection(_orderCollection)
        .doc(order.id)
        .set(order.toMap());
  }

  Future<bool> _tryUpdate(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_orderCollection).doc(id).update(data);
      return true;
    } catch (_) {}

    try {
      await _firestore.collection(_collection).doc(id).update(data);
      return true;
    } catch (_) {}

    return false;
  }

  Future<void> updateSaleStatus(String id, bool isConfirmed) async {
    await _tryUpdate(id, {
      'isConfirmed': isConfirmed,
      if (isConfirmed) 'isMismatch': false,
      if (isConfirmed) 'mismatchNote': null,
    });
  }

  Future<void> updateMismatchStatus(
    String id, {
    required bool isMismatch,
    String? mismatchNote,
  }) async {
    await _tryUpdate(id, {
      'isMismatch': isMismatch,
      'mismatchNote': isMismatch ? mismatchNote : null,
      if (isMismatch) 'isConfirmed': false,
    });
  }

  Future<void> markDebtAsPaid(String id) async {
    await _tryUpdate(id, {
      'debtAmount': 0,
      'isConfirmed': true,
      'isMismatch': false,
      'mismatchNote': null,
    });
  }

  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  }) async {
    await _tryUpdate(id, {
      'debtAmount': 0,
      'isConfirmed': true,
      'isMismatch': false,
      'mismatchNote': null,
      'debtPaymentImageUrls': FieldValue.arrayUnion([imageUrl]),
      if (paymentType == 'cash')
        'cashPaidAmount': FieldValue.increment(paidAmount),
      if (paymentType == 'transfer')
        'transferPaidAmount': FieldValue.increment(paidAmount),
    });
  }

  Future<void> updateSaleImages(
    String id, {
    required List<String> paymentImageUrls,
    required List<String> billImageUrls,
    required List<String> topUpImageUrls,
  }) async {
    await _tryUpdate(id, {
      'paymentImageUrls': paymentImageUrls,
      'billImageUrls': billImageUrls,
      'topUpImageUrls': topUpImageUrls,
    });
  }

  Future<void> deleteSale(String id) async {
    try {
      await _firestore.collection(_orderCollection).doc(id).delete();
    } catch (_) {}
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (_) {}
  }
}