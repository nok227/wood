import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import 'sales_summary_detail_page.dart';

class SalesSummaryPage extends StatelessWidget {
  const SalesSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('ສະຫຼຸບການຂາຍ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── ຕົວກອງວັນທີ ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Obx(() => Row(
                  children: [
                    _chip(controller, 'ທັງໝົດ', DateFilter.all),
                    _chip(controller, 'ມື້ນີ້', DateFilter.today),
                    _chip(controller, 'ອາທິດນີ້', DateFilter.week),
                    _chip(controller, 'ເດືອນນີ້', DateFilter.month),
                    _chip(controller, 'ປີນີ້', DateFilter.year),
                  ],
                )),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final sales = controller.filteredSalesList.toList();
              if (sales.isEmpty) {
                return const Center(
                    child: Text('ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້'));
              }
              final s = _Summary.from(sales);
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // ══ ຍອດລວມ ══
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
                  const SizedBox(height: 10),

                  // ══ ສົດ / ໂອນ ══
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
                            '${fmt.format(s.cashTotal)} ກີບ',
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
                            '${fmt.format(s.transferTotal)} ກີບ',
                            '${s.transferCount} ລາຍການ',
                            Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ══ ຢືນຢັນ / ລໍຖ້າ ══
                  Row(
                    children: [
                      Expanded(
                        child: _tapCard(
                          onTap: () => _open(
                            '✓ ເງິນເຂົ້າແລ້ວ',
                            sales.where((e) => e.isConfirmed).toList(),
                            Icons.check_circle_outline,
                            Colors.green.shade800,
                            SummaryDetailType.list,
                          ),
                          child: _statTile(
                            '✓ ເງິນເຂົ້າແລ້ວ',
                            '${fmt.format(s.confirmedTotal)} ກີບ',
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
                                    !e.isConfirmed && !e.isMismatch)
                                .toList(),
                            Icons.hourglass_bottom,
                            Colors.amber.shade900,
                            SummaryDetailType.list,
                          ),
                          child: _statTile(
                            '⏳ ລໍຖ້າກວດສອບ',
                            '${fmt.format(s.pendingTotal)} ກີບ',
                            '${s.count - s.confirmedCount} ລາຍການ',
                            Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ══ ບໍ່ຕົງ / ຕິດໜີ້ ══
                  Row(
                    children: [
                      Expanded(
                        child: _tapCard(
                          onTap: () => _open(
                            '⚠ ບັນຊີບໍ່ຕົງ',
                            sales.where((e) => e.isMismatch).toList(),
                            Icons.warning_amber_rounded,
                            const Color(0xFFB71C1C),
                            SummaryDetailType.list,
                          ),
                          child: _statTile(
                            '⚠ ບັນຊີບໍ່ຕົງ',
                            '${fmt.format(s.mismatchTotal)} ກີບ',
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
                            sales.where((e) => e.hasDebt).toList(),
                            Icons.receipt_long_outlined,
                            Colors.orange.shade800,
                            SummaryDetailType.list,
                          ),
                          child: _statTile(
                            '📝 ຕິດໜີ້',
                            '${fmt.format(s.debtTotal)} ກີບ',
                            '${s.debtCount} ລາຍການ',
                            Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ══ ສ່ວນລົດ / ເງິນທອນ ══
                  Row(
                    children: [
                      Expanded(
                        child: _tapCard(
                          onTap: () => _open(
                            '🏷 ລາຍລະອຽດສ່ວນລົດ',
                            sales
                                .where((e) => e.discountPerUnit > 0)
                                .toList(),
                            Icons.discount,
                            Colors.red,
                            SummaryDetailType.discount,
                          ),
                          child: _statTile(
                            '🏷 ສ່ວນລົດລວມ',
                            '${fmt.format(s.discountTotal)} ກີບ',
                            '${s.discountCount} ລາຍການ',
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
                            '${fmt.format(s.changeTotal)} ກີບ',
                            '${s.changeCount} ລາຍການ',
                            Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ══ 💰 ສະຫຼຸບໃບເງິນສົດ — ກົດໄດ້ ══
                  const SizedBox(height: 16),
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

                  // ══ ສະຫຼຸບຕາມລາຍການໄມ້ ══
                  const SizedBox(height: 16),
                  _sectionTitle('📦 ສະຫຼຸບຕາມລາຍການໄມ້ (ຫຼາຍ → ໜ້ອຍ)'),
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
                            .where((x) => x.productName == e.key)
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
    );
  }

  // ── ເປີດໜ້າລາຍລະອຽດ ──
  void _open(
    String title,
    List<SaleEntity> sales,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: c.selectedFilter.value == f,
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
        color: Colors.brown,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('ຍອດຂາຍລວມ',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${fmt.format(s.total)} ກີບ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${s.count} ລາຍການ · ຂາຍທັງໝົດ ${fmt.format(s.qty)} ຊິ້ນ',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700)),
              ),
              Icon(Icons.chevron_right,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          if (sub.isNotEmpty)
            Text(sub,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 💰 Preview ສະຫຼຸບໃບເງິນ (ຢູ່ໜ້າສະຫຼຸບ)
  // ══════════════════════════════════════════════
  Widget _cashBillsPreview(_Summary s, NumberFormat fmt) {
    final denoms = [100000, 50000, 20000, 10000, 5000, 2000, 1000, 500];
    final total = denoms.fold<double>(
        0, (acc, d) => acc + d * (s.notes[d] ?? 0));
    final totalBills =
        s.notes.values.fold<int>(0, (sum, e) => sum + e);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        children: [
          // ── ລາຍການໃບເງິນ ──
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: denoms.map((d) {
              final count = s.notes[d] ?? 0;
              final isEmpty = count == 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
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
          // ── ລວມ ──
          Row(
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.receipt_long,
                        size: 16, color: Colors.brown),
                    SizedBox(width: 4),
                    Text('ລວມ',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
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
              Text(
                '${fmt.format(total)} ກີບ',
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

  // ══════════════════════════════════════════════
  // 📦 ແຖວສິນຄ້າ — ພ້ອມອັນດັບທີ
  // ══════════════════════════════════════════════
  Widget _productRow({
    required int idx,
    required MapEntry<String, _ProductStat> e,
    required NumberFormat fmt,
    required VoidCallback onTap,
  }) {
    // ສີອັນດັບທີ 1-3
    final Color medal = idx == 0
        ? Colors.amber.shade700
        : idx == 1
            ? Colors.grey.shade600
            : idx == 2
                ? Colors.brown.shade400
                : Colors.brown.shade200;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
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
        title: Text(e.key.isNotEmpty ? e.key : 'ລາຍການໄມ້',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${e.value.count} ລາຍການ · ${fmt.format(e.value.qty)} ຊິ້ນ'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${fmt.format(e.value.total)} ກີບ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// _ProductStat & _Summary
// ══════════════════════════════════════════════
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
  final Map<int, int> notes = {};
  final Map<String, _ProductStat> products = {};

  _Summary.from(List<SaleEntity> sales) {
    for (final s in sales) {
      count++;
      total += s.totalAmount;
      qty += s.quantity;
      discountTotal += s.discountPerUnit * s.quantity;

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
      if (s.discountPerUnit > 0) discountCount++;
      if (s.changeAmount > 0) changeTotal += s.changeAmount;
      if (s.changeAmount > 0) changeCount++;

      final p =
          products.putIfAbsent(s.productName, () => _ProductStat());
      p.count++;
      p.qty += s.quantity;
      p.total += s.totalAmount;
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