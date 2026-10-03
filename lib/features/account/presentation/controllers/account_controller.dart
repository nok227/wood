import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/features/notifications/domain/entities/app_notification.dart';
import 'package:wood/features/notifications/presentation/controllers/notification_controller.dart';
import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_repository.dart';

class AccountController extends GetxController {
  final AccountRepository repository;
  AccountController({required this.repository});

  var allTransactions = <AccountTransaction>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> _notify({
    required AppNotificationType type,
    required String title,
    required String message,
    String? targetId,
  }) async {
    if (!Get.isRegistered<NotificationController>()) return;
    try {
      await Get.find<NotificationController>().push(
        type: type,
        title: title,
        message: message,
        audience: NotificationAudience.admin,
        targetId: targetId,
      );
    } catch (_) {}
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final list = await repository.getTransactions();
      allTransactions.assignAll(list);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດດຶງຂໍ້ມູນໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(AccountTransaction tx) async {
    try {
      await repository.addTransaction(tx);
      await fetchTransactions();

      final names = tx.items.map((i) => i.name).join(', ');
      await _notify(
        type: AppNotificationType.accountAdd,
        title: tx.isIncome ? 'ຮັບເງິນເຂົ້າ' : 'ຈ່າຍເງິນອອກ',
        message: '$names · '
            '${NumberFormat('#,###').format(tx.totalAmount)} ກີບ '
            '(${tx.isCash ? "ສົດ" : "ໂອນ"})',
        targetId: tx.id,
      );

      Get.snackbar('ສຳເລັດ', 'ບັນທຶກຮຽບຮ້ອຍແລ້ວ',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final tx = allTransactions.firstWhereOrNull((t) => t.id == id);
      await repository.deleteTransaction(id);
      allTransactions.removeWhere((t) => t.id == id);

      final names = tx?.items.map((i) => i.name).join(', ') ?? 'ລາຍການ';
      await _notify(
        type: AppNotificationType.accountDelete,
        title: 'ລຶບລາຍການບັນຊີ',
        message: 'ລຶບ "$names" '
            '${NumberFormat('#,###').format(tx?.totalAmount ?? 0)} ກີບ',
        targetId: id,
      );

      Get.snackbar('ສຳເລັດ', 'ລຶບຮຽບຮ້ອຍແລ້ວ',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  // ══════════════════════════════════════════════
  // ຍອດລວມ
  // ══════════════════════════════════════════════
  double get totalIn => allTransactions
      .where((t) => t.isIncome)
      .fold<double>(0, (s, t) => s + t.totalAmount);

  double get totalOut => allTransactions
      .where((t) => t.isExpense)
      .fold<double>(0, (s, t) => s + t.totalAmount);

  double get balance => totalIn - totalOut;

  double get cashBalance => allTransactions
          .where((t) => t.isCash)
          .fold<double>(0,
              (s, t) => s + (t.isIncome ? t.totalAmount : -t.totalAmount));

  double get transferBalance => allTransactions
          .where((t) => t.isTransfer)
          .fold<double>(0,
              (s, t) => s + (t.isIncome ? t.totalAmount : -t.totalAmount));

  List<SessionGroup> get sessionGroups {
    if (allTransactions.isEmpty) return [];

    final Map<String, List<AccountTransaction>> groups = {};
    for (final t in allTransactions) {
      groups.putIfAbsent(t.sessionKey, () => []).add(t);
    }

    final sortedKeys = groups.keys.toList()..sort();

    double running = 0;
    final List<SessionGroup> result = [];
    for (final key in sortedKeys) {
      final list = groups[key]!;
      final first = list.first;
      final income = list
          .where((t) => t.isIncome)
          .fold<double>(0, (s, t) => s + t.totalAmount);
      final expense = list
          .where((t) => t.isExpense)
          .fold<double>(0, (s, t) => s + t.totalAmount);
      running += income - expense;

      list.sort((a, b) => b.date.compareTo(a.date));

      result.add(SessionGroup(
        key: key,
        date: DateTime(first.date.year, first.date.month, first.date.day),
        session: first.session,
        transactions: list,
        income: income,
        expense: expense,
        endingBalance: running,
      ));
    }

    return result.reversed.toList();
  }

  String formatDateHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(d.year, d.month, d.day);

    const days = [
      'ວັນຈັນ', 'ວັນອັງຄານ', 'ວັນພຸດ',
      'ວັນພະຫັດ', 'ວັນສຸກ', 'ວັນເສົາ', 'ວັນອາທິດ',
    ];
    final dayName = days[d.weekday - 1];
    final f =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    if (target == today) return 'ມື້ນີ້ ($dayName, $f)';
    if (target == yesterday) return 'ມື້ວານນີ້ ($dayName, $f)';
    return '$dayName, $f';
  }

  String formatTime(DateTime d) => DateFormat('HH:mm').format(d);
}

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