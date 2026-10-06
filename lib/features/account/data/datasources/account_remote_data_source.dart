import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_transaction_model.dart';

/// ══════════════════════════════════════════════
/// 📡 ACCOUNT REMOTE DATA SOURCE
///
/// หน้าที่: คุยกับ Firestore เท่านั้น
/// คืน Model (DTO) → ไม่แปลงเป็น Entity
/// ══════════════════════════════════════════════
class AccountRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'account_transactions';

  // ── อ่านทั้งหมด (คืน Model) ──
  Future<List<AccountTransactionModel>> getTransactions() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .get();

    return snap.docs
        .map((d) => AccountTransactionModel.fromMap(d.data(), d.id))
        .toList();
  }

  // ── เพิ่ม ──
  Future<void> addTransaction(AccountTransactionModel tx) async {
    await _firestore.collection(_collection).doc(tx.id).set(tx.toMap());
  }

  // ── ลบ ──
  Future<void> deleteTransaction(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}