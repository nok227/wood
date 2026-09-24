import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';
import '../widgets/sale_card.dart';
import 'add_payment_page.dart';
import 'sales_summary_page.dart';
import '../../../auth/auth_controller.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  // สถานะเปิด/ปิด เมนูปุ่มลอย
  bool _isFabOpen = false;

  // ดึงวันที่จากข้อมูล sale (รองรับ createdAt, date หรือ timestamp)
  DateTime _getSaleDate(dynamic sale) {
    try {
      if (sale.createdAt != null) {
        if (sale.createdAt is DateTime) return sale.createdAt;
        return DateTime.parse(sale.createdAt.toString());
      }
      if (sale.date != null) {
        if (sale.date is DateTime) return sale.date;
        return DateTime.parse(sale.date.toString());
      }
    } catch (_) {}
    return DateTime.now();
  }

  // แปลงวันที่เป็นข้อความแสดง วันในสัปดาห์, วัน/เดือน/ปี
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    final daysOfWeek = [
      'ວັນອາທິດ', // อาทิตย์
      'ວັນຈັນ', // จันทร์
      'ວັນອັງຄານ', // อังคาร
      'ວັນພຸດ', // พุธ
      'ວັນພະຫັດ', // พฤหัสบดี
      'ວັນສຸກ', // ศุกร์
      'ວັນເສົາ', // เสาร์
    ];

    String dayName = daysOfWeek[date.weekday % 7];
    String formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (targetDate == today) {
      return 'ມື້ນີ້ ($dayName, $formattedDate)';
    } else if (targetDate == yesterday) {
      return 'ມື້ວານນີ້ ($dayName, $formattedDate)';
    } else {
      return '$dayName, $formattedDate';
    }
  }

  // จัดกลุ่มบิลขายตามวันที่ (เรียงลำดับจากวันที่ล่าสุด)
  Map<String, List<dynamic>> _groupSalesByDate(List sales) {
    final Map<String, List<dynamic>> grouped = {};

    for (var sale in sales) {
      final DateTime date = _getSaleDate(sale);
      final String dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(sale);
    }

    // เรียงลำดับวันที่จากล่าสุดไปเก่าสุด
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final Map<String, List<dynamic>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
   final isAdminUser = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: Colors.brown[50], // พื้นหลังโทนสีไม้อ่อน
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   foregroundColor: Colors.brown[800],
      // ),
      body: Column(
        children: [
          // 📌 ตัวกรองหมวดหมู่เวลา (วันนี้, อาทิตย์นี้, เดือนนี้, ปีนี้, ทั้งหมด)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 4), 
            child: Obx(() => Row(
                  children: [
                    _filterChip(controller, 'ທັງໝົດ', DateFilter.all),
                    _filterChip(controller, 'ມື້ນີ້', DateFilter.today),
                    _filterChip(controller, 'ອາທິດນີ້', DateFilter.week),
                    _filterChip(controller, 'ເດືອນນີ້', DateFilter.month),
                    _filterChip(controller, 'ປີນີ້', DateFilter.year),
                  ],
                )),
          ),

          // ลิสต์รายการขายแบบจัดกลุ่มตามวันที่
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.brown));
              }

              if (controller.filteredSalesList.isEmpty) {
                return const Center(child: Text('ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້'));
              }

              // จัดกลุ่มรายการขายตามวันที่
              final groupedSales = _groupSalesByDate(controller.filteredSalesList);

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 120, left: 12, right: 12),
                itemCount: groupedSales.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedSales.keys.elementAt(index);
                  final salesInGroup = groupedSales[dateKey]!;
                  final firstSaleDate = _getSaleDate(salesInGroup.first);
                  final headerTitle = _formatDateHeader(firstSaleDate);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📌 Card หัวข้อแสดง วัน/เดือน/ปี, วันในสัปดาห์ และจำนวนบิล
                      Card(
                        color: Colors.brown[100],
                        elevation: 1,
                        margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.brown[800]),
                                  const SizedBox(width: 8),
                                  Text(
                                    headerTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.brown[900],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.brown[800],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${salesInGroup.length} ລາຍການ',
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

                      // รายการ SaleCard แต่ละรายการในกลุ่มนั้น
                      ...salesInGroup.map((sale) => SaleCard(sale: sale, isAdmin: isAdminUser)),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ตำแหน่งปุ่มลอยด้านล่างขวา โทนสีไม้
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            // ปุ่มสรุปการขาย / รายงาน
            FloatingActionButton.extended(
              heroTag: 'btnSummary',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Get.to(() => const SalesSummaryPage());
              },
              backgroundColor: Colors.brown[700],
              icon: const Icon(Icons.assessment_outlined, color: Colors.white),
              label: const Text('ສະຫຼຸບການຂາຍ', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),

            // ปุ่มบันทึกการขาย
            FloatingActionButton.extended(
              heroTag: 'btnAddPayment',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Get.to(() => const AddPaymentPage());
              },
              backgroundColor: Colors.brown[700],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('ບັນທຶກການຂາຍ', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
          ],

          // ปุ่มลอยหลัก
          FloatingActionButton(
            heroTag: 'btnMainFab',
            backgroundColor: Colors.brown[800],
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
              });
            },
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 📌 ปุ่มตัวกรองที่มีปุ่มเครื่องหมายถูกด้านหน้า (เป็นสีฟ้าเมื่อเลือก)
  Widget _filterChip(SalesController controller, String label, DateFilter filter) {
    final isSelected = controller.selectedFilter.value == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        showCheckmark: false, // ปิดไอคอนถูกเดิมของ Flutter เพื่อคุมสีเอง
        avatar: Icon(
          Icons.check_circle,
          color: isSelected ? Colors.blue : Colors.grey[400], // สีฟ้าเมื่อเลือก, สีเทาเมื่อไม่ได้เลือก
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.brown[900] : Colors.brown[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.brown[200],
        backgroundColor: Colors.brown[100],
        onSelected: (selected) {
          if (selected) controller.applyDateFilter(filter);
        },
      ),
    );
  }
}