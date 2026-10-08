import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/account_style.dart';

import '../../domain/entities/account_transaction.dart';

Future<void> showAccountDeleteDialog({
  required AccountTransaction transaction,
  required Future<void> Function() onConfirm,
}) async {
  if (Get.isDialogOpen ?? false) return;

  final fmt = NumberFormat('#,###');
  final names = transaction.items.map((i) => i.name).join(', ');

  await Get.defaultDialog(
    title: AccountStyle.confirmDelete,
    middleText: '${AccountStyle.deletePrefix}'
        '${names.isNotEmpty ? names : AccountStyle.fallbackItemName}'
        '${AccountStyle.deleteMid}'
        '${fmt.format(transaction.totalAmount)}'
        '${AccountStyle.deleteSuffix}',
    textConfirm: AccountStyle.delete,
    textCancel: AccountStyle.cancel,
    confirmTextColor: AccountStyle.white,
    buttonColor: AccountStyle.error800,
    onConfirm: () async {
      Get.back();
      await Future.delayed(AccountStyle.fast);
      await onConfirm();
    },
  );
}