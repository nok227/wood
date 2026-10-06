import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import '../../../domain/entities/sale_item_entity.dart';

class AddPaymentSummary extends StatelessWidget {
  final List<SaleItemEntity> items;
  final double discTot;
  final double net;
  final NumberFormat fmt;

  const AddPaymentSummary({
    super.key,
    required this.items, required this.discTot,
    required this.net, required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SaleStyle.padSection,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SaleStyle.green50, SaleStyle.green100],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: SaleStyle.r14,
        border: Border.all(color: SaleStyle.green300, width: 1.5),
        boxShadow: [
          BoxShadow(color: SaleStyle.green700.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(width: 26, height: 26,
            decoration: const BoxDecoration(color: SaleStyle.green700, shape: BoxShape.circle),
            child: const Center(child: Icon(Icons.receipt_long, color: SaleStyle.white, size: 15))),
          const SizedBox(width: 8),
          Text('${SaleStyle.sectionSummary} (${items.length} ${SaleStyle.summaryItemsUnit})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  color: SaleStyle.green700, letterSpacing: 0.2)),
        ]),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final it = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _sumRow(
              '${i + 1}. ${it.productName} (${it.quantity} ${it.unit})',
              '${fmt.format(it.grossAmount)} ${SaleStyle.currency}',
            ),
          );
        }),
        if (discTot > 0) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: SaleStyle.grey500)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(SaleStyle.discountTotal,
                style: TextStyle(fontSize: 12, color: SaleStyle.red700)),
            Text('-${fmt.format(discTot)} ${SaleStyle.currency}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SaleStyle.red700)),
          ]),
        ],
        const Padding(padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: SaleStyle.green700)),
        Row(children: [
          const Expanded(child: Text(SaleStyle.previewNetLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SaleStyle.green700))),
          FittedBox(fit: BoxFit.scaleDown,
            child: AnimatedNumber(
              value: net, suffix: ' ${SaleStyle.currency}', duration: 1200,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: SaleStyle.green700),
            )),
        ]),
      ]),
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) => Row(children: [
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, color: SaleStyle.textSecondary))),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
        color: color ?? SaleStyle.textPrimary)),
  ]);
}