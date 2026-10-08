import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/account_style.dart';

import '../controllers/account_form_controller.dart';
import 'account_form_pay.dart';
import 'account_form_receive.dart';

class AccountFormSheet extends StatelessWidget {
  final String initialType;
  const AccountFormSheet({super.key, required this.initialType});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      AccountFormController(initialType: initialType),
      tag: 'account_form',
    );

    return Container(
      padding: AccountStyle.padFormSheet,
      constraints: BoxConstraints(
        maxHeight: Get.height * AccountStyle.formMaxHeightFactor,
      ),
      decoration: const BoxDecoration(
        color: AccountStyle.surface,
        borderRadius: AccountStyle.topR20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // handle
            Center(
              child: Container(
                width: AccountStyle.handleW,
                height: AccountStyle.handleH,
                decoration: BoxDecoration(
                  color: AccountStyle.grey300,
                  borderRadius: AccountStyle.r4,
                ),
              ),
            ),
            AccountStyle.gapMd,
            _Header(c: c),
            AccountStyle.gapSm,
            _TypeToggle(c: c),
            AccountStyle.gapLg,

            Flexible(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (c.isIn)
                          AccountFormReceive(controller: c)
                        else
                          AccountFormPay(controller: c),
                        AccountStyle.gapLg,
                        _PaymentTypeToggle(c: c),
                        AccountStyle.gapLg,
                        TextField(
                          controller: c.noteCtrl,
                          maxLines: 2,
                          decoration: _inputDeco(
                            label: AccountStyle.noteLabel,
                            prefix: Icons.sticky_note_2_outlined,
                          ),
                        ),
                        AccountStyle.gapLg,
                      ],
                    )),
              ),
            ),

            // save
            Obx(() => SizedBox(
                  height: AccountStyle.saveButtonHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.isIn
                          ? AccountStyle.success
                          : AccountStyle.error700,
                      foregroundColor: AccountStyle.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AccountStyle.r12),
                    ),
                    onPressed: c.submit,
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      c.isIn
                          ? AccountStyle.saveReceiveBtn
                          : AccountStyle.savePayBtn,
                      style: AccountStyle.formSaveBtnText,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  static InputDecoration _inputDeco({
    required String label,
    IconData? prefix,
    String? suffix,
    Color focusColor = AccountStyle.brown400,
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
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: AccountStyle.brown400, size: 20),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  final AccountFormController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isIn = c.isIn;
      return Row(
        children: [
          Container(
            width: AccountStyle.iconCircleSize,
            height: AccountStyle.iconCircleSize,
            decoration: BoxDecoration(
              color: isIn
                  ? AccountStyle.successLight
                  : AccountStyle.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIn
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color:
                  isIn ? AccountStyle.success : AccountStyle.error700,
              size: AccountStyle.iconMd,
            ),
          ),
          AccountStyle.gapSm,
          Expanded(
            child: Text(
              isIn ? AccountStyle.receiveBtn : AccountStyle.payBtn,
              style: AccountStyle.formTitle.copyWith(
                color: isIn
                    ? AccountStyle.green800
                    : AccountStyle.error800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: AccountStyle.grey600, size: 22),
            onPressed: () => Get.back(),
          ),
        ],
      );
    });
  }
}

// ── Type toggle ──
class _TypeToggle extends StatelessWidget {
  final AccountFormController c;
  const _TypeToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: AccountStyle.typeIn,
                icon: Icons.arrow_downward_rounded,
                color: AccountStyle.success,
                selected: c.isIn,
                onTap: () => c.setType('in'),
              ),
            ),
            AccountStyle.gapSm,
            Expanded(
              child: _ToggleButton(
                label: AccountStyle.typeOut,
                icon: Icons.arrow_upward_rounded,
                color: AccountStyle.error700,
                selected: !c.isIn,
                onTap: () => c.setType('out'),
              ),
            ),
          ],
        ));
  }
}

// ── Payment toggle ──
class _PaymentTypeToggle extends StatelessWidget {
  final AccountFormController c;
  const _PaymentTypeToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AccountStyle.paymentTypeLabel,
                style: AccountStyle.sectionLabel),
            AccountStyle.gap6,
            Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: AccountStyle.cashFull,
                    icon: Icons.payments_outlined,
                    color: AccountStyle.amber800,
                    selected: c.payType.value == 'cash',
                    onTap: () => c.setPayType('cash'),
                  ),
                ),
                AccountStyle.gapSm,
                Expanded(
                  child: _ToggleButton(
                    label: AccountStyle.transferFull,
                    icon: Icons.account_balance,
                    color: AccountStyle.blue700,
                    selected: c.payType.value == 'transfer',
                    onTap: () => c.setPayType('transfer'),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

// ── Reusable toggle ──
class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AccountStyle.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AccountStyle.inputRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : AccountStyle.white,
            borderRadius: AccountStyle.inputRadius,
            border: Border.all(
              color: selected ? color : AccountStyle.grey300,
              width: selected ? 0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? AccountStyle.white : color, size: 16),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? AccountStyle.white : color,
                      letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}