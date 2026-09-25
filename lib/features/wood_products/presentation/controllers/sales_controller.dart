import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
import 'package:wood/features/wood_products/domain/entities/app_notification.dart';
import 'package:wood/features/wood_products/presentation/controllers/notification_controller.dart';
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

  // ─────────────────────────────────────────────
  // 🔔 Helper — push notification ຢ່າງປອດໄພ
  // ─────────────────────────────────────────────
  Future<void> _notify({
    required AppNotificationType type,
    required String title,
    required String message,
    String? targetId,
    NotificationAudience audience = NotificationAudience.all,
  }) async {
    if (!Get.isRegistered<NotificationController>()) return;
    try {
      await Get.find<NotificationController>().push(
        type: type,
        title: title,
        message: message,
        audience: audience,
        targetId: targetId,
      );
    } catch (_) {}
  }

  Future<void> fetchSales() async {
    isLoading.value = true;
    try {
      final sales = await repository.getSales();
      allSalesList.assignAll(sales);
      applyDateFilter(selectedFilter.value);
    } catch (e) {
      debugPrint('fetchSales error: $e');
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດດຶງຂໍ້ມູນໄດ້');
    } finally {
      isLoading.value = false;
    }
  }

  void applyDateFilter(DateFilter filter) {
    selectedFilter.value = filter;
    final now = DateTime.now();
    filteredSalesList.assignAll(allSalesList.where((s) {
      switch (filter) {
        case DateFilter.today:
          return s.date.year == now.year &&
              s.date.month == now.month &&
              s.date.day == now.day;
        case DateFilter.week:
          return s.date.isAfter(now.subtract(const Duration(days: 7)));
        case DateFilter.month:
          return s.date.year == now.year && s.date.month == now.month;
        case DateFilter.year:
          return s.date.year == now.year;
        case DateFilter.all:
          return true;
      }
    }).toList());
  }

  double get totalCashAmount {
    double t = 0;
    cashCounts.forEach((d, c) => t += d * c.value);
    return t;
  }

  void updateCashCount(int d, int c) {
    if (c >= 0) cashCounts[d]?.value = c;
  }

  void resetForm() {
    selectedProduct.value = null;
    cashCounts.forEach((_, c) => c.value = 0);
  }

  // ══════════════════════════════════════════════
  // 🔔 ເອີ້ນຈາກ add_payment_page ຫຼັງບັນທຶກການຂາຍສຳເລັດ
  // ══════════════════════════════════════════════
  Future<void> notifyNewSale(SaleEntity sale) async {
    await _notify(
      type: AppNotificationType.saleAdd,
      title: 'ບັນທຶກການຂາຍໃໝ່',
      message: '"${sale.productName}" '
          '${NumberFormat('#,###').format(sale.totalAmount)} ກີບ'
          '${sale.hasDebt ? " (ຕິດໜີ້ ${NumberFormat('#,###').format(sale.debtAmount)})" : ""}',
      targetId: sale.id,
    );
  }

  // ══════════════════════════════════════════════
  // 🔒 ລຶບ
  // ══════════════════════════════════════════════
  Future<void> deleteSale(String id) async {
    try {
      final sale = allSalesList.firstWhereOrNull((s) => s.id == id);
      final urls = <String>[
        ...?sale?.paymentImageUrls,
        ...?sale?.billImageUrls,
        ...?sale?.topUpImageUrls,
      ].where((u) => u.isNotEmpty).toList();

      await repository.deleteSale(id);
      allSalesList.removeWhere((s) => s.id == id);
      applyDateFilter(selectedFilter.value);

      // 🔔 ແຈ້ງເຕືອນ
      await _notify(
        type: AppNotificationType.saleDelete,
        title: 'ລຶບລາຍການຂາຍ',
        message: 'ລຶບ "${sale?.productName ?? "ລາຍການ"}" '
            '${NumberFormat('#,###').format(sale?.totalAmount ?? 0)} ກີບ',
        targetId: id,
      );

      if (urls.isNotEmpty) {
        try {
          await CloudinaryService.deleteImages(urls);
        } catch (e) {
          debugPrint('Cloudinary delete error (ignored): $e');
        }
      }

      Get.snackbar('ສຳເລັດ', 'ລຶບລາຍການແລ້ວ',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('deleteSale error: $e');
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  Future<void> confirmPaymentStatus(String id, bool cur) async {
    try {
      await repository.updateSaleStatus(id, !cur);
      await fetchSales();

      // 🔔 ແຈ້ງເຕືອນ
      final s = allSalesList.firstWhereOrNull((x) => x.id == id);
      await _notify(
        type: AppNotificationType.saleConfirm,
        title: 'ຢືນຢັນເງິນເຂົ້າ',
        message: '"${s?.productName ?? "ລາຍການ"}" '
            '${NumberFormat('#,###').format(s?.totalAmount ?? 0)} ກີບ',
        targetId: id,
      );
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດປ່ຽນສະຖານະໄດ້');
    }
  }

  Future<void> markAsMismatch(String id, String note) async {
    try {
      await repository.updateMismatchStatus(id,
          isMismatch: true, mismatchNote: note);
      await fetchSales();

      // 🔔 ແຈ້ງເຕືອນ
      await _notify(
        type: AppNotificationType.saleMismatch,
        title: 'ບັນຊີບໍ່ຕົງ',
        message: 'ເຫດຜົນ: $note',
        targetId: id,
      );

      Get.snackbar('ບັນທຶກ', 'ບັນຊີບໍ່ຕົງກັນແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    }
  }

  Future<void> clearMismatch(String id) async {
    try {
      await repository.updateMismatchStatus(id, isMismatch: false);
      await fetchSales();

      // 🔔 ແຈ້ງເຕືອນ
      await _notify(
        type: AppNotificationType.saleMismatchClear,
        title: 'ຍົກເລີກບັນຊີບໍ່ຕົງ',
        message: 'ກັບສູ່ສະຖານະປົກກະຕິ',
        targetId: id,
      );

      Get.snackbar('ສຳເລັດ', 'ຍົກເລີກສະຖານະແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດຍົກເລີກໄດ້: $e');
    }
  }

  Future<void> updateMismatchNote(String id, String note) async {
    try {
      await repository.updateMismatchStatus(id,
          isMismatch: true, mismatchNote: note);
      await fetchSales();
      Get.snackbar('ສຳເລັດ', 'ອັບເດດໝາຍເຫດແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອັບເດດໄດ້: $e');
    }
  }

  Future<void> payDebt(
    String id, {
    required String paymentType,
    required String imageUrl,
    required double paidAmount,
  }) async {
    try {
      final s = allSalesList.firstWhereOrNull((x) => x.id == id);

      await repository.payDebt(
        id,
        paymentType: paymentType,
        imageUrl: imageUrl,
        paidAmount: paidAmount,
      );
      await fetchSales();

      // 🔔 ແຈ້ງເຕືອນ
      await _notify(
        type: AppNotificationType.debtPaid,
        title: 'ປິດໜີ້ສຳເລັດ',
        message: '"${s?.customerName ?? "ລູກຄ້າ"}" ຈ່າຍ '
            '${NumberFormat('#,###').format(paidAmount)} ກີບ',
        targetId: id,
      );

      Get.snackbar('ສຳເລັດ', 'ປິດໜີ້ · ຮັບເງິນແລ້ວ',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດປິດໜີ້ໄດ້: $e');
      rethrow;
    }
  }

  String formatLaoDate(DateTime date) {
    const days = [
      'ວັນຈັນ', 'ວັນອັງຄານ', 'ວັນພຸດ',
      'ວັນພະຫັດ', 'ວັນສຸກ', 'ວັນເສົາ', 'ວັນອາທິດ',
    ];
    return '${days[date.weekday - 1]} ${DateFormat('dd/MM/yyyy').format(date)}';
  }
}