import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sale_order_entity.dart';
import '../widgets/sale_card.dart';

import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';

enum SummaryDetailType { list, change, discount, cashBills }

class SalesSummaryDetailPage extends StatelessWidget {
  final String title;
  final List<SaleOrderEntity> sales;
  final IconData icon;
  final Color accentColor;
  final SummaryDetailType detailType;

  const SalesSummaryDetailPage({
    super.key,
    required this.title,
    required this.sales,
    this.icon = Icons.list_alt,
    this.accentColor = Colors.brown,
    this.detailType = SummaryDetailType.list,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final total = sales.fold<double>(0, (s, e) => s + e.totalAmount);
    final totalItems = sales.fold<int>(0, (s, e) => s + e.itemCount);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: accentColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sales.length} ອໍເດີ · $totalItems ລາຍການ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ລວມ ${fmt.format(total)} ກີບ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: detailType == SummaryDetailType.cashBills
                ? _cashBillsView(fmt)
                : _listWithDateGroup(),
          ),
        ],
      ),
    );
  }

  Widget _listWithDateGroup() {
    List<SaleOrderEntity> filtered = sales;
    if (detailType == SummaryDetailType.change) {
      filtered = sales.where((e) => e.changeAmount > 0).toList();
    } else if (detailType == SummaryDetailType.discount) {
      filtered = sales.where((e) => e.hasDiscount).toList();
    }

    if (filtered.isEmpty) {
      return const Center(child: Text('ບໍ່ມີລາຍການ'));
    }

    final Map<String, List<SaleOrderEntity>> grouped = {};
    for (final s in filtered) {
      final key =
          '${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(s);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding:
          const EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 4),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final salesInGroup = grouped[dateKey]!;
        final date = _parseDateKey(dateKey);
        final headerTitle = _formatDateHeader(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.brown[100],
              elevation: 1,
              margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Colors.brown[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              headerTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.brown[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.brown[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${salesInGroup.length} ອໍເດີ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...salesInGroup.map(
              (s) => SaleCard(
                key: ValueKey('sale-${s.id}'),
                sale: s,
                isAdmin: Get.find<AuthController>().isAdmin,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cashBillsView(NumberFormat fmt) {
    final Map<int, int> totalBills = {};
    for (final s in sales) {
      s.cashDenominations?.forEach((d, n) {
        totalBills[d] = (totalBills[d] ?? 0) + n;
      });
    }

    if (totalBills.isEmpty) {
      return const Center(child: Text('ບໍ່ມີຂໍ້ມູນໃບເງິນສົດ'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('ໃບເງິນສົດທີ່ໄດ້ຮັບທັງໝົດ',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${fmt.format(_billsTotal(totalBills))} ກີບ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalBills.values.fold<int>(0, (s, e) => s + e)} ໃບ ທັງໝົດ',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _billsSummary(totalBills, fmt, showHeader: true),
        ],
      ),
    );
  }

  DateTime _parseDateKey(String key) {
    final p = key.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    const daysOfWeek = [
      'ວັນອາທິດ', 'ວັນຈັນ', 'ວັນອັງຄານ',
      'ວັນພຸດ', 'ວັນພະຫັດ', 'ວັນສຸກ', 'ວັນເສົາ',
    ];
    final dayName = daysOfWeek[date.weekday % 7];
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (targetDate == today) {
      return 'ມື້ນີ້ ($dayName, $formattedDate)';
    } else if (targetDate == yesterday) {
      return 'ມື້ວານນີ້ ($dayName, $formattedDate)';
    }
    return '$dayName, $formattedDate';
  }

  double _billsTotal(Map<int, int> bills) {
    double t = 0;
    bills.forEach((d, n) => t += d * n);
    return t;
  }

  Widget _billsSummary(
    Map<int, int> bills,
    NumberFormat fmt, {
    bool showHeader = false,
  }) {
    const standard = [100000, 50000, 20000, 10000, 5000, 2000, 1000, 500];
    final all = <int>{...standard, ...bills.keys}.toList()
      ..sort((a, b) => b.compareTo(a));

    final total = _billsTotal(bills);
    final totalBills = bills.values.fold<int>(0, (s, e) => s + e);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        children: [
          if (showHeader)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text('ໃບລະ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('ຈຳນວນໃບ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        )),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('ລວມ',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        )),
                  ),
                ],
              ),
            ),
          ...all.map((d) {
            final count = bills[d] ?? 0;
            final sub = d * count;
            final isEmpty = count == 0;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: Colors.grey.shade200)),
                color: isEmpty ? Colors.grey.shade50 : Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 14,
                            color: isEmpty
                                ? Colors.grey.shade400
                                : Colors.brown),
                        const SizedBox(width: 6),
                        Text(
                          fmt.format(d),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isEmpty
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isEmpty
                            ? Colors.grey.shade400
                            : Colors.brown.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${fmt.format(sub)} ກີບ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isEmpty
                            ? Colors.grey.shade400
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('ລວມທັງໝົດ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '$totalBills ໃບ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${fmt.format(total)} ກີບ',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}