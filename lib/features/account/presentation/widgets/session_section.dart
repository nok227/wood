import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/dashed_divider.dart';

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

  String _day(DateTime d) => AccountStyle.dayNames[d.weekday - 1];

  String _dateShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AccountStyle.white,
        borderRadius: AccountStyle.cardRadius,
        boxShadow: AccountStyle.cardMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(g),
          _dashed(),
          _statsRow(g),
          _dashed(),
          ...g.transactions.map(_txTile),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _header(SessionGroup g) => Padding(
        padding: AccountStyle.padSessionHeader,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 13, color: AccountStyle.primary),
                AccountStyle.gap6,
                Expanded(
                  child: Text(
                    '${_day(g.date)}, ${_dateShort(g.date)}',
                    style: AccountStyle.dateHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AccountStyle.gap6,
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AccountStyle.brown50,
                    borderRadius: AccountStyle.r20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(g.icon,
                          style: const TextStyle(fontSize: 11)),
                      AccountStyle.gap3,
                      Text(g.label,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AccountStyle.brown800)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text('${g.transactions.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AccountStyle.grey500)),
              ],
            ),
            AccountStyle.gap4,
            Text('${AccountStyle.timePrefix}${g.range}',
                style: AccountStyle.txMeta.copyWith(
                    color: AccountStyle.grey500)),
          ],
        ),
      );

  // ── Dashed divider ──
  Widget _dashed() => const DashedDivider(
        dashWidth: 4,
        dashSpace: 4,
        height: 1,
        color: AccountStyle.sessionDivider,
        padding: AccountStyle.padDashedH,
      );

  // ── Stats ──
  Widget _statsRow(SessionGroup g) => Padding(
        padding: AccountStyle.padStatsRow,
        child: Row(
          children: [
            Expanded(
                child: _stat(Icons.arrow_downward_rounded,
                    AccountStyle.labelIn,
                    g.income, AccountStyle.success)),
            Expanded(
                child: _stat(Icons.arrow_upward_rounded,
                    AccountStyle.labelOut,
                    g.expense, AccountStyle.error700)),
            Expanded(
                child: _stat(Icons.savings_outlined,
                    AccountStyle.labelBalance,
                    g.endingBalance, AccountStyle.brown800,
                    bold: true)),
          ],
        ),
      );

  Widget _stat(IconData i, String l, double v, Color c,
      {bool bold = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: c, size: 11),
            AccountStyle.gap3,
            Text(l, style: AccountStyle.statLabelText.copyWith(color: c)),
          ],
        ),
        AccountStyle.gap2,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: v,
            duration: AccountStyle.animFast.inMilliseconds,
            style: (bold
                    ? AccountStyle.statValueBold
                    : AccountStyle.statValue)
                .copyWith(color: c),
          ),
        ),
      ],
    );
  }

  // ── Transaction tile ──
  Widget _txTile(AccountTransaction t) {
    final fmt = NumberFormat('#,###');
    final isIn = t.isIncome;
    final c = isIn ? AccountStyle.success : AccountStyle.error700;

    return Column(
      children: [
        if (t.id != group.transactions.first.id) _dashed(),
        Padding(
          padding: AccountStyle.padTxTile,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──
              Container(
                width: AccountStyle.txIconCircleSize,
                height: AccountStyle.txIconCircleSize,
                decoration: BoxDecoration(
                    color: c.withOpacity(AccountStyle.tintOpacity),
                    shape: BoxShape.circle),
                child: Icon(
                  isIn
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: c,
                  size: 16,
                ),
              ),
              AccountStyle.gap10,

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...t.items.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  i.name,
                                  style: AccountStyle.txItemName.copyWith(
                                      fontWeight: isIn
                                          ? FontWeight.w800
                                          : FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isIn)
                                Text(fmt.format(i.price),
                                    style: AccountStyle.txItemPrice),
                            ],
                          ),
                        )),
                    AccountStyle.gap4,
                    Row(
                      children: [
                        Icon(
                          t.isCash
                              ? Icons.payments_outlined
                              : Icons.account_balance,
                          size: 11,
                          color: t.isCash
                              ? AccountStyle.amber800
                              : AccountStyle.transfer,
                        ),
                        AccountStyle.gap3,
                        Text(
                          t.isCash
                              ? AccountStyle.cashLabel
                              : AccountStyle.transferLabel,
                          style: AccountStyle.txMeta.copyWith(
                              fontWeight: FontWeight.w800,
                              color: t.isCash
                                  ? AccountStyle.amber800
                                  : AccountStyle.transfer,
                              letterSpacing: 0.2),
                        ),
                        AccountStyle.gap10,
                        const Icon(Icons.access_time,
                            size: 10, color: AccountStyle.grey500),
                        AccountStyle.gap3,
                        Text(
                          controller.formatTime(t.date),
                          style: AccountStyle.txMeta.copyWith(
                              color: AccountStyle.grey500),
                        ),
                        if ((t.note ?? '').trim().isNotEmpty) ...[
                          AccountStyle.gapSm,
                          Flexible(
                            child: Text(
                              '· ${t.note}',
                              style: AccountStyle.txNote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Amount + menu ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedNumber(
                    value: t.totalAmount,
                    prefix: isIn ? '+' : '-',
                    duration: 1000,
                    style: AccountStyle.txAmount.copyWith(color: c),
                  ),
                  if (isAdmin)
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: const Icon(Icons.more_vert,
                            color: AccountStyle.grey400, size: 16),
                        onSelected: (v) {
                          if (v == 'delete') onDelete(t);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline,
                                    color: AccountStyle.error, size: 18),
                                AccountStyle.gapSm,
                                Text(AccountStyle.delete,
                                    style: const TextStyle(
                                        color: AccountStyle.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}