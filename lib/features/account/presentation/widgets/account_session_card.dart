import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/dashed_divider.dart';
import 'package:wood/features/account/presentation/models/session_group.dart';

import '../../domain/entities/account_transaction.dart';
import 'account_tx_tile.dart';

class AccountSessionCard extends StatelessWidget {
  final SessionGroup group;
  final bool isAdmin;
  final String Function(DateTime) formatTime;
  final void Function(AccountTransaction) onDelete;

  const AccountSessionCard({
    super.key,
    required this.group,
    required this.isAdmin,
    required this.formatTime,
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
          _Header(group: g, day: _day, dateShort: _dateShort),
          _dashed(),
          _Stats(group: g),
          _dashed(),
          for (final t in g.transactions)
            AccountTxTile(
              tx: t,
              timeText: formatTime(t.date),
              showTopDivider: t.id != g.transactions.first.id,
              isAdmin: isAdmin,
              onDelete: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _dashed() => const DashedDivider(
        dashWidth: 4,
        dashSpace: 4,
        height: 1,
        color: AccountStyle.sessionDivider,
        padding: AccountStyle.padDashedH,
      );
}

class _Header extends StatelessWidget {
  final SessionGroup group;
  final String Function(DateTime) day;
  final String Function(DateTime) dateShort;

  const _Header({
    required this.group,
    required this.day,
    required this.dateShort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  '${day(group.date)}, ${dateShort(group.date)}',
                  style: AccountStyle.dateHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AccountStyle.gap6,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AccountStyle.brown50,
                  borderRadius: AccountStyle.r20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(group.icon, style: const TextStyle(fontSize: 11)),
                    AccountStyle.gap3,
                    Text(group.label,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AccountStyle.brown800)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text('${group.transactions.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AccountStyle.grey500)),
            ],
          ),
          AccountStyle.gap4,
          Text('${AccountStyle.timePrefix}${group.range}',
              style: AccountStyle.txMeta
                  .copyWith(color: AccountStyle.grey500)),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final SessionGroup group;
  const _Stats({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AccountStyle.padStatsRow,
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              icon: Icons.arrow_downward_rounded,
              label: AccountStyle.labelIn,
              value: group.income,
              color: AccountStyle.success,
            ),
          ),
          Expanded(
            child: _Stat(
              icon: Icons.arrow_upward_rounded,
              label: AccountStyle.labelOut,
              value: group.expense,
              color: AccountStyle.error700,
            ),
          ),
          Expanded(
            child: _Stat(
              icon: Icons.savings_outlined,
              label: AccountStyle.labelBalance,
              value: group.endingBalance,
              color: AccountStyle.brown800,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final bool bold;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 11),
            AccountStyle.gap3,
            Text(label,
                style: AccountStyle.statLabelText.copyWith(color: color)),
          ],
        ),
        AccountStyle.gap2,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: value,
            duration: AccountStyle.animFast.inMilliseconds,
            style: (bold
                    ? AccountStyle.statValueBold
                    : AccountStyle.statValue)
                .copyWith(color: color),
          ),
        ),
      ],
    );
  }
}