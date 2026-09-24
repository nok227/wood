import '../entities/account_transaction.dart';

abstract class AccountRepository {
  Future<List<AccountTransaction>> getTransactions();
  Future<void> addTransaction(AccountTransaction tx);
  Future<void> deleteTransaction(String id);
}