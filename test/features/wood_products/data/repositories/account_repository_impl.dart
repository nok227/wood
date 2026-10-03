import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/account_transaction_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AccountTransaction>> getTransactions() async {
    return await remoteDataSource.getTransactions();
  }

  @override
  Future<void> addTransaction(AccountTransaction tx) async {
    final model = AccountTransactionModel(
      id: tx.id,
      type: tx.type,
      paymentType: tx.paymentType,
      items: tx.items, // ✅ ປ່ຽນຈາກ amount + itemName
      note: tx.note,
      date: tx.date,
    );
    await remoteDataSource.addTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await remoteDataSource.deleteTransaction(id);
  }
}