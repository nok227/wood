import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';

enum DateFilter { today, week, month, year, all }

class SalesController extends GetxController {
  final SalesRepository repository;

  SalesController({required this.repository});

  var allSalesList = <SaleEntity>[].obs;
  var filteredSalesList = <SaleEntity>[].obs;
  var isLoading = false.obs;

  var selectedFilter = DateFilter.today.obs;

  var selectedProduct = Rxn<WoodProductModel>();
  var paymentType = 'cash'.obs;

  var cashCounts = <int, RxInt>{
    100000: 0.obs,
    50000: 0.obs,
    20000: 0.obs,
    10000: 0.obs,
    5000: 0.obs,
    2000: 0.obs,
    1000: 0.obs,
    500: 0.obs,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
  }

  Future<void> fetchSales() async {
    isLoading.value = true;
    try {
      final sales = await repository.getSales();
      allSalesList.assignAll(sales);
      applyDateFilter(selectedFilter.value);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດດຶງຂໍ້ມູນການຂາຍໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  void applyDateFilter(DateFilter filter) {
    selectedFilter.value = filter;
    final now = DateTime.now();
    filteredSalesList.assignAll(allSalesList.where((sale) {
      switch (filter) {
        case DateFilter.today:
          return sale.date.year == now.year &&
              sale.date.month == now.month &&
              sale.date.day == now.day;
        case DateFilter.week:
          final weekAgo = now.subtract(const Duration(days: 7));
          return sale.date.isAfter(weekAgo);
        case DateFilter.month:
          return sale.date.year == now.year && sale.date.month == now.month;
        case DateFilter.year:
          return sale.date.year == now.year;
        case DateFilter.all:
          return true;
      }
    }).toList());
  }

  double get totalCashAmount {
    double total = 0;
    cashCounts.forEach((denom, count) {
      total += denom * count.value;
    });
    return total;
  }

  void updateCashCount(int denom, int count) {
    if (count >= 0) cashCounts[denom]?.value = count;
  }

  void resetForm() {
    selectedProduct.value = null;
    cashCounts.forEach((_, count) => count.value = 0);
  }

  // ══════════════════════════════════════════════
  // 🔒 Admin: ລຶບ (Firebase + Cloudinary)
  // ══════════════════════════════════════════════
  Future<void> deleteSale(String id) async {
    try {
      final sale = allSalesList.firstWhereOrNull((s) => s.id == id);
      if (sale == null) {
        Get.snackbar('ຜິດພາດ', 'ບໍ່ພົບລາຍການ');
        return;
      }
      final urls = <String>[
        ...sale.paymentImageUrls,
        ...sale.billImageUrls,
        ...sale.topUpImageUrls,
      ];
      if (urls.isNotEmpty) {
        await CloudinaryService.deleteImages(urls);
      }
      await repository.deleteSale(id);
      allSalesList.removeWhere((s) => s.id == id);
      applyDateFilter(selectedFilter.value);
      Get.snackbar('ສຳເລັດ', 'ລຶບລາຍການ ແລະ ຮູບພາບແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  // ══════════════════════════════════════════════
  // 🔒 Admin: ຢືນຢັນສະຖານະ
  // ══════════════════════════════════════════════
  Future<void> confirmPaymentStatus(String id, bool currentStatus) async {
    try {
      await repository.updateSaleStatus(id, !currentStatus);
      await fetchSales();
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດປ່ຽນສະຖານະໄດ້');
    }
  }

  // ══════════════════════════════════════════════
  // ⚠ ບັນຊີບໍ່ຕົງ
  // ══════════════════════════════════════════════
  Future<void> markAsMismatch(String id, String note) async {
    try {
      await repository.updateMismatchStatus(
        id,
        isMismatch: true,
        mismatchNote: note,
      );
      await fetchSales();
      Get.snackbar('ບັນທຶກ', 'ບັນຊີບໍ່ຕົງກັນແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    }
  }

  Future<void> clearMismatch(String id) async {
    try {
      await repository.updateMismatchStatus(id, isMismatch: false);
      await fetchSales();
      Get.snackbar('ສຳເລັດ', 'ຍົກເລີກສະຖານະບໍ່ຕົງແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດຍົກເລີກໄດ້: $e');
    }
  }

  Future<void> updateMismatchNote(String id, String note) async {
    try {
      await repository.updateMismatchStatus(
        id,
        isMismatch: true,
        mismatchNote: note,
      );
      await fetchSales();
      Get.snackbar('ສຳເລັດ', 'ອັບເດດໝາຍເຫດແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອັບເດດໄດ້: $e');
    }
  }

  // ══════════════════════════════════════════════
  // 🆕 ປິດໜີ້ — ຕອນລູກຄ້າມາຈ່າຍໜີ້ໝົດ
  // ══════════════════════════════════════════════
  Future<void> markDebtAsPaid(String id) async {
    try {
      await repository.markDebtAsPaid(id);
      await fetchSales();
      Get.snackbar(
        'ສຳເລັດ',
        'ປິດໜີ້ຮຽບຮ້ອຍ · ຮັບເງິນແລ້ວ',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດປິດໜີ້ໄດ້: $e');
    }
  }

  String formatLaoDate(DateTime date) {
    const laoDays = [
      'ວັນຈັນ',
      'ວັນອັງຄານ',
      'ວັນພຸດ',
      'ວັນພະຫັດ',
      'ວັນສຸກ',
      'ວັນເສົາ',
      'ວັນອາທິດ',
    ];
    final dayName = laoDays[date.weekday - 1];
    return '$dayName ${DateFormat('dd/MM/yyyy').format(date)}';
  }
}