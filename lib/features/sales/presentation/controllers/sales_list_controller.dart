import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

import '../../domain/entities/sale_order_entity.dart';
import 'sales_controller.dart';

class SalesListController extends GetxController {
  final sales = Get.find<SalesController>();
  final scrollCtrl = ScrollController();

  final displayLimit = SaleStyle.perPage.obs;
  final isFabOpen = false.obs;
  final isLoadingMore = false.obs;

  int _cachedRevision = -1;
  DateFilter? _cachedFilter;
  Map<String, List<SaleOrderEntity>> _cachedGroup = const {};
  List<String> _cachedKeys = const [];

  @override
  void onInit() {
    super.onInit();
    scrollCtrl.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollCtrl.removeListener(_onScroll);
    scrollCtrl.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════
  // Scroll → load more
  // ══════════════════════════════════════════
  void _onScroll() {
    if (!scrollCtrl.hasClients) return;
    final pos = scrollCtrl.position;
    if (pos.pixels >=
            pos.maxScrollExtent - SaleStyle.scrollLoadMoreThreshold &&
        !isLoadingMore.value) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    isLoadingMore.value = true;
    await Future.delayed(SaleStyle.debounce);
    if (isClosed) return;
    displayLimit.value += SaleStyle.perPage;
    isLoadingMore.value = false;
  }

  void resetLimit() => displayLimit.value = SaleStyle.perPage;

  // ══════════════════════════════════════════
  // FAB
  // ══════════════════════════════════════════
  void toggleFab() => isFabOpen.toggle();
  void closeFab() => isFabOpen.value = false;

  // ══════════════════════════════════════════
  // Group by date
  // ══════════════════════════════════════════
  Map<String, List<SaleOrderEntity>> groupByDate(
    List<SaleOrderEntity> source,
    DateFilter filter,
    int revision,
  ) {
    if (_cachedRevision == revision && _cachedFilter == filter) {
      return _cachedGroup;
    }
    _cachedRevision = revision;
    _cachedFilter = filter;

    final map = <String, List<SaleOrderEntity>>{};
    for (final sale in source) {
      final d = sale.date;
      final k =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(k, () => []).add(sale);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    _cachedGroup = {for (final k in keys) k: map[k]!};
    _cachedKeys = keys;
    return _cachedGroup;
  }

  List<String> get cachedKeys => _cachedKeys;

  // ══════════════════════════════════════════
  // Format date header
  // ══════════════════════════════════════════
  String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    const days = [
      'ວັນອາທິດ',
      'ວັນຈັນ',
      'ວັນອັງຄານ',
      'ວັນພຸດ',
      'ວັນພະຫັດ',
      'ວັນສຸກ',
      'ວັນເສົາ',
    ];
    final dayName = days[date.weekday % 7];
    final fmtDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (target == today) return 'ມື້ນີ້ ($dayName, $fmtDate)';
    if (target == yesterday) return 'ມື້ວານນີ້ ($dayName, $fmtDate)';
    return '$dayName, $fmtDate';
  }
}