import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/account_transaction_model.dart';

/// ══════════════════════════════════════════════
/// 📦 ACCOUNT REPOSITORY IMPL
///
/// หน้าที่:
///   • Implement interface (domain)
///   • แปลง Model ↔ Entity
///   • try/catch (จัดการ error)
/// ══════════════════════════════════════════════
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  // ── ดึงทั้งหมด: Model → Entity ──
  @override
  Future<List<AccountTransaction>> getTransactions() async {
    final models = await remoteDataSource.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  // ── เพิ่ม: Entity → Model ──
  @override
  Future<void> addTransaction(AccountTransaction tx) async {
    final model = AccountTransactionModel(
      id: tx.id,
      type: tx.type,
      paymentType: tx.paymentType,
      items: tx.items,
      note: tx.note,
      date: tx.date,
    );
    await remoteDataSource.addTransaction(model);
  }

  // ── ลบ ──
  @override
  Future<void> deleteTransaction(String id) async {
    await remoteDataSource.deleteTransaction(id);
  }
}