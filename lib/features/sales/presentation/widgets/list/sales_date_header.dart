import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

class SalesDateHeader extends StatelessWidget {
  final DateTime date;
  final int count;
  final String Function(DateTime) formatHeader;

  const SalesDateHeader({
    super.key,
    required this.date,
    required this.count,
    required this.formatHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SaleStyle.padDateHeader,
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: SaleStyle.iconCalendar,
            color: SaleStyle.brown700,
          ),
          SaleStyle.gap6,
          Expanded(
            child: Text(
              formatHeader(date),
              style: SaleStyle.dateHeader,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count ${SaleStyle.summaryOrderUnit}',
            style: SaleStyle.dateHeaderGrey,
          ),
        ],
      ),
    );
  }
}