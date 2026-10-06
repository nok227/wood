import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import '../../../domain/entities/sale_item_entity.dart';

class AddPaymentItemsPanel extends StatelessWidget {
  final List<SaleItemEntity> items;
  final NumberFormat fmt;
  final double net;
  final void Function(int) onEdit;
  final void Function(int) onRemove;

  const AddPaymentItemsPanel({
    super.key,
    required this.items, required this.fmt, required this.net,
    required this.onEdit, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.r14,
        border: Border.all(color: SaleStyle.green300, width: 1.5),
        boxShadow: [
          BoxShadow(color: SaleStyle.green700.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: SaleStyle.green50,
            borderRadius: SaleStyle.topR13),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: SaleStyle.green700, shape: BoxShape.circle),
              child: const Icon(Icons.list_alt, color: SaleStyle.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${SaleStyle.itemsPanelTitle} (${items.length})',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: SaleStyle.green800))),
            Text('${fmt.format(net)} ${SaleStyle.currency}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: SaleStyle.green800)),
          ]),
        ),
        ...List.generate(items.length, (i) => _itemRow(items[i], i)),
      ]),
    );
  }

  Widget _itemRow(SaleItemEntity it, int idx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SaleStyle.grey200))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(color: SaleStyle.green100, shape: BoxShape.circle),
          child: Center(child: Text('${idx + 1}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SaleStyle.green800))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(it.productName,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (it.hasSize)
            Text('${SaleStyle.itemDimPrefix} ${it.dimensionText}',
                style: const TextStyle(fontSize: 11, color: SaleStyle.grey600)),
          const SizedBox(height: 3),
          Row(children: [
            Text('${it.quantity} ${it.unit} × ${fmt.format(it.unitPrice)}',
                style: const TextStyle(fontSize: 11.5)),
            if (it.hasDiscount) ...[
              const SizedBox(width: 6),
              Text('${SaleStyle.itemDiscountPrefix} ${fmt.format(it.discountPerUnit)}',
                  style: const TextStyle(fontSize: 11, color: SaleStyle.red700)),
            ],
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${fmt.format(it.totalAmount)} ${SaleStyle.currency}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: SaleStyle.green800)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _iconBtn(Icons.edit, SaleStyle.blue700, () => onEdit(idx)),
            const SizedBox(width: 4),
            _iconBtn(Icons.delete, SaleStyle.errorRed, () => onRemove(idx)),
          ]),
        ]),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: SaleStyle.r6,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: SaleStyle.r6),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}