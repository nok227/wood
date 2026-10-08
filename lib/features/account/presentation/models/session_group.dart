import '../../domain/entities/account_transaction.dart';

class SessionGroup {
  final String key;
  final DateTime date;
  final String session;
  final List<AccountTransaction> transactions;
  final double income;
  final double expense;
  final double endingBalance;

  SessionGroup({
    required this.key,
    required this.date,
    required this.session,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.endingBalance,
  });

  double get net => income - expense;

  String get label {
    switch (session) {
      case 'morning':
        return 'ເຊົ້າ';
      case 'afternoon':
        return 'ບ່າຍ';
      default:
        return 'ແລງ';
    }
  }

  String get icon {
    switch (session) {
      case 'morning':
        return '🌅';
      case 'afternoon':
        return '☀️';
      default:
        return '🌙';
    }
  }

  String get range {
    switch (session) {
      case 'morning':
        return '06:00 - 11:59';
      case 'afternoon':
        return '12:00 - 16:59';
      default:
        return '17:00 - 05:59';
    }
  }
}