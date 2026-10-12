import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/dashed_divider.dart';

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
            // ── Drag handle ──
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Header(c: c),
            ),
            const SizedBox(height: 16),

            // ── Body scrollable ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toggle รับเข้า / จ่ายออก
                        _TypeToggle(c: c),
                        const SizedBox(height: 20),

                        // จำนวนเงิน
                        if (c.isIn)
                          AccountFormReceive(controller: c)
                        else
                          AccountFormPay(controller: c),
                        const SizedBox(height: 20),

                        // เส้นประคั่น
                        DashedDivider(
                          color: Colors.grey.shade300,
                          height: 1,
                          dashWidth: 4,
                          dashSpace: 4,
                        ),
                        const SizedBox(height: 20),

                        // ประเภทเงิน
                        _PaymentTypeToggle(c: c),
                        const SizedBox(height: 20),

                        // เส้นประคั่น
                        DashedDivider(
                          color: Colors.grey.shade300,
                          height: 1,
                          dashWidth: 4,
                          dashSpace: 4,
                        ),
                        const SizedBox(height: 20),

                        // หมายเหตุ
                        TextField(
                          controller: c.noteCtrl,
                          maxLines: 2,
                          decoration: _softInput(
                            hint: AccountStyle.noteLabel,
                            prefix: Icons.sticky_note_2_outlined,
                            prefixColor: Colors.purple.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    )),
              ),
            ),

            // ── Save button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Obx(() => SizedBox(
                    height: AccountStyle.saveButtonHeight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.isIn
                            ? AccountStyle.success
                            : AccountStyle.error700,
                        foregroundColor: AccountStyle.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
            ),
          ],
        ),
      ),
    );
  }

  // ── Input แบบ filled ไม่มีกรอบ ──
  static InputDecoration _softInput({
    required String hint,
    IconData? prefix,
    Color? prefixColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: prefixColor, size: 20),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIn
                  ? AccountStyle.success.withOpacity(0.12)
                  : AccountStyle.error700.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIn
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIn ? AccountStyle.success : AccountStyle.error700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isIn ? AccountStyle.receiveBtn : AccountStyle.payBtn,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIn
                    ? AccountStyle.green800
                    : AccountStyle.error800,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600, size: 22),
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
              child: _SoftToggle(
                label: AccountStyle.typeIn,
                icon: Icons.arrow_downward_rounded,
                color: AccountStyle.success,
                selected: c.isIn,
                onTap: () => c.setType('in'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SoftToggle(
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
            Text(
              AccountStyle.paymentTypeLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SoftToggle(
                    label: AccountStyle.cashFull,
                    icon: Icons.payments_outlined,
                    color: AccountStyle.amber800,
                    selected: c.payType.value == 'cash',
                    onTap: () => c.setPayType('cash'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftToggle(
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

// ── Soft toggle (สีจางเมื่อเลือก ไม่ทึบ) ──
class _SoftToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SoftToggle({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.12)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color.withOpacity(0.4) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? color : Colors.grey.shade500,
                  size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}