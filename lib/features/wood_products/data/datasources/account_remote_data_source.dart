import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_transaction.dart';
import '../models/account_transaction_model.dart';

class AccountRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'account_transactions';

  Future<List<AccountTransaction>> getTransactions() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) =>
            AccountTransactionModel.fromMap(d.data(), d.id).toEntity())
        .toList();
  }

  Future<void> addTransaction(AccountTransactionModel tx) async {
    await _firestore.collection(_collection).doc(tx.id).set(tx.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}