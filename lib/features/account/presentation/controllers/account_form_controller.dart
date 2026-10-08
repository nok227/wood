import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';

import '../../domain/entities/account_transaction.dart';
import 'account_controller.dart';

class AccountFormController extends GetxController {
  AccountFormController({required this.initialType});

  final String initialType;

  final _fmt = NumberFormat('#,###');
  final recvCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final rows = <AccountFormRow>[].obs;
  final type = 'in'.obs;
  final payType = 'cash'.obs;

  bool get isIn => type.value == 'in';

  double get payTotal =>
      rows.fold(0.0, (sum, r) => sum + r.price.value);

  @override
  void onInit() {
    super.onInit();
    type.value = initialType;
    rows.add(AccountFormRow());
  }

  @override
  void onClose() {
    recvCtrl.dispose();
    noteCtrl.dispose();
    for (final r in rows) {
      r.dispose();
    }
    super.onClose();
  }

  // ── Mutations ──
  void setType(String t) => type.value = t;
  void setPayType(String p) => payType.value = p;
  void addRow() => rows.add(AccountFormRow());

  void removeRow(int i) {
    if (rows.length <= 1) return;
    rows[i].dispose();
    rows.removeAt(i);
  }

  // ── Submit ──
  Future<void> submit() async {
    final items = <AccountItem>[];

    if (isIn) {
      final amount =
          double.tryParse(recvCtrl.text.replaceAll(',', '')) ?? 0;
      if (amount <= 0) {
        AppSnackbar.err(AccountStyle.alertTitle, AccountStyle.alertAmount);
        return;
      }
      items.add(AccountItem(
        name: payType.value == 'cash'
            ? AccountStyle.receiveCash
            : AccountStyle.receiveTransfer,
        price: amount,
      ));
    } else {
      for (final r in rows) {
        final n = r.nameCtrl.text.trim();
        final p = r.price.value;
        if (n.isEmpty || p <= 0) continue;
        items.add(AccountItem(name: n, price: p));
      }
      if (items.isEmpty) {
        AppSnackbar.err(AccountStyle.alertTitle, AccountStyle.alertMinItem);
        return;
      }
    }

    final tx = AccountTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type.value,
      paymentType: payType.value,
      items: items,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      date: DateTime.now(),
    );

    Get.back();
    await Get.find<AccountController>().addTransaction(tx);
  }

  // ── Input formatter ──
  static List<TextInputFormatter> get numberFormatters => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  String get formattedPayTotal =>
      '${_fmt.format(payTotal)} ${AccountStyle.currency}';
}

// ── Row ──
class AccountFormRow {
  AccountFormRow() {
    priceCtrl.addListener(_onPrice);
  }

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final price = 0.0.obs;

  void _onPrice() {
    price.value =
        double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? 0;
  }

  void dispose() {
    priceCtrl.removeListener(_onPrice);
    nameCtrl.dispose();
    priceCtrl.dispose();
    price.close();
  }
}