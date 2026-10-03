import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  static const _r1 = [500, 1000, 2000, 5000];
  static const _r2 = [10000, 20000, 50000, 100000];

  const AddPaymentBillsPanel({
    super.key,
    required this.bills,
    required this.isCash,
    required this.paid,
    required this.billsTot,
    required this.fmt,
    required this.onAdd,
    required this.onAddBy5,
    required this.onDelete,
    required this.onReset,
    required this.onSetCount,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCash) return const SizedBox.shrink();

    final totalBills = bills.values.fold<int>(0, (s, e) => s + e);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Row(
            children: [
              const Icon(Icons.list_alt, color: Colors.brown, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'ນັບແຍກໃບເງິນ (ບັງຄັບ)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              if (bills.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'ລ້າງ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // ── คำแนะนำ ──
          Text(
            'ແຕະ +1 · ກົດຄ້າງ +5 · ແຕະ × ພິມຈຳນວນ',
            style: TextStyle(
              fontSize: 10,
              color: Colors.brown.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          // ── ແຖວ 1 ──
          Row(
            children: [
              for (int i = 0; i < _r1.length; i++) ...[
                Expanded(child: _billCard(context, _r1[i])),
                if (i < _r1.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // ── ແຖວ 2 ──
          Row(
            children: [
              for (int i = 0; i < _r2.length; i++) ...[
                Expanded(child: _billCard(context, _r2[i])),
                if (i < _r2.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
          // ── Summary ──
          if (bills.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown.shade300),
                  ),
                  child: Text(
                    '$totalBills ໃບ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ນັບໄດ້: ',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  '${fmt.format(billsTot)} ກີບ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: billsTot == paid && paid > 0
                        ? Colors.green.shade700
                        : Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🎴 Bill Card — 76px
  // ┌──────────────┐
  // │ 20,000  [x]  │  ← แตะ = +1, long press = +5
  // │ [-] ×3 [+]   │  ← ปุ่ม -, + และแตะที่ ×N เพื่อพิมพ์
  // └──────────────┘
  // ══════════════════════════════════════════════
  Widget _billCard(BuildContext context, int d) {
    final n = bills[d] ?? 0;
    final on = n > 0;
    final bg = on ? Colors.brown.shade700 : Colors.white;
    final fg = on ? Colors.white : Colors.brown.shade800;
    final subBg = on ? Colors.brown.shade800 : Colors.grey.shade100;
    final subFg = on ? Colors.white : Colors.grey.shade700;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: on ? Colors.brown.shade800 : Colors.grey.shade300,
          width: on ? 2 : 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Row 1: ตัวเงิน + ปุ่ม x ──
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onAdd(d),
                    onLongPress: () => onAddBy5(d),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            fmt.format(d),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: fg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (on)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onReset(d),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 11, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Row 2: [-] ×N [+] ──
          Container(
            height: 26,
            color: subBg,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDelete(d),
                    child: Icon(Icons.remove,
                        size: 14, color: subFg),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showInputDialog(context, d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: on ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '×$n',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: on
                            ? Colors.brown.shade800
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onAdd(d),
                    child: Icon(Icons.add, size: 14, color: subFg),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 📝 Dialog พิมพ์จำนวน
  // ══════════════════════════════════════════════
  Future<void> _showInputDialog(BuildContext context, int d) async {
    final ctrl = TextEditingController(text: '${bills[d] ?? 0}');
    try {
      final result = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payments,
                  color: Colors.brown.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'ນັບໃບ ${fmt.format(d)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              labelText: 'ຈຳນວນໃບ',
              suffixText: 'ໃບ',
              border: OutlineInputBorder(),
              hintText: '0',
            ),
            onSubmitted: (v) {
              final n = int.tryParse(v) ?? 0;
              Navigator.pop(ctx, n);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ຍົກເລີກ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final n = int.tryParse(ctrl.text) ?? 0;
                Navigator.pop(ctx, n);
              },
              child: const Text('ຕົກລົງ'),
            ),
          ],
        ),
      );
      if (result != null) onSetCount(d, result);
    } finally {
      ctrl.dispose();
    }
  }
}