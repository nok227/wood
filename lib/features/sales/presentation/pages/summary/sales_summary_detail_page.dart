import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
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
    this.accentColor = SaleStyle.brown700,
    this.detailType = SummaryDetailType.list,
  });

  @override
  State<SalesSummaryDetailPage> createState() => _SalesSummaryDetailPageState();
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
        backgroundColor: SaleStyle.bg,
        appBar: AppBar(
          backgroundColor: SaleStyle.brown700,
          foregroundColor: SaleStyle.white,
          elevation: 0,
          title: Text(widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: SaleStyle.summaryReturnBtn,
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            color: SaleStyle.white,
            child: Row(children: [
              Container(
                width: SaleStyle.avatarMd,
                height: SaleStyle.avatarMd,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.sales.length} ${SaleStyle.summaryOrderUnit} · $totalItems ${SaleStyle.summaryItemsUnit}',
                    style: const TextStyle(fontSize: 12, color: SaleStyle.grey600, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text('${fmt.format(total)} ${SaleStyle.currency}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                          color: widget.accentColor, letterSpacing: 0.2)),
                ],
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.swipe, color: SaleStyle.grey400, size: 16),
                Text(SaleStyle.summarySwipeHint,
                    style: const TextStyle(fontSize: 9, color: SaleStyle.grey500)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.detailType == SummaryDetailType.cashBills
                ? _cashBillsView(fmt)
                : _listWithDateGroup(),
          ),
        ]),
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

    if (filtered.isEmpty) return const Center(child: Text(SaleStyle.noItems));

    final Map<String, List<SaleOrderEntity>> grouped = {};
    for (final s in filtered) {
      final key = '${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(s);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: SaleStyle.padSummary,
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
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 13, color: SaleStyle.brown700),
                const SizedBox(width: 6),
                Expanded(child: Text(headerTitle,
                    style: SaleStyle.dateHeader, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('${salesInGroup.length} ${SaleStyle.summaryOrderUnit}',
                    style: SaleStyle.dateHeaderGrey),
              ]),
            ),
            ...salesInGroup.map((s) => SaleCard(
              key: ValueKey('sale-${s.id}'),
              sale: s,
              isAdmin: Get.find<AuthController>().isAdmin,
            )),
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
      return const Center(child: Text(SaleStyle.noBillData));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: SaleStyle.padCardLg,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SaleStyle.brown700, SaleStyle.brown500],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: SaleStyle.r14,
              boxShadow: [
                BoxShadow(color: SaleStyle.brown700.withOpacity(0.25),
                    blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(children: [
              const Icon(Icons.receipt_long, color: SaleStyle.white70, size: 20),
              const SizedBox(height: 4),
              const Text(SaleStyle.summaryTotalBills,
                  style: TextStyle(color: SaleStyle.white70, fontSize: 12)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${fmt.format(_billsTotal(totalBills))} ${SaleStyle.currency}',
                    style: const TextStyle(color: SaleStyle.white, fontSize: 28,
                        fontWeight: FontWeight.w900, letterSpacing: 0.3)),
              ),
              const SizedBox(height: 4),
              Text('${totalBills.values.fold<int>(0, (s, e) => s + e)} ${SaleStyle.summaryTotalSheets}',
                  style: const TextStyle(color: SaleStyle.white70, fontSize: 11.5)),
            ]),
          ),
          const SizedBox(height: 14),
          _sectionLabel(Icons.list_alt, SaleStyle.sectionByDenom),
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

    const daysOfWeek = ['ວັນອາທິດ', 'ວັນຈັນ', 'ວັນອັງຄານ',
      'ວັນພຸດ', 'ວັນພະຫັດ', 'ວັນສຸກ', 'ວັນເສົາ'];
    final dayName = daysOfWeek[date.weekday % 7];
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (targetDate == today) return 'ມື້ນີ້ ($dayName, $formattedDate)';
    if (targetDate == yesterday) return 'ມື້ວານນີ້ ($dayName, $formattedDate)';
    return '$dayName, $formattedDate';
  }

  double _billsTotal(Map<int, int> bills) {
    double t = 0;
    bills.forEach((d, n) => t += d * n);
    return t;
  }

  Widget _sectionLabel(IconData icon, String text) {
    return Row(children: [
      const Icon(Icons.list_alt, size: 13, color: SaleStyle.brown700),
      const SizedBox(width: 6),
      Text(text, style: SaleStyle.sectionLabel),
    ]);
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count,
              (_) => Container(width: dashWidth, height: 1, color: SaleStyle.grey200)),
        );
      }),
    );
  }

  Widget _billsSummary(Map<int, int> bills, NumberFormat fmt, {bool showHeader = false}) {
    final all = <int>{...SaleStyle.billDenominations, ...bills.keys}.toList()
      ..sort((a, b) => b.compareTo(a));

    final total = _billsTotal(bills);
    final totalBills = bills.values.fold<int>(0, (s, e) => s + e);

    return Container(
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.r14,
        boxShadow: [
          BoxShadow(color: SaleStyle.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(children: [
          if (showHeader) ...[
            Row(children: [
              Expanded(flex: 3, child: Text(SaleStyle.summaryPerSheet,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900,
                      color: SaleStyle.grey500, letterSpacing: 1))),
              Expanded(flex: 2, child: Text(SaleStyle.summaryCount, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900,
                      color: SaleStyle.grey500, letterSpacing: 1))),
              Expanded(flex: 3, child: Text(SaleStyle.summaryTotal, textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900,
                      color: SaleStyle.grey500, letterSpacing: 1))),
            ]),
            const SizedBox(height: 4),
            _dashedDivider(),
          ],
          ...all.map((d) {
            final count = bills[d] ?? 0;
            final sub = d * count;
            final isEmpty = count == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(flex: 3, child: Row(children: [
                  Icon(Icons.payments_outlined, size: 13,
                      color: isEmpty ? SaleStyle.grey400 : SaleStyle.brown600),
                  const SizedBox(width: 5),
                  Text(fmt.format(d), style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800,
                    color: isEmpty ? SaleStyle.grey400 : SaleStyle.black87,
                  )),
                ])),
                Expanded(flex: 2, child: Text('$count', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800,
                        color: isEmpty ? SaleStyle.grey400 : SaleStyle.brown700))),
                Expanded(flex: 3, child: Text(fmt.format(sub), textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800,
                        color: isEmpty ? SaleStyle.grey400 : SaleStyle.black87))),
              ]),
            );
          }),
          _dashedDivider(),
          Row(children: [
            Expanded(flex: 3, child: Text(SaleStyle.summaryTotalLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: SaleStyle.brown800))),
            Expanded(flex: 2, child: Text('$totalBills ${SaleStyle.billCountSuffix}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: SaleStyle.grey700))),
            Expanded(flex: 3, child: Text('${fmt.format(total)} ${SaleStyle.currency}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900,
                    color: SaleStyle.brown800, letterSpacing: 0.2))),
          ]),
        ]),
      ),
    );
  }
}