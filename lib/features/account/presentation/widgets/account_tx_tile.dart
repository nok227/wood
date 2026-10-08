import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/dashed_divider.dart';

import '../../domain/entities/account_transaction.dart';

class AccountTxTile extends StatelessWidget {
  final AccountTransaction tx;
  final String timeText;
  final bool isAdmin;
  final bool showTopDivider;
  final void Function(AccountTransaction) onDelete;

  const AccountTxTile({
    super.key,
    required this.tx,
    required this.timeText,
    required this.isAdmin,
    required this.onDelete,
    this.showTopDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final isIn = tx.isIncome;
    final color = isIn ? AccountStyle.success : AccountStyle.error700;

    return Column(
      children: [
        if (showTopDivider)
          const DashedDivider(
            dashWidth: 4,
            dashSpace: 4,
            height: 1,
            color: AccountStyle.sessionDivider,
            padding: AccountStyle.padDashedH,
          ),
        Padding(
          padding: AccountStyle.padTxTile,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: AccountStyle.txIconCircleSize,
                height: AccountStyle.txIconCircleSize,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: AccountStyle.tintOpacity),
                    shape: BoxShape.circle),
                child: Icon(
                  isIn
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              AccountStyle.gap10,

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in tx.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: AccountStyle.txItemName.copyWith(
                                    fontWeight: isIn
                                        ? FontWeight.w800
                                        : FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isIn)
                              Text(fmt.format(item.price),
                                  style: AccountStyle.txItemPrice),
                          ],
                        ),
                      ),
                    AccountStyle.gap4,
                    Row(
                      children: [
                        Icon(
                          tx.isCash
                              ? Icons.payments_outlined
                              : Icons.account_balance,
                          size: 11,
                          color: tx.isCash
                              ? AccountStyle.amber800
                              : AccountStyle.transfer,
                        ),
                        AccountStyle.gap3,
                        Text(
                          tx.isCash
                              ? AccountStyle.cashLabel
                              : AccountStyle.transferLabel,
                          style: AccountStyle.txMeta.copyWith(
                              fontWeight: FontWeight.w800,
                              color: tx.isCash
                                  ? AccountStyle.amber800
                                  : AccountStyle.transfer,
                              letterSpacing: 0.2),
                        ),
                        AccountStyle.gap10,
                        const Icon(Icons.access_time,
                            size: 10, color: AccountStyle.grey500),
                        AccountStyle.gap3,
                        Text(timeText,
                            style: AccountStyle.txMeta
                                .copyWith(color: AccountStyle.grey500)),
                        if ((tx.note ?? '').trim().isNotEmpty) ...[
                          AccountStyle.gapSm,
                          Flexible(
                            child: Text(
                              '· ${tx.note}',
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

              // Amount + menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedNumber(
                    value: tx.totalAmount,
                    prefix: isIn ? '+' : '-',
                    duration: 1000,
                    style: AccountStyle.txAmount.copyWith(color: color),
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
                          if (v == 'delete') onDelete(tx);
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