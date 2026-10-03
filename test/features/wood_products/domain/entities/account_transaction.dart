class AccountItem {
  final String name;
  final double price;
  const AccountItem({required this.name, required this.price});
}

class AccountTransaction {
  final String id;
  final String type;      
  final String paymentType;
  final List<AccountItem> items;
  final String? note;
  final DateTime date;

  AccountTransaction({
    required this.id,
    required this.type,
    required this.paymentType,
    required this.items,
    this.note,
    required this.date,
  });

  double get totalAmount =>
      items.fold<double>(0, (s, i) => s + i.price);

  bool get isIncome => type == 'in';
  bool get isExpense => type == 'out';
  bool get isCash => paymentType == 'cash';
  bool get isTransfer => paymentType == 'transfer';

  /// 'morning' | 'afternoon' | 'evening'
  String get session {
    final h = date.hour;
    if (h >= 6 && h < 12) return 'morning';
    if (h >= 12 && h < 17) return 'afternoon';
    return 'evening';
  }

  String get sessionLabel {
    switch (session) {
      case 'morning':
        return 'ເຊົ້າ';
      case 'afternoon':
        return 'ບ່າຍ';
      default:
        return 'ແລງ';
    }
  }

  String get sessionIcon {
    switch (session) {
      case 'morning':
        return '🌅';
      case 'afternoon':
        return '☀️';
      default:
        return '🌙';
    }
  }

  String get sessionRange {
    switch (session) {
      case 'morning':
        return '06:00 - 11:59';
      case 'afternoon':
        return '12:00 - 16:59';
      default:
        return '17:00 - 05:59';
    }
  }

  String get sessionKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_$session';
}