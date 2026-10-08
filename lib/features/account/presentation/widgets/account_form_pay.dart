import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/number_formatter.dart';

import '../controllers/account_form_controller.dart';

class AccountFormPay extends StatelessWidget {
  final AccountFormController controller;
  const AccountFormPay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AccountStyle.itemsLabel,
            style: AccountStyle.sectionLabel),
        AccountStyle.gap6,
        Obx(() => Column(
              children: [
                for (var i = 0; i < controller.rows.length; i++)
                  _RowItem(
                    index: i,
                    row: controller.rows[i],
                    showDelete: controller.rows.length > 1,
                    onDelete: () => controller.removeRow(i),
                  ),
              ],
            )),
        AccountStyle.gapXs,
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AccountStyle.brown700,
            side: const BorderSide(color: AccountStyle.brown300),
            padding: AccountStyle.padAddItem,
            shape: const RoundedRectangleBorder(
                borderRadius: AccountStyle.inputRadius),
          ),
          onPressed: controller.addRow,
          icon: const Icon(Icons.add, size: 16),
          label: const Text(AccountStyle.addItemBtn,
              style: AccountStyle.addItemBtnText),
        ),
        AccountStyle.gap10,
        Obx(() => _TotalBox(text: controller.formattedPayTotal)),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  final int index;
  final AccountFormRow row;
  final bool showDelete;
  final VoidCallback onDelete;

  const _RowItem({
    required this.index,
    required this.row,
    required this.showDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: row.nameCtrl,
              decoration: _deco(
                label: '${AccountStyle.itemPrefix} ${index + 1}',
                focusColor: AccountStyle.red400,
                contentPad: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 12),
              ),
            ),
          ),
          AccountStyle.gap6,
          Expanded(
            flex: 4,
            child: TextField(
              controller: row.priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                NumberFormatter(),
              ],
              decoration: _deco(
                label: AccountStyle.priceLabel,
                suffix: AccountStyle.currency,
                focusColor: AccountStyle.red400,
                contentPad: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 12),
              ),
            ),
          ),
          if (showDelete)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.remove_circle_outline,
                  color: AccountStyle.red600, size: 22),
            ),
        ],
      ),
    );
  }

  InputDecoration _deco({
    required String label,
    String? suffix,
    Color focusColor = AccountStyle.brown400,
    EdgeInsets? contentPad,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AccountStyle.inputLabel,
      suffixText: suffix,
      isDense: true,
      border: const OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: AccountStyle.grey300),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: AccountStyle.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      contentPadding: contentPad,
    );
  }
}

class _TotalBox extends StatelessWidget {
  final String text;
  const _TotalBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AccountStyle.padTotalBox,
      decoration: BoxDecoration(
        color: AccountStyle.errorLight,
        borderRadius: AccountStyle.inputRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.summarize_outlined,
              color: AccountStyle.error700, size: 18),
          AccountStyle.gap6,
          const Expanded(
            child: Text(AccountStyle.totalLabel,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AccountStyle.error700)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AccountStyle.error700,
                    letterSpacing: 0.2)),
          ),
        ],
      ),
    );
  }
}