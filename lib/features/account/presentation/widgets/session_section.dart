import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/widgets/animated_number.dart';
import 'package:wood/core/widgets/dashed_divider.dart';
import '../../domain/entities/account_transaction.dart';
import '../controllers/account_controller.dart';

class SessionSection extends StatelessWidget {
  final SessionGroup group;
  final bool isAdmin;
  final AccountController controller;
  final void Function(AccountTransaction) onDelete;

  const SessionSection({
    super.key,
    required this.group,
    required this.isAdmin,
    required this.controller,
    required this.onDelete,
  });

  String _day(DateTime d) {
    const days = ['ວັນຈັນ', 'ວັນອັງຄານ', 'ວັນພຸດ', 'ວັນພະຫັດ',
      'ວັນສຸກ', 'ວັນເສົາ', 'ວັນອາທິດ'];
    return days[d.weekday - 1];
  }

  String _dateShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: [
                Row(children: [
                  Icon(Icons.calendar_today, size: 13, color: Colors.brown.shade700),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${_day(g.date)}, ${_dateShort(g.date)}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900,
                      color: Colors.brown.shade800, letterSpacing: 0.2),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(g.icon, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(g.label, style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w900, color: Colors.brown.shade800)),
                    ]),
                  ),
                  const SizedBox(width: 4),
                  Text('${g.transactions.length}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                      color: Colors.grey.shade500)),
                ]),
                const SizedBox(height: 4),
                Text('ເວລາ ${g.range}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const DashedDivider(dashWidth: 4, dashSpace: 4, height: 1,
            color: Color(0xFFEEEEEE),
            padding: EdgeInsets.symmetric(horizontal: 14)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(children: [
              Expanded(child: _stat(Icons.arrow_downward_rounded, 'ຮັບ',
                g.income, Colors.green.shade700)),
              Expanded(child: _stat(Icons.arrow_upward_rounded, 'ຈ່າຍ',
                g.expense, Colors.red.shade700)),
              Expanded(child: _stat(Icons.savings_outlined, 'ຄົງເຫຼືອ',
                g.endingBalance, Colors.brown.shade800, bold: true)),
            ]),
          ),
          const DashedDivider(dashWidth: 4, dashSpace: 4, height: 1,
            color: Color(0xFFEEEEEE),
            padding: EdgeInsets.symmetric(horizontal: 14)),
          ...g.transactions.map((t) => _txTile(t)),
        ],
      ),
    );
  }

  Widget _stat(IconData i, String l, double v, Color c, {bool bold = false}) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, color: c, size: 11),
        const SizedBox(width: 3),
        Text(l, style: TextStyle(color: c, fontSize: 10,
          fontWeight: FontWeight.w800, letterSpacing: 0.2)),
      ]),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedNumber(
          value: v, duration: 1100,
          style: TextStyle(fontSize: bold ? 13 : 12,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            color: c, letterSpacing: 0.2),
        ),
      ),
    ]);
  }

  Widget _txTile(AccountTransaction t) {
    final fmt = NumberFormat('#,###');
    final isIn = t.isIncome;
    final c = isIn ? Colors.green.shade700 : Colors.red.shade700;

    return Column(children: [
      if (t.id != group.transactions.first.id)
        const DashedDivider(dashWidth: 4, dashSpace: 4, height: 1,
          color: Color(0xFFEEEEEE),
          padding: EdgeInsets.symmetric(horizontal: 14)),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(isIn ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded, color: c, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...t.items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    Expanded(child: Text(i.name,
                      style: TextStyle(fontSize: 12.5,
                        fontWeight: isIn ? FontWeight.w800 : FontWeight.w600,
                        color: Colors.black87),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (!isIn)
                      Text(fmt.format(i.price),
                        style: TextStyle(fontSize: 11.5,
                          color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ]),
                )),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(t.isCash ? Icons.payments_outlined : Icons.account_balance,
                    size: 11,
                    color: t.isCash ? Colors.amber.shade800 : Colors.blue.shade700),
                  const SizedBox(width: 3),
                  Text(t.isCash ? 'ສົດ' : 'ໂອນ',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800,
                      color: t.isCash ? Colors.amber.shade800 : Colors.blue.shade700,
                      letterSpacing: 0.2)),
                  const SizedBox(width: 10),
                  Icon(Icons.access_time, size: 10, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(controller.formatTime(t.date),
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600)),
                  if ((t.note ?? '').trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(child: Text('· ${t.note}',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ]),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedNumber(
                  value: t.totalAmount,
                  prefix: isIn ? '+' : '-',
                  duration: 1000,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: c, letterSpacing: 0.2),
                ),
                if (isAdmin)
                  SizedBox(
                    height: 22, width: 22,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 16),
                      onSelected: (v) { if (v == 'delete') onDelete(t); },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, color: Color(0xFFB71C1C), size: 18),
                            SizedBox(width: 8),
                            Text('ລຶບ', style: TextStyle(color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}