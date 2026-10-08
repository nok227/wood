import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/wood_3d_style.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';

class Wood3DController extends GetxController {
  final ValueNotifier<bool>? swipeLock;
  Wood3DController({this.swipeLock});

  final WoodProductController products = Get.find<WoodProductController>();

  // ══════════════════════════════════════════
  // State
  // ══════════════════════════════════════════
  final selectedWoodType = Wood3DStyle.allFilter.obs;
  final selectedUnitFilter = Wood3DStyle.allFilter.obs;
  final selectedName = Rxn<String>();
  final selectedVariant = Rxn<WoodProduct>();
  final focusedDimension = Rxn<String>();
  final showColor = false.obs;
  final panelExpanded = true.obs;

  // ══════════════════════════════════════════
  // Computed (แสดงผลจาก cache)
  // ══════════════════════════════════════════
  final filteredProducts = <WoodProduct>[].obs;
  final woodTypeOptions = <String>[Wood3DStyle.allFilter].obs;
  final unitOptions = <String>[Wood3DStyle.allFilter].obs;
  final names = <String>[].obs;
  final variants = <WoodProduct>[].obs;

  // ─── Cache tracker ───
  int _cachedRevision = -1;
  String _cachedWoodType = '__none__';
  String _cachedUnitFilter = '__none__';
  String? _cachedSelectedName;

  bool? _lastLockValue;

  bool get hasSelection => selectedVariant.value != null;

  bool get hasAnyChoice =>
      selectedWoodType.value != Wood3DStyle.allFilter ||
      selectedUnitFilter.value != Wood3DStyle.allFilter ||
      selectedName.value != null ||
      selectedVariant.value != null;

  // ══════════════════════════════════════════
  // Init
  // ══════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    ever(products.productsRevision, (_) => recomputeIfNeeded());
    recomputeIfNeeded();
  }

  // ══════════════════════════════════════════
  // Recompute
  // ══════════════════════════════════════════
  void recomputeIfNeeded() {
    final all = products.products.toList();
    final revision = products.productsRevision.value;

    final changed =
        revision != _cachedRevision ||
        _cachedWoodType != selectedWoodType.value ||
        _cachedUnitFilter != selectedUnitFilter.value ||
        _cachedSelectedName != selectedName.value;

    if (!changed) return;

    _cachedRevision = revision;
    _cachedWoodType = selectedWoodType.value;
    _cachedUnitFilter = selectedUnitFilter.value;
    _cachedSelectedName = selectedName.value;

    final byUnitOnly = selectedUnitFilter.value == Wood3DStyle.allFilter
        ? all
        : all.where((p) => p.unit.contains(selectedUnitFilter.value)).toList();

    final byTypeOnly = selectedWoodType.value == Wood3DStyle.allFilter
        ? all
        : all
              .where((p) => p.woodType.trim() == selectedWoodType.value)
              .toList();

    final byBoth = all.where((p) {
      if (selectedWoodType.value != Wood3DStyle.allFilter &&
          p.woodType.trim() != selectedWoodType.value) {
        return false;
      }
      if (selectedUnitFilter.value != Wood3DStyle.allFilter &&
          !p.unit.contains(selectedUnitFilter.value)) {
        return false;
      }
      return true;
    }).toList();

    // Type options
    final typeSet =
        byUnitOnly
            .map((p) => p.woodType.trim())
            .where((t) => t.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    woodTypeOptions.assignAll([Wood3DStyle.allFilter, ...typeSet]);

    // Unit options
    final unitSet = byTypeOnly
        .map((p) => p.unit.trim())
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();
    if (unitSet.any((u) => u.contains('ວົງ')) && !unitSet.contains('ວົງ')) {
      unitSet.add('ວົງ');
    }
    unitSet.sort((a, b) => a.length.compareTo(b.length));
    unitOptions.assignAll([Wood3DStyle.allFilter, ...unitSet]);

    // Reset ถ้าเลือกตัวที่ไม่มีในรายการ
    if (selectedWoodType.value != Wood3DStyle.allFilter &&
        !woodTypeOptions.contains(selectedWoodType.value)) {
      selectedWoodType.value = Wood3DStyle.allFilter;
      _cachedWoodType = Wood3DStyle.allFilter;
    }
    if (selectedUnitFilter.value != Wood3DStyle.allFilter &&
        !unitOptions.contains(selectedUnitFilter.value)) {
      selectedUnitFilter.value = Wood3DStyle.allFilter;
      _cachedUnitFilter = Wood3DStyle.allFilter;
    }

    filteredProducts.assignAll(byBoth);
    names.assignAll(
      byBoth
          .map((p) => p.name.trim()) // ← เพิ่ม .trim()
          .where((n) => n.isNotEmpty) // ← กรองค่าว่าง
          .toSet()
          .toList()
        ..sort(),
    );

    if (selectedName.value != null && !names.contains(selectedName.value)) {
      selectedName.value = null;
      selectedVariant.value = null;
      _cachedSelectedName = null;
    }

    if (selectedName.value == null) {
      variants.clear();
      selectedVariant.value = null;
    } else {
final list = filteredProducts
    .where((p) => p.name.trim() == selectedName.value)   // ← เพิ่ม .trim()
    .toList();
      variants.assignAll(list);

      if (list.isEmpty) {
        selectedVariant.value = null;
      } else {
        final matched = list.where((v) => v.id == selectedVariant.value?.id);
        selectedVariant.value = matched.isNotEmpty ? matched.first : list.first;
      }
    }
  }

  // ══════════════════════════════════════════
  // Actions
  // ══════════════════════════════════════════
  void pickWoodType(String v) {
    selectedWoodType.value = v;
    selectedName.value = null;
    selectedVariant.value = null;
    focusedDimension.value = null;
    recomputeIfNeeded();
  }

  void pickUnit(String v) {
    selectedUnitFilter.value = v;
    selectedName.value = null;
    selectedVariant.value = null;
    focusedDimension.value = null;
    recomputeIfNeeded();
  }

  void pickName(String? v) {
    selectedName.value = v;
    focusedDimension.value = null;
    recomputeIfNeeded();
  }

  void pickVariant(WoodProduct v) {
    selectedVariant.value = v;
    focusedDimension.value = null;
  }

  void focusDimension(String? v) {
    focusedDimension.value = v;
  }

  void toggleColor() => showColor.toggle();

  void togglePanel() => panelExpanded.toggle();

  void clearAll() {
    selectedWoodType.value = Wood3DStyle.allFilter;
    selectedUnitFilter.value = Wood3DStyle.allFilter;
    selectedName.value = null;
    selectedVariant.value = null;
    focusedDimension.value = null;
    _cachedWoodType = '__none__';
    _cachedUnitFilter = '__none__';
    _cachedSelectedName = null;
    recomputeIfNeeded();
  }

  // ══════════════════════════════════════════
  // Swipe lock sync (เรียกจาก build)
  // ══════════════════════════════════════════
  void syncSwipeLock() {
    final lock = swipeLock;
    if (lock == null) return;
    final wanted = hasAnyChoice;
    if (lock.value == wanted) {
      _lastLockValue = wanted;
      return;
    }
    if (_lastLockValue == wanted) return;
    _lastLockValue = wanted;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = swipeLock;
      if (l != null && l.value != wanted) l.value = wanted;
    });
  }
}
