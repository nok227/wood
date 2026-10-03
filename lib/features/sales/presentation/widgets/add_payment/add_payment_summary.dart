import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/widgets/animated_number.dart';
import '../../../domain/entities/sale_item_entity.dart';

class AddPaymentSummary extends StatelessWidget {
  final List<SaleItemEntity> items;
  final double discTot;
  final double net;
  final NumberFormat fmt;

  const AddPaymentSummary({
    super.key,
    required this.items,
    required this.discTot,
    required this.net,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ສະຫຼຸບຍອດຂາຍ (${items.length} ລາຍການ)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final it = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: _sumRow(
                '${i + 1}. ${it.productName} (${it.quantity} ${it.unit})',
                '${fmt.format(it.grossAmount)} ກີບ',
              ),
            );
          }),
          if (discTot > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Colors.red),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ສ່ວນລົດລວມ',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
                Text(
                  '-${fmt.format(discTot)} ກີບ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.green),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ຍອດຂາຍລວມ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedNumber(
                  value: net,
                  suffix: ' ກີບ',
                  duration: 1200,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      );
}