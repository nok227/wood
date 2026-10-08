import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

import '../../../domain/entities/sale_order_entity.dart';
import '../../controllers/sales_controller.dart';
import '../../widgets/sales_summary_skeleton.dart';
import 'sales_summary_detail_page.dart';

class SalesSummaryPage extends StatefulWidget {
  const SalesSummaryPage({super.key});

  @override
  State<SalesSummaryPage> createState() => _SalesSummaryPageState();
}

class _SalesSummaryPageState extends State<SalesSummaryPage> {
  final ScreenshotController _screenshotCtrl = ScreenshotController();
  bool _savingImage = false;

  double? _downX;
  double? _downY;
  static const double _minSwipe = 60;
  static const double _hRatio = 1.2;

  void _onPointerDown(PointerDownEvent e) {
    _downX = e.position.dx;
    _downY = e.position.dy;
  }

  void _onPointerUp(PointerUpEvent e) {
    final dx0 = _downX;
    final dy0 = _downY;
    _downX = null;
    _downY = null;
    if (dx0 == null || dy0 == null) return;

    final dx = e.position.dx - dx0;
    final dy = e.position.dy - dy0;
    if (dx.abs() < _minSwipe) return;
    if (dx.abs() < dy.abs() * _hRatio) return;

    HapticFeedback.lightImpact();
    Get.back();
  }

  Future<void> _saveToDevice() async {
    if (_savingImage) return;
    setState(() => _savingImage = true);
    try {
      final Uint8List? imageBytes = await _screenshotCtrl.capture(
        delay: const Duration(milliseconds: 150),
        pixelRatio: 2.5,
      );
      if (imageBytes == null) throw Exception('ຈັບພາບບໍ່ສຳເລັດ');

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);

      final fileName = 'sale_summary_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(imageBytes, name: fileName);

      if (mounted) {
        _snack(SaleStyle.alertSuccess, SaleStyle.saveImageSuccess,
            SaleStyle.green700, Icons.check_circle);
      }
    } catch (e) {
      if (mounted) {
        _snack(SaleStyle.errorMsg, '${SaleStyle.saveImageError}: $e',
            SaleStyle.red700, Icons.error_outline);
      }
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  void _snack(String title, String msg, Color bg, IconData icon) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title, msg,
      backgroundColor: bg,
      colorText: SaleStyle.white,
      icon: Icon(icon, color: SaleStyle.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: SaleStyle.snackbarRadius,
      duration: SaleStyle.snackbarLong,
      boxShadows: [
        BoxShadow(
          color: bg.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    final fmt = NumberFormat('#,###');

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: SaleStyle.bg,
        appBar: AppBar(
          title: const Text(
            SaleStyle.summaryPageTitle,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: SaleStyle.brown700,
          foregroundColor: SaleStyle.white,
          elevation: 0,
          actions: [
            if (_savingImage)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: SaleStyle.white,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: SaleStyle.saveToDevice,
                onPressed: _saveToDevice,
              ),
          ],
        ),
        body: Screenshot(
          controller: _screenshotCtrl,
          child: Container(
            color: SaleStyle.bg,
            child: Column(
              children: [
                Container(
                  color: SaleStyle.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Obx(() => Row(
                      children: [
                        _chip(controller, SaleStyle.filterAll, DateFilter.all),
                        _chip(controller, SaleStyle.filterToday, DateFilter.today),
                        _chip(controller, SaleStyle.filterWeek, DateFilter.week),
                        _chip(controller, SaleStyle.filterMonth, DateFilter.month),
                        _chip(controller, SaleStyle.filterYear, DateFilter.year),
                      ],
                    )),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.allSalesList.isEmpty) {
                      return const SalesSummarySkeleton();
                    }
                    final sales = controller.filteredSalesList.toList();
                    if (sales.isEmpty) {
                      return const Center(child: Text(SaleStyle.noSales));
                    }
                    final s = _Summary.from(sales);
                    return ListView(
                      padding: SaleStyle.padCardLg,
                      children: [
                        _tapCard(
                          onTap: () => _open(SaleStyle.summaryAllItems, sales,
                              Icons.list_alt, SaleStyle.brown700, SummaryDetailType.list),
                          child: _totalCard(s, fmt),
                        ),
                        SaleStyle.gapMd,
                        Row(children: [
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryCash,
                              sales.where((e) => e.cashPaidAmount > 0 || e.paymentType == 'cash').toList(),
                              Icons.payments_outlined, SaleStyle.green700, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryCash, s.cashTotal,
                                '${s.cashCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.green700),
                          )),
                          SaleStyle.gapSm,
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryTransfer,
                              sales.where((e) => e.transferPaidAmount > 0 || e.paymentType == 'transfer').toList(),
                              Icons.account_balance, SaleStyle.blue700, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryTransfer, s.transferTotal,
                                '${s.transferCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.blue700),
                          )),
                        ]),
                        SaleStyle.gapSm,
                        Row(children: [
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryConfirmed,
                              sales.where((e) => e.isConfirmed).toList(),
                              Icons.check_circle_outline, SaleStyle.green800, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryConfirmed, s.confirmedTotal,
                                '${s.confirmedCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.green800),
                          )),
                          SaleStyle.gapSm,
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryPending,
                              sales.where((e) => !e.isConfirmed && !e.isMismatch).toList(),
                              Icons.hourglass_bottom, SaleStyle.amber900, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryPending, s.pendingTotal,
                                '${s.count - s.confirmedCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.amber900),
                          )),
                        ]),
                        SaleStyle.gapSm,
                        Row(children: [
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryMismatch,
                              sales.where((e) => e.isMismatch).toList(),
                              Icons.warning_amber_rounded, SaleStyle.mismatch, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryMismatch, s.mismatchTotal,
                                '${s.mismatchCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.mismatch),
                          )),
                          SaleStyle.gapSm,
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryDebt,
                              sales.where((e) => e.hasDebt).toList(),
                              Icons.receipt_long_outlined, SaleStyle.orange800, SummaryDetailType.list),
                            child: _statTile(SaleStyle.summaryDebt, s.debtTotal,
                                '${s.debtCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.orange800),
                          )),
                        ]),
                        SaleStyle.gapSm,
                        Row(children: [
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryDiscountDetail,
                              sales.where((e) => e.hasDiscount).toList(),
                              Icons.discount, SaleStyle.red600, SummaryDetailType.discount),
                            child: _statTile(SaleStyle.summaryDiscount, s.discountTotal,
                                '${s.discountCount} ${SaleStyle.summaryOrderUnit}', SaleStyle.red600),
                          )),
                          SaleStyle.gapSm,
                          Expanded(child: _tapCard(
                            onTap: () => _open(
                              SaleStyle.summaryChangeDetail,
                              sales.where((e) => e.changeAmount > 0).toList(),
                              Icons.money_off, SaleStyle.black87, SummaryDetailType.change),
                            child: _statTile(SaleStyle.summaryChange, s.changeTotal,
                                '${s.changeCount} ${SaleStyle.summaryItemsUnit}', SaleStyle.black87),
                          )),
                        ]),
                        const SizedBox(height: 18),
                        _sectionTitle(SaleStyle.sectionRefund),
                        _tapCard(
                          onTap: () => _open(SaleStyle.summaryAllBills, sales,
                              Icons.payments, SaleStyle.brown700, SummaryDetailType.cashBills),
                          child: _cashBillsPreview(s, fmt),
                        ),
                        const SizedBox(height: 18),
                        _sectionTitle(SaleStyle.sectionTopProducts),
                        ...s.sortedProducts.asMap().entries.map((entry) {
                          return _productRow(
                            idx: entry.key,
                            e: entry.value,
                            fmt: fmt,
                            onTap: () => _open(
                              '📦 ${entry.value.key}',
                              sales.where((x) => x.items.any((it) => it.productName == entry.value.key)).toList(),
                              Icons.inventory_2_outlined, SaleStyle.brown700, SummaryDetailType.list),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(String title, List<SaleOrderEntity> sales, IconData icon,
      Color color, SummaryDetailType type) {
    Get.to(() => SalesSummaryDetailPage(
      title: title, sales: sales, icon: icon, accentColor: color, detailType: type,
    ));
  }

  Widget _tapCard({required VoidCallback onTap, required Widget child}) {
    return InkWell(onTap: onTap, borderRadius: SaleStyle.r10, child: child);
  }

  Widget _chip(SalesController c, String label, DateFilter f) {
    final selected = c.selectedFilter.value == f;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(Icons.check_circle,
            color: selected ? SaleStyle.brown800 : SaleStyle.grey400, size: 16),
        label: Text(label,
            style: TextStyle(
              color: selected ? SaleStyle.brown900 : SaleStyle.brown700,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.5,
            )),
        selected: selected,
        selectedColor: SaleStyle.brown100,
        backgroundColor: SaleStyle.brown50,
        onSelected: (v) { if (v) c.applyDateFilter(f); },
      ),
    );
  }

  Widget _totalCard(_Summary s, NumberFormat fmt) {
    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SaleStyle.brown700, SaleStyle.brown500],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: SaleStyle.r16,
        boxShadow: [
          BoxShadow(
            color: SaleStyle.brown700.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Expanded(child: Text(SaleStyle.totalSales,
                style: TextStyle(color: SaleStyle.white70, fontSize: 13, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: SaleStyle.white70),
          ]),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedNumber(
              value: s.total,
              suffix: ' ${SaleStyle.currency}',
              duration: 1400,
              style: const TextStyle(
                color: SaleStyle.white, fontSize: 30,
                fontWeight: FontWeight.w900, letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.receipt_long, color: SaleStyle.white.withOpacity(0.7), size: 13),
            const SizedBox(width: 5),
            Text(
              '${s.count} ${SaleStyle.summaryOrderUnit} · ${s.itemCount} ${SaleStyle.summaryItemsUnit} · ${fmt.format(s.qty)} ${SaleStyle.summaryPiecesUnit}',
              style: TextStyle(color: SaleStyle.white.withOpacity(0.85), fontSize: 12.5),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _statTile(String title, double value, String sub, Color color) {
    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.r12,
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
            Icon(Icons.chevron_right, size: 16, color: SaleStyle.grey400),
          ]),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedNumber(
              value: value, suffix: ' ${SaleStyle.currency}', duration: 1200,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          if (sub.isNotEmpty)
            Text(sub, style: const TextStyle(fontSize: 11, color: SaleStyle.grey600)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(color: SaleStyle.brown700, borderRadius: SaleStyle.r2),
        ),
        const SizedBox(width: 8),
        Text(t, style: SaleStyle.sectionTitle),
      ]),
    );
  }

  Widget _cashBillsPreview(_Summary s, NumberFormat fmt) {
    final denoms = SaleStyle.billDenominations;
    final total = denoms.fold<double>(0, (acc, d) => acc + d * (s.notes[d] ?? 0));
    final totalBills = s.notes.values.fold<int>(0, (sum, e) => sum + e);

    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.r12,
        border: Border.all(color: SaleStyle.brown200, width: 1.2),
        boxShadow: [
          BoxShadow(color: SaleStyle.brown700.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: [
        Wrap(
          spacing: 6, runSpacing: 6,
          children: denoms.map((d) {
            final count = s.notes[d] ?? 0;
            final isEmpty = count == 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isEmpty ? SaleStyle.grey100 : SaleStyle.brown50,
                borderRadius: SaleStyle.r6,
                border: Border.all(color: isEmpty ? SaleStyle.grey300 : SaleStyle.brown300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(fmt.format(d),
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: isEmpty ? SaleStyle.grey400 : SaleStyle.brown800,
                    )),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isEmpty ? SaleStyle.grey300 : SaleStyle.brown800,
                    borderRadius: SaleStyle.r8,
                  ),
                  child: Text('×$count',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold,
                        color: isEmpty ? SaleStyle.grey600 : SaleStyle.white,
                      )),
                ),
              ]),
            );
          }).toList(),
        ),
        const Divider(height: 18),
        Row(children: [
          const Expanded(child: Row(children: [
            Icon(Icons.receipt_long, size: 16, color: SaleStyle.brown700),
            SizedBox(width: 4),
            Text(SaleStyle.summaryTotal,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ])),
          Text('$totalBills ${SaleStyle.billCountSuffix}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SaleStyle.grey700)),
          const SizedBox(width: 10),
          AnimatedNumber(
            value: total, suffix: ' ${SaleStyle.currency}', duration: 1200,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: SaleStyle.brown700),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: SaleStyle.brown700),
        ]),
      ]),
    );
  }

  Widget _productRow({
    required int idx,
    required MapEntry<String, _ProductStat> e,
    required NumberFormat fmt,
    required VoidCallback onTap,
  }) {
    final Color medal = idx == 0
        ? SaleStyle.medal1
        : idx == 1
            ? SaleStyle.medal2
            : idx == 2
                ? SaleStyle.medal3
                : SaleStyle.medal4;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: SaleStyle.r12,
        side: const BorderSide(color: SaleStyle.brown100, width: 1.2),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: medal, shape: BoxShape.circle),
          child: Center(child: Text('${idx + 1}',
              style: const TextStyle(color: SaleStyle.white, fontSize: 13, fontWeight: FontWeight.w900))),
        ),
        title: Text(e.key.isNotEmpty ? e.key : 'ລາຍການໄມ້',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${e.value.count} ${SaleStyle.summaryCountTimes} · ${fmt.format(e.value.qty)} ${SaleStyle.summaryPiecesUnit}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedNumber(
            value: e.value.total, suffix: ' ${SaleStyle.currency}', duration: 1200,
            style: const TextStyle(fontWeight: FontWeight.bold, color: SaleStyle.brown700),
          ),
          const Icon(Icons.chevron_right, color: SaleStyle.grey500),
        ]),
      ),
    );
  }
}

class _ProductStat {
  int qty = 0;
  int count = 0;
  double total = 0;
}

class _Summary {
  double total = 0;
  double cashTotal = 0;
  double transferTotal = 0;
  double confirmedTotal = 0;
  double pendingTotal = 0;
  double discountTotal = 0;
  double changeTotal = 0;
  double debtTotal = 0;
  double mismatchTotal = 0;
  int count = 0;
  int cashCount = 0;
  int transferCount = 0;
  int confirmedCount = 0;
  int debtCount = 0;
  int mismatchCount = 0;
  int discountCount = 0;
  int changeCount = 0;
  int qty = 0;
  int itemCount = 0;
  final Map<int, int> notes = {};
  final Map<String, _ProductStat> products = {};

  _Summary.from(List<SaleOrderEntity> sales) {
    for (final s in sales) {
      count++;
      total += s.totalAmount;
      qty += s.totalQuantity;
      itemCount += s.itemCount;
      discountTotal += s.discountTotal;

      if (s.cashPaidAmount > 0 || s.paymentType == 'cash') {
        cashCount++;
        cashTotal += s.cashPaidAmount > 0 ? s.cashPaidAmount : s.totalAmount;
        s.cashDenominations?.forEach((denom, n) {
          notes[denom] = (notes[denom] ?? 0) + n;
        });
      }
      if (s.transferPaidAmount > 0 || s.paymentType == 'transfer') {
        transferCount++;
        transferTotal += s.transferPaidAmount > 0 ? s.transferPaidAmount : s.totalAmount;
      }

      if (s.isConfirmed) {
        confirmedCount++;
        confirmedTotal += s.totalAmount;
      } else {
        pendingTotal += s.totalAmount;
      }

      if (s.hasDebt) { debtCount++; debtTotal += s.debtAmount; }
      if (s.isMismatch) { mismatchCount++; mismatchTotal += s.totalAmount; }
      if (s.hasDiscount) discountCount++;
      if (s.changeAmount > 0) { changeTotal += s.changeAmount; changeCount++; }

      for (final item in s.items) {
        final p = products.putIfAbsent(item.productName, () => _ProductStat());
        p.count++;
        p.qty += item.quantity;
        p.total += item.totalAmount;
      }
    }
  }

  List<MapEntry<String, _ProductStat>> get sortedProducts {
    final l = products.entries.toList();
    l.sort((a, b) => b.value.total.compareTo(a.value.total));
    return l;
  }
}