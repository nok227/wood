import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import '../../../domain/entities/sale_order_entity.dart';
import '../../widgets/sale_card.dart';

enum SummaryDetailType { list, change, discount, cashBills }

class SalesSummaryDetailPage extends StatefulWidget {
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
  State<SalesSummaryDetailPage> createState() =>
      _SalesSummaryDetailPageState();
}

class _SalesSummaryDetailPageState extends State<SalesSummaryDetailPage> {
  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v.abs() > 300) {
      HapticFeedback.lightImpact();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final total = widget.sales.fold<double>(0, (s, e) => s + e.totalAmount);
    final totalItems = widget.sales.fold<int>(0, (s, e) => s + e.itemCount);

    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0EA),
        appBar: AppBar(
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'ກັບ',
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.sales.length} ອໍເດີ · $totalItems ລາຍການ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fmt.format(total)} ກີບ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: widget.accentColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe,
                          color: Colors.grey.shade400, size: 16),
                      Text('ປັດກັບ',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: widget.detailType == SummaryDetailType.cashBills
                  ? _cashBillsView(fmt)
                  : _listWithDateGroup(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listWithDateGroup() {
    List<SaleOrderEntity> filtered = widget.sales;
    if (widget.detailType == SummaryDetailType.change) {
      filtered = widget.sales.where((e) => e.changeAmount > 0).toList();
    } else if (widget.detailType == SummaryDetailType.discount) {
      filtered = widget.sales.where((e) => e.hasDiscount).toList();
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
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final salesInGroup = grouped[dateKey]!;
        final date = _parseDateKey(dateKey);
        final headerTitle = _formatDateHeader(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: Colors.brown.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      headerTitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.brown.shade800,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${salesInGroup.length} ອໍເດີ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
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
    for (final s in widget.sales) {
      s.cashDenominations?.forEach((d, n) {
        totalBills[d] = (totalBills[d] ?? 0) + n;
      });
    }

    if (totalBills.isEmpty) {
      return const Center(child: Text('ບໍ່ມີຂໍ້ມູນໃບເງິນສົດ'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.brown.shade700,
                  Colors.brown.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long,
                    color: Colors.white70, size: 20),
                const SizedBox(height: 4),
                const Text(
                  'ໃບເງິນສົດທີ່ໄດ້ຮັບທັງໝົດ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${fmt.format(_billsTotal(totalBills))} ກີບ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalBills.values.fold<int>(0, (s, e) => s + e)} ໃບ ທັງໝົດ',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionLabel(Icons.list_alt, 'ແຍກຕາມໃບລະ'),
          const SizedBox(height: 8),
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

  Widget _sectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.brown.shade700),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: Colors.brown.shade700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          const dashSpace = 4.0;
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),
          );
        },
      ),
    );
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            if (showHeader) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ໃບລະ',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ຈຳນວນ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ລວມ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _dashedDivider(),
            ],
            ...all.map((d) {
              final count = bills[d] ?? 0;
              final sub = d * count;
              final isEmpty = count == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 13,
                            color: isEmpty
                                ? Colors.grey.shade400
                                : Colors.brown.shade600,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            fmt.format(d),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isEmpty
                              ? Colors.grey.shade400
                              : Colors.brown.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${fmt.format(sub)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
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
            _dashedDivider(),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ລວມທັງໝົດ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '$totalBills ໃບ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${fmt.format(total)} ກີບ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}