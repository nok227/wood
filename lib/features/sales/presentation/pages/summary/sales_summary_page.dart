import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import 'package:wood/core/widgets/animated_number.dart';
import 'package:wood/core/widgets/skeletons/skeletons.dart';

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

      if (imageBytes == null) {
        throw Exception('ຈັບພາບບໍ່ສຳເລັດ');
      }

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      final fileName =
          'sale_summary_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(imageBytes, name: fileName);

      if (mounted) {
        _snack('ສຳເລັດ', 'ບັນທຶກລົງຄັງຮູບແລ້ວ', Colors.green.shade700,
            Icons.check_circle);
      }
    } catch (e) {
      if (mounted) {
        _snack('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e',
            Colors.red.shade700, Icons.error_outline);
      }
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  void _snack(String title, String msg, Color bg, IconData icon) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      msg,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
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
        backgroundColor: const Color(0xFFF5F0EA),
        appBar: AppBar(
          title: const Text(
            'ສະຫຼຸບການຂາຍ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (_savingImage)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: 'ບັນທຶກລົງເຄື່ອງ',
                onPressed: _saveToDevice,
              ),
          ],
        ),
        body: Screenshot(
          controller: _screenshotCtrl,
          child: Container(
            color: const Color(0xFFF5F0EA),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    child: Obx(() => Row(
                          children: [
                            _chip(controller, 'ທັງໝົດ',
                                DateFilter.all),
                            _chip(controller, 'ມື້ນີ້',
                                DateFilter.today),
                            _chip(controller, 'ອາທິດນີ້',
                                DateFilter.week),
                            _chip(controller, 'ເດືອນນີ້',
                                DateFilter.month),
                            _chip(controller, 'ປີນີ້',
                                DateFilter.year),
                          ],
                        )),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.allSalesList.isEmpty) {
                      return const SalesSummarySkeleton();
                    }
                    final sales = controller.filteredSalesList.toList();
                    if (sales.isEmpty) {
                      return const Center(
                        child: Text('ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້'),
                      );
                    }
                    final s = _Summary.from(sales);
                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _tapCard(
                          onTap: () => _open(
                            'ລາຍການທັງໝົດ',
                            sales,
                            Icons.list_alt,
                            Colors.brown,
                            SummaryDetailType.list,
                          ),
                          child: _totalCard(s, fmt),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '💵 ເງິນສົດ',
                                  sales
                                      .where((e) =>
                                          e.cashPaidAmount > 0 ||
                                          e.paymentType == 'cash')
                                      .toList(),
                                  Icons.payments_outlined,
                                  Colors.green.shade700,
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '💵 ເງິນສົດ',
                                  s.cashTotal,
                                  '${s.cashCount} ລາຍການ',
                                  Colors.green.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '🏦 ເງິນໂອນ',
                                  sales
                                      .where((e) =>
                                          e.transferPaidAmount > 0 ||
                                          e.paymentType == 'transfer')
                                      .toList(),
                                  Icons.account_balance,
                                  Colors.blue.shade700,
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '🏦 ເງິນໂອນ',
                                  s.transferTotal,
                                  '${s.transferCount} ລາຍການ',
                                  Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '✓ ເງິນເຂົ້າແລ້ວ',
                                  sales
                                      .where((e) => e.isConfirmed)
                                      .toList(),
                                  Icons.check_circle_outline,
                                  Colors.green.shade800,
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '✓ ເງິນເຂົ້າແລ້ວ',
                                  s.confirmedTotal,
                                  '${s.confirmedCount} ລາຍການ',
                                  Colors.green.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '⏳ ລໍຖ້າກວດສອບ',
                                  sales
                                      .where((e) =>
                                          !e.isConfirmed &&
                                          !e.isMismatch)
                                      .toList(),
                                  Icons.hourglass_bottom,
                                  Colors.amber.shade900,
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '⏳ ລໍຖ້າກວດສອບ',
                                  s.pendingTotal,
                                  '${s.count - s.confirmedCount} ລາຍການ',
                                  Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '⚠ ບັນຊີບໍ່ຕົງ',
                                  sales
                                      .where((e) => e.isMismatch)
                                      .toList(),
                                  Icons.warning_amber_rounded,
                                  const Color(0xFFB71C1C),
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '⚠ ບັນຊີບໍ່ຕົງ',
                                  s.mismatchTotal,
                                  '${s.mismatchCount} ລາຍການ',
                                  const Color(0xFFB71C1C),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '📝 ຕິດໜີ້',
                                  sales
                                      .where((e) => e.hasDebt)
                                      .toList(),
                                  Icons.receipt_long_outlined,
                                  Colors.orange.shade800,
                                  SummaryDetailType.list,
                                ),
                                child: _statTile(
                                  '📝 ຕິດໜີ້',
                                  s.debtTotal,
                                  '${s.debtCount} ລາຍການ',
                                  Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '🏷 ລາຍລະອຽດສ່ວນລົດ',
                                  sales
                                      .where((e) => e.hasDiscount)
                                      .toList(),
                                  Icons.discount,
                                  Colors.red,
                                  SummaryDetailType.discount,
                                ),
                                child: _statTile(
                                  '🏷 ສ່ວນລົດລວມ',
                                  s.discountTotal,
                                  '${s.discountCount} ອໍເດີ',
                                  Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _tapCard(
                                onTap: () => _open(
                                  '💰 ລາຍລະອຽດເງິນທອນ',
                                  sales
                                      .where((e) => e.changeAmount > 0)
                                      .toList(),
                                  Icons.money_off,
                                  Colors.black87,
                                  SummaryDetailType.change,
                                ),
                                child: _statTile(
                                  '💰 ເງິນທອນລວມ',
                                  s.changeTotal,
                                  '${s.changeCount} ລາຍການ',
                                  Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _sectionTitle('💰 ສະຫຼຸບໃບເງິນທີ່ໄດ້ຮັບ'),
                        _tapCard(
                          onTap: () => _open(
                            '💰 ໃບເງິນທັງໝົດ',
                            sales,
                            Icons.payments,
                            Colors.brown,
                            SummaryDetailType.cashBills,
                          ),
                          child: _cashBillsPreview(s, fmt),
                        ),
                        const SizedBox(height: 18),
                        _sectionTitle(
                            '📦 ສະຫຼຸບຕາມລາຍການໄມ້ (ຫຼາຍ → ໜ້ອຍ)'),
                        ...s.sortedProducts.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final e = entry.value;
                          return _productRow(
                            idx: idx,
                            e: e,
                            fmt: fmt,
                            onTap: () => _open(
                              '📦 ${e.key}',
                              sales
                                  .where((x) => x.items.any(
                                      (it) => it.productName == e.key))
                                  .toList(),
                              Icons.inventory_2_outlined,
                              Colors.brown,
                              SummaryDetailType.list,
                            ),
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

  void _open(
    String title,
    List<SaleOrderEntity> sales,
    IconData icon,
    Color color,
    SummaryDetailType type,
  ) {
    Get.to(() => SalesSummaryDetailPage(
          title: title,
          sales: sales,
          icon: icon,
          accentColor: color,
          detailType: type,
        ));
  }

  Widget _tapCard({required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }

  Widget _chip(SalesController c, String label, DateFilter f) {
    final selected = c.selectedFilter.value == f;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(
          Icons.check_circle,
          color: selected ? Colors.brown.shade800 : Colors.grey.shade400,
          size: 16,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.brown.shade900 : Colors.brown.shade700,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.5,
          ),
        ),
        selected: selected,
        selectedColor: Colors.brown.shade100,
        backgroundColor: Colors.brown.shade50,
        onSelected: (v) {
          if (v) c.applyDateFilter(f);
        },
      ),
    );
  }

  Widget _totalCard(_Summary s, NumberFormat fmt) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'ຍອດຂາຍລວມ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedNumber(
              value: s.total,
              suffix: ' ກີບ',
              duration: 1400,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.receipt_long,
                  color: Colors.white.withOpacity(0.7), size: 13),
              const SizedBox(width: 5),
              Text(
                '${s.count} ອໍເດີ · ${s.itemCount} ລາຍການ · ${fmt.format(s.qty)} ຊິ້ນ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String title, double value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedNumber(
              value: value,
              suffix: ' ກີບ',
              duration: 1200,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          if (sub.isNotEmpty)
            Text(
              sub,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.brown.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: Colors.brown,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashBillsPreview(_Summary s, NumberFormat fmt) {
    final denoms = [100000, 50000, 20000, 10000, 5000, 2000, 1000, 500];
    final total = denoms.fold<double>(
        0, (acc, d) => acc + d * (s.notes[d] ?? 0));
    final totalBills = s.notes.values.fold<int>(0, (sum, e) => sum + e);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: denoms.map((d) {
              final count = s.notes[d] ?? 0;
              final isEmpty = count == 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isEmpty
                      ? Colors.grey.shade100
                      : Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isEmpty
                        ? Colors.grey.shade300
                        : Colors.brown.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt.format(d),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isEmpty
                            ? Colors.grey.shade400
                            : Colors.brown.shade800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isEmpty
                            ? Colors.grey.shade300
                            : Colors.brown.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '×$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isEmpty
                              ? Colors.grey.shade600
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.receipt_long,
                        size: 16, color: Colors.brown),
                    SizedBox(width: 4),
                    Text(
                      'ລວມ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$totalBills ໃບ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedNumber(
                value: total,
                suffix: ' ກີບ',
                duration: 1200,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productRow({
    required int idx,
    required MapEntry<String, _ProductStat> e,
    required NumberFormat fmt,
    required VoidCallback onTap,
  }) {
    final Color medal = idx == 0
        ? Colors.amber.shade700
        : idx == 1
            ? Colors.grey.shade600
            : idx == 2
                ? Colors.brown.shade400
                : Colors.brown.shade200;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade100, width: 1.2),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: medal,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${idx + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        title: Text(
          e.key.isNotEmpty ? e.key : 'ລາຍການໄມ້',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${e.value.count} ຄັ້ງ · ${fmt.format(e.value.qty)} ຊິ້ນ',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedNumber(
              value: e.value.total,
              suffix: ' ກີບ',
              duration: 1200,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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
        cashTotal +=
            s.cashPaidAmount > 0 ? s.cashPaidAmount : s.totalAmount;
        s.cashDenominations?.forEach((denom, n) {
          notes[denom] = (notes[denom] ?? 0) + n;
        });
      }
      if (s.transferPaidAmount > 0 || s.paymentType == 'transfer') {
        transferCount++;
        transferTotal +=
            s.transferPaidAmount > 0 ? s.transferPaidAmount : s.totalAmount;
      }

      if (s.isConfirmed) {
        confirmedCount++;
        confirmedTotal += s.totalAmount;
      } else {
        pendingTotal += s.totalAmount;
      }

      if (s.hasDebt) {
        debtCount++;
        debtTotal += s.debtAmount;
      }
      if (s.isMismatch) {
        mismatchCount++;
        mismatchTotal += s.totalAmount;
      }
      if (s.hasDiscount) discountCount++;
      if (s.changeAmount > 0) {
        changeTotal += s.changeAmount;
        changeCount++;
      }

      for (final item in s.items) {
        final p =
            products.putIfAbsent(item.productName, () => _ProductStat());
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

  List<MapEntry<int, int>> get sortedNotes {
    final l = notes.entries.toList();
    l.sort((a, b) => b.key.compareTo(a.key));
    return l;
  }
}