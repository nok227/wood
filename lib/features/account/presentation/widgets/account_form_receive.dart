import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/number_formatter.dart';

import '../controllers/account_form_controller.dart';

class AccountFormReceive extends StatelessWidget {
  final AccountFormController controller;
  const AccountFormReceive({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AccountStyle.amountLabel,
            style: AccountStyle.sectionLabel),
        AccountStyle.gap6,
        TextField(
          controller: controller.recvCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            NumberFormatter(),
          ],
          style: AccountStyle.amountInput,
          decoration: InputDecoration(
            hintText: AccountStyle.zeroHint,
            hintStyle: const TextStyle(
              color: AccountStyle.grey400,
              fontWeight: FontWeight.w600,
            ),
            border: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide: BorderSide(color: AccountStyle.grey300),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide: BorderSide(color: AccountStyle.grey300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide: BorderSide(color: AccountStyle.green400, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.numbers, color: AccountStyle.green600),
            suffixText: AccountStyle.currency,
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AccountStyle.grey600,
            ),
          ),
        ),
      ],
    );
  }
}