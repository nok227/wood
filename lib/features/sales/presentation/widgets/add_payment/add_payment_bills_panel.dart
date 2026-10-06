import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';

class AddPaymentBillsPanel extends StatelessWidget {
  final Map<int, int> bills;
  final bool isCash;
  final double paid;
  final double billsTot;
  final NumberFormat fmt;
  final void Function(int) onAdd;
  final void Function(int) onAddBy5;
  final void Function(int) onDelete;
  final void Function(int) onReset;
  final void Function(int, int) onSetCount;
  final VoidCallback onClear;

static const List<int> _r1 = [500, 1000, 2000, 5000];
static const List<int> _r2 = [10000, 20000, 50000, 100000];

  const AddPaymentBillsPanel({
    super.key,
    required this.bills, required this.isCash,
    required this.paid, required this.billsTot, required this.fmt,
    required this.onAdd, required this.onAddBy5, required this.onDelete,
    required this.onReset, required this.onSetCount, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCash) return const SizedBox.shrink();
    final totalBills = bills.values.fold<int>(0, (s, e) => s + e);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.brown50, borderRadius: SaleStyle.r10,
        border: Border.all(color: SaleStyle.brown200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.list_alt, color: SaleStyle.brown700, size: 18),
            const SizedBox(width: 6),
            const Expanded(child: Text(SaleStyle.billCountLabel,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SaleStyle.brown700))),
            if (bills.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: SaleStyle.red50, borderRadius: SaleStyle.r10,
                    border: Border.all(color: SaleStyle.red200),
                  ),
                  child: const Text(SaleStyle.clear,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SaleStyle.red700)),
                ),
              ),
          ]),
          const SizedBox(height: 4),
          const Text(SaleStyle.billCountHint,
              style: TextStyle(fontSize: 10, color: SaleStyle.brown600, fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          Row(children: [
            for (int i = 0; i < _r1.length; i++) ...[
              Expanded(child: _billCard(context, _r1[i])),
              if (i < _r1.length - 1) const SizedBox(width: 6),
            ],
          ]),
          const SizedBox(height: 6),
          Row(children: [
            for (int i = 0; i < _r2.length; i++) ...[
              Expanded(child: _billCard(context, _r2[i])),
              if (i < _r2.length - 1) const SizedBox(width: 6),
            ],
          ]),
          if (bills.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SaleStyle.brown100, borderRadius: SaleStyle.r8,
                  border: Border.all(color: SaleStyle.brown300)),
                child: Text('$totalBills ${SaleStyle.billCountSuffix}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SaleStyle.brown800)),
              ),
              const Spacer(),
              const Text('ນັບໄດ້: ',
                  style: TextStyle(fontSize: 12, color: SaleStyle.grey700)),
              Text('${fmt.format(billsTot)} ${SaleStyle.currency}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                      color: billsTot == paid && paid > 0 ? SaleStyle.green700 : SaleStyle.brown700)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _billCard(BuildContext context, int d) {
    final n = bills[d] ?? 0;
    final on = n > 0;
    final bg = on ? SaleStyle.brown700 : SaleStyle.white;
    final fg = on ? SaleStyle.white : SaleStyle.brown800;
    final subBg = on ? SaleStyle.brown800 : SaleStyle.grey100;
    final subFg = on ? SaleStyle.white : SaleStyle.grey700;

    return Container(
      height: SaleStyle.billCardHeight,
      decoration: BoxDecoration(
        color: bg, borderRadius: SaleStyle.r8,
        border: Border.all(
          color: on ? SaleStyle.brown800 : SaleStyle.grey300,
          width: on ? 2 : 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Expanded(child: Stack(children: [
          Positioned.fill(child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onAdd(d), onLongPress: () => onAddBy5(d),
            child: Center(child: FittedBox(fit: BoxFit.scaleDown,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(fmt.format(d),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: fg))),
            )),
          )),
if (on) Positioned(top: 1, right: 1,
  child: GestureDetector(
    onTap: () => onReset(d),
    child: Container(
      width: SaleStyle.billCloseSize,
      height: SaleStyle.billCloseSize,
      decoration: const BoxDecoration(color: SaleStyle.red600, shape: BoxShape.circle),
      child: const Icon(Icons.close, size: SaleStyle.billIconClose, color: SaleStyle.white)),
            )),
        ])),
        Container(
          height: SaleStyle.billCardSubHeight,
          color: subBg,
          child: Row(children: [
            Expanded(child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDelete(d),
              child: Icon(Icons.remove, size: SaleStyle.billSubIcon, color: subFg))),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showInputDialog(context, d),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: on ? SaleStyle.white : SaleStyle.grey200,
                  borderRadius: SaleStyle.r4),
                child: Text('×$n',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                        color: on ? SaleStyle.brown800 : SaleStyle.grey600)),
              ),
            ),
            Expanded(child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onAdd(d),
              child: Icon(Icons.add, size: SaleStyle.billSubIcon, color: subFg))),
          ]),
        ),
      ]),
    );
  }

  Future<void> _showInputDialog(BuildContext context, int d) async {
    final ctrl = TextEditingController(text: '${bills[d] ?? 0}');
    try {
      final result = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.payments, color: SaleStyle.brown700, size: 20),
            const SizedBox(width: 8),
            Text('${SaleStyle.billCountDialog} ${fmt.format(d)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          content: TextField(
            controller: ctrl, autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: SaleStyle.billCountInput,
              suffixText: SaleStyle.billCountSuffix,
              border: OutlineInputBorder(), hintText: '0'),
            onSubmitted: (v) { Navigator.pop(ctx, int.tryParse(v) ?? 0); },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(SaleStyle.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SaleStyle.brown700, foregroundColor: SaleStyle.white),
              onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text) ?? 0),
              child: const Text(SaleStyle.ok)),
          ],
        ),
      );
      if (result != null) onSetCount(d, result);
    } finally {
      ctrl.dispose();
    }
  }
}