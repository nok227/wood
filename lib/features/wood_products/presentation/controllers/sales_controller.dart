import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
import 'package:wood/features/wood_products/domain/entities/app_notification.dart';
import 'package:wood/features/wood_products/presentation/controllers/notification_controller.dart';
import '../../domain/entities/sale_order_entity.dart';
import '../../domain/repositories/sales_repository.dart';

enum DateFilter { today, week, month, year, all }

class SalesController extends GetxController {
  final SalesRepository repository;
  SalesController({required this.repository});

  final fmt = NumberFormat('#,###');

  var allSalesList = <SaleOrderEntity>[].obs;
  var filteredSalesList = <SaleOrderEntity>[].obs;
  var isLoading = false.obs;
  var selectedFilter = DateFilter.today.obs;

  final salesRevision = 0.obs;

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

  String _productLabel(SaleOrderEntity sale) =>
      sale.shortSummary.trim().isNotEmpty ? sale.shortSummary : 'ລາຍການໄມ້';

  String _customerLabel(SaleOrderEntity sale) {
    final c = (sale.customerName ?? '').trim();
    return c.isEmpty ? 'ລູກຄ້າ' : c;
  }

  String _paymentLabel(String type) {
    switch (type) {
      case 'cash':
        return 'ສົດ';
      case 'transfer':
        return 'ໂອນ';
      case 'mixed':
        return 'ປະສົມ';
      case 'debt':
        return 'ຕິດໜີ້';
      default:
        return type;
    }
  }

  Future<void> fetchSales() async {
    isLoading.value = true;
    try {
      final sales = await repository.getSaleOrders();
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

    salesRevision.value++;
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

  Future<void> notifyNewSale(SaleOrderEntity sale) async {
    final name = _productLabel(sale);
    final itemInfo = sale.hasMultiItems ? ' · ${sale.itemCount} ລາຍການ' : '';

    if (sale.hasDebt) {
      final customer = _customerLabel(sale);
      final paidBefore = sale.receivedAmount;

      if (paidBefore > 0) {
        await _notify(
          type: AppNotificationType.saleDebtAdd,
          title: 'ຂາຍຕິດໜີ້ · ຈ່າຍກ່ອນ',
          message: '"$name"$itemInfo ລວມ ${fmt.format(sale.totalAmount)} ກີບ\n'
              'ຈ່າຍກ່ອນ ${fmt.format(paidBefore)} · ຕິດໜີ້ ${fmt.format(sale.debtAmount)} ກີບ\n'
              'ລູກຄ້າ: $customer',
          targetId: sale.id,
        );
      } else {
        await _notify(
          type: AppNotificationType.saleDebtAdd,
          title: 'ຂາຍຕິດໜີ້',
          message: '"$name"$itemInfo ຍອດ ${fmt.format(sale.debtAmount)} ກີບ\n'
              'ລູກຄ້າ: $customer',
          targetId: sale.id,
        );
      }
      return;
    }

    if (sale.isMixed) {
      await _notify(
        type: AppNotificationType.saleAdd,
        title: 'ຂາຍປະສົມ',
        message: '"$name"$itemInfo ລວມ ${fmt.format(sale.totalAmount)} ກີບ\n'
            'ສົດ ${fmt.format(sale.cashPaidAmount)} + ໂອນ ${fmt.format(sale.transferPaidAmount)}'
            '${sale.changeAmount > 0 ? " · ທອນ ${fmt.format(sale.changeAmount)} ກີບ" : ""}',
        targetId: sale.id,
      );
      return;
    }

    final isCash = sale.paymentType == 'cash';
    final extra = StringBuffer();
    if (sale.changeAmount > 0) {
      extra.write(' · ທອນ ${fmt.format(sale.changeAmount)} ກີບ');
    }
    if (sale.hasMultiItems) {
      extra.write(' · ${sale.itemCount} ລາຍການ');
    }

    await _notify(
      type: AppNotificationType.saleAdd,
      title: isCash ? 'ຂາຍເງິນສົດ' : 'ຂາຍເງິນໂອນ',
      message: '"$name" ${fmt.format(sale.totalAmount)} ກີບ$extra',
      targetId: sale.id,
    );
  }

  Future<void> addOrder(SaleOrderEntity order) async {
    await repository.addSaleOrder(order);
    await fetchSales();
  }

  Future<void> deleteSale(String id) async {
    try {
      final sale = allSalesList.firstWhereOrNull((s) => s.id == id);
      final urls = <String>[
        ...?sale?.paymentImageUrls,
        ...?sale?.billImageUrls,
        ...?sale?.topUpImageUrls,
        ...?sale?.debtPaymentImageUrls, 
      ].where((u) => u.isNotEmpty).toList();

      await repository.deleteSale(id);
      allSalesList.removeWhere((s) => s.id == id);
      applyDateFilter(selectedFilter.value);

      final name = sale == null
          ? 'ລາຍການ'
          : (sale.shortSummary.trim().isNotEmpty
              ? sale.shortSummary
              : 'ລາຍການໄມ້');

      String status = '';
      if (sale != null) {
        if (sale.isMismatch) {
          status = ' (ບັນຊີບໍ່ຕົງ)';
        } else if (sale.hasDebt) {
          status = ' (ຕິດໜີ້ ${fmt.format(sale.debtAmount)} ກີບ)';
        } else if (sale.isConfirmed) {
          status = ' (ເງິນເຂົ້າແລ້ວ)';
        } else {
          status = ' (ລໍຖ້າກວດສອບ)';
        }
      }

      await _notify(
        type: AppNotificationType.saleDelete,
        title: 'ລຶບລາຍການຂາຍ',
        message: '"$name" '
            '${fmt.format(sale?.totalAmount ?? 0)} ກີບ$status',
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
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      debugPrint('deleteSale error: $e');
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  Future<void> confirmPaymentStatus(String id, bool cur) async {
    try {
      await repository.updateSaleStatus(id, !cur);
      await fetchSales();

      final s = allSalesList.firstWhereOrNull((x) => x.id == id);
      final name = s == null ? 'ລາຍການ' : _productLabel(s);
      final payment = s == null ? '' : _paymentLabel(s.paymentType);

      await _notify(
        type: AppNotificationType.saleConfirm,
        title: 'ຢືນຢັນເງິນເຂົ້າ',
        message: '"$name" '
            '${fmt.format(s?.totalAmount ?? 0)} ກີບ'
            '${payment.isNotEmpty ? " · $payment" : ""}',
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

      final s = allSalesList.firstWhereOrNull((x) => x.id == id);
      final name = s == null ? 'ລາຍການ' : _productLabel(s);

      await _notify(
        type: AppNotificationType.saleMismatch,
        title: 'ບັນຊີບໍ່ຕົງ',
        message: '"$name" · ${fmt.format(s?.totalAmount ?? 0)} ກີບ\n'
            'ເຫດຜົນ: $note',
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

      final s = allSalesList.firstWhereOrNull((x) => x.id == id);
      final name = s == null ? 'ລາຍການ' : _productLabel(s);

      await _notify(
        type: AppNotificationType.saleMismatchClear,
        title: 'ແກ້ໄຂບັນຊີບໍ່ຕົງ',
        message: '"$name" ກັບສູ່ສະຖານະປົກກະຕິ',
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
      final customer = s == null ? 'ລູກຄ້າ' : _customerLabel(s);

      await repository.payDebt(
        id,
        paymentType: paymentType,
        imageUrl: imageUrl,
        paidAmount: paidAmount,
      );
      await fetchSales();

      final updated = allSalesList.firstWhereOrNull((x) => x.id == id);
      final remaining = updated?.debtAmount ?? 0;
      final payment = _paymentLabel(paymentType);

      if (remaining > 0) {
        await _notify(
          type: AppNotificationType.debtPartial,
          title: 'ຈ່າຍໜີ້ບາງສ່ວນ',
          message:
              '$customer ຈ່າຍ ${fmt.format(paidAmount)} ກີບ ($payment)\n'
              'ຍັງເຫຼືອ ${fmt.format(remaining)} ກີບ',
          targetId: id,
        );
      } else {
        await _notify(
          type: AppNotificationType.debtPaid,
          title: 'ປິດໜີ້ສຳເລັດ',
          message: '$customer ຈ່າຍ ${fmt.format(paidAmount)} ກີບ ($payment)',
          targetId: id,
        );
      }

      Get.snackbar('ສຳເລັດ', 'ປິດໜີ້ · ຮັບເງິນແລ້ວ',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດປິດໜີ້ໄດ້: $e');
      rethrow;
    }
  }

  Future<void> updateSaleImages(
    String id, {
    required List<String> paymentImageUrls,
    required List<String> billImageUrls,
    required List<String> topUpImageUrls,
  }) async {
    try {
      await repository.updateSaleImages(
        id,
        paymentImageUrls: paymentImageUrls,
        billImageUrls: billImageUrls,
        topUpImageUrls: topUpImageUrls,
      );
      await fetchSales();

      final s = allSalesList.firstWhereOrNull((x) => x.id == id);
      final name = s == null ? 'ລາຍການ' : _productLabel(s);

      await _notify(
        type: AppNotificationType.saleConfirm,
        title: 'ແກ້ໄຂຮູບພາບ',
        message: '"$name" · ອັບເດດຮູບຮຽບຮ້ອຍ',
        targetId: id,
      );
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດແກ້ໄຂຮູບໄດ້: $e');
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