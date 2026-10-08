import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/notifications/domain/entities/app_notification.dart';
import 'package:wood/features/notifications/presentation/controllers/notification_controller.dart';

import '../../domain/entities/account_transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../models/session_group.dart';

class AccountController extends GetxController {
  final AccountRepository repository;
  AccountController({required this.repository});

  final allTransactions = <AccountTransaction>[].obs;
  final isLoading = false.obs;

  // ══════════════════════════════════════════════
  // Derived state
  // ══════════════════════════════════════════════
  double get totalIn => allTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.totalAmount);

  double get totalOut => allTransactions
      .where((t) => t.isExpense)
      .fold(0.0, (s, t) => s + t.totalAmount);

  double get balance => totalIn - totalOut;

  double get cashBalance => allTransactions
      .where((t) => t.isCash)
      .fold(0.0, (s, t) => s + (t.isIncome ? t.totalAmount : -t.totalAmount));

  double get transferBalance => allTransactions
      .where((t) => t.isTransfer)
      .fold(0.0, (s, t) => s + (t.isIncome ? t.totalAmount : -t.totalAmount));

  List<SessionGroup> get sessionGroups => _buildGroups(allTransactions);

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  // ══════════════════════════════════════════════
  // Fetch
  // ══════════════════════════════════════════════
  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final list = await repository.getTransactions();
      allTransactions.assignAll(list);
    } catch (_) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດດຶງຂໍ້ມູນໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════
  // Add / Delete
  // ══════════════════════════════════════════════
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

      AppSnackbar.ok('ສຳເລັດ', 'ບັນທຶກຮຽບຮ້ອຍແລ້ວ');
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
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
        message:
            'ລຶບ "$names" ${NumberFormat('#,###').format(tx?.totalAmount ?? 0)} ກີບ',
        targetId: id,
      );

      AppSnackbar.ok('ສຳເລັດ', 'ລຶບຮຽບຮ້ອຍແລ້ວ');
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  // ══════════════════════════════════════════════
  // Format helpers
  // ══════════════════════════════════════════════
  String formatTime(DateTime d) => DateFormat('HH:mm').format(d);

  // ══════════════════════════════════════════════
  // Private
  // ══════════════════════════════════════════════
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

  List<SessionGroup> _buildGroups(List<AccountTransaction> src) {
    if (src.isEmpty) return [];

    final Map<String, List<AccountTransaction>> map = {};
    for (final t in src) {
      map.putIfAbsent(t.sessionKey, () => []).add(t);
    }

    final sortedKeys = map.keys.toList()..sort();

    double running = 0;
    final result = <SessionGroup>[];
    for (final key in sortedKeys) {
      final list = map[key]!;
      final first = list.first;
      final income =
          list.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.totalAmount);
      final expense =
          list.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.totalAmount);
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
}