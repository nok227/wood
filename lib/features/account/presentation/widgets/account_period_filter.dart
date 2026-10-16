import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

import '../controllers/account_controller.dart';

// ══════════════════════════════════════════════
// 🎛️ Filter button → popup ສະຫຼຸບ
// ══════════════════════════════════════════════
class AccountPeriodFilter extends StatelessWidget {
  final AccountController controller;
  const AccountPeriodFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Obx(() {
        final period = controller.selectedPeriod.value;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPopup(context),
            borderRadius: AccountStyle.r12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AccountStyle.white,
                borderRadius: AccountStyle.r12,
                border: Border.all(color: AccountStyle.brown200),
                boxShadow: AccountStyle.cardMd,
              ),
              child: Row(
                children: [
                  // ── Icon ──
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AccountStyle.brown50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assessment_outlined,
                      size: 20,
                      color: AccountStyle.brown700,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── ຂໍ້ຄວາມ ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ສະຫຼຸບ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AccountStyle.brown800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AccountStyle.brown50,
                                borderRadius: AccountStyle.r20,
                                border: Border.all(
                                  color: AccountStyle.brown200,
                                ),
                              ),
                              child: Text(
                                period.label,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AccountStyle.brown800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ແຕະເພື່ອເບິ່ງລາຍລະອຽດ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AccountStyle.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── ຍອດສຸດທິ (preview) ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ຍອດສຸດທິ',
                        style: TextStyle(
                          fontSize: 10,
                          color: AccountStyle.grey500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedNumber(
                          value: controller.periodBalance,
                          suffix: ' ${AccountStyle.currency}',
                          duration:
                              AccountStyle.animFast.inMilliseconds,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: controller.periodBalance < 0
                                ? AccountStyle.error700
                                : AccountStyle.brown800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AccountStyle.grey400,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openPopup(BuildContext context) {
    Get.bottomSheet(
      _SummarySheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ══════════════════════════════════════════════
// 📋 Bottom sheet ສະຫຼຸບ
// ══════════════════════════════════════════════
class _SummarySheet extends StatelessWidget {
  final AccountController controller;
  const _SummarySheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');

    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AccountStyle.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AccountStyle.brown50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assessment_outlined,
                      size: 20,
                      color: AccountStyle.brown700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ສະຫຼຸບລາຍຮັບ-ລາຍຈ່າຍ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AccountStyle.brown100,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Chips ເລືອກໄລຍະ (ໂຕໜັງສືສະແດງສະເໝີ) ──
                    Obx(() {
                      final selected = controller.selectedPeriod.value;
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            AccountPeriod.values.map((p) {
                          final sel = selected == p;
                          return GestureDetector(
                            onTap: () => controller.setPeriod(p),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AccountStyle.brown700
                                    : AccountStyle.white,
                                borderRadius: AccountStyle.r20,
                                border: Border.all(
                                  color: sel
                                      ? AccountStyle.brown800
                                      : AccountStyle.brown200,
                                  width: sel ? 1.5 : 1,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: AccountStyle.brown700
                                              .withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: sel
                                      ? AccountStyle.white
                                      : AccountStyle.brown700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 16),

                    // ── ກາດສະຫຼຸບ ──
                    Obx(
                      () => _SummaryCard(
                        income: controller.periodIncome,
                        expense: controller.periodExpense,
                        balance: controller.periodBalance,
                        count: controller.periodTransactions.length,
                        periodLabel:
                            controller.selectedPeriod.value.label,
                        fmt: fmt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 💰 ກາດສະຫຼຸບ
// ══════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final int count;
  final String periodLabel;
  final NumberFormat fmt;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.count,
    required this.periodLabel,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AccountStyle.padCard,
      decoration: BoxDecoration(
        color: AccountStyle.white,
        borderRadius: AccountStyle.cardRadius,
        border: Border.all(color: AccountStyle.brown200),
        boxShadow: AccountStyle.cardMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 16,
                color: AccountStyle.brown700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ສະຫຼຸບ · $periodLabel',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AccountStyle.brown800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AccountStyle.brown50,
                  borderRadius: AccountStyle.r20,
                ),
                child: Text(
                  '$count ລາຍການ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AccountStyle.brown700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── ຮັບເຂົ້າ ──
          _row(
            icon: Icons.arrow_downward_rounded,
            label: 'ຮັບເຂົ້າ',
            value: income,
            color: AccountStyle.success,
          ),
          const SizedBox(height: 8),

          // ── ຈ່າຍອອກ ──
          _row(
            icon: Icons.arrow_upward_rounded,
            label: 'ຈ່າຍອອກ',
            value: expense,
            color: AccountStyle.error700,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AccountStyle.grey200),
          ),

          // ── ຍອດສຸດທິ ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AccountStyle.brown700.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings_outlined,
                  size: 14,
                  color: AccountStyle.brown700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ຍອດສຸດທິ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AccountStyle.brown800,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedNumber(
                  value: balance,
                  suffix: ' ${AccountStyle.currency}',
                  duration: AccountStyle.animNormal.inMilliseconds,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: balance < 0
                        ? AccountStyle.error700
                        : AccountStyle.brown800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: value,
            suffix: ' ${AccountStyle.currency}',
            duration: AccountStyle.animFast.inMilliseconds,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}