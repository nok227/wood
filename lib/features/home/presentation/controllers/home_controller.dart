import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/utils/page_route_notifier.dart';
import 'package:wood/features/auth/domain/entities/menu_permission.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';

class TabDef {
  final MenuKey key;
  final String title;
  final String label;
  const TabDef({required this.key, required this.title, required this.label});
}

class HomeController extends GetxController {
  final AuthController auth = Get.find<AuthController>();

  // ══════════════════════════════════════════
  // State
  // ══════════════════════════════════════════
  final tabs = <TabDef>[].obs;
  final currentIndex = 0.obs;
  final titleIndex = 0.obs;
  final barsVisible = true.obs;
  final lockSwipe = false.obs;

  // ⭐ flag: พร้อม render หรือยัง
  final isReady = false.obs;

  // ⭐ PageController nullable — สร้างเมื่อพร้อม
  PageController? _pageController;
  PageController get pageController => _pageController!;

  bool _initialTabSet = false;

  // ⭐ flag: ระหว่าง programmatic animation → block onPageChanged
  bool _isAnimating = false;

  Timer? _bumpTimer;
  Timer? _titleDebounce;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();

    _rebuildTabs();
    _authWorker = ever(auth.currentUser, (_) => _rebuildTabs());
  }

  // ══════════════════════════════════════════
  // Tabs
  // ══════════════════════════════════════════
  void _rebuildTabs() {
    final all = <TabDef>[
      const TabDef(
        key: MenuKey.woodForm,
        title: 'ເພີ່ມໄມ້ໃໝ່',
        label: 'ເພີ່ມໄມ້',
      ),
      const TabDef(
        key: MenuKey.woodList,
        title: 'ລາຍການໄມ້ໃນຄັງ',
        label: 'ລາຍການໄມ້',
      ),
      const TabDef(
        key: MenuKey.salesList,
        title: 'ລາຍການຂາຍ',
        label: 'ການຂາຍ',
      ),
      const TabDef(
        key: MenuKey.account,
        title: 'ບັນຊີ ລາຍຮັບ-ລາຍຈ່າຍ',
        label: 'ບັນຊີ',
      ),
      const TabDef(
        key: MenuKey.wood3d,
        title: 'ໂມເດວ 3D ທຽບໄມ້ໃນຄັງ',
        label: 'ໂມເດວ 3D',
      ),
    ];
    final filtered = all.where((t) => auth.canAccess(t.key)).toList();
    tabs.assignAll(filtered);

    if (tabs.isEmpty) return;

    // ⭐ ครั้งแรก — สร้าง PageController ด้วย initialPage ที่ถูกต้อง
    if (!_initialTabSet) {
      _initialTabSet = true;
      final idx = _computeDefaultIndex();

      currentIndex.value = idx;
      titleIndex.value = idx;

      _pageController?.dispose();
      _pageController = PageController(initialPage: idx);
      isReady.value = true;
      return;
    }

    // Rebuild ครั้งต่อ ๆ ไป (auth เปลี่ยน) → clamp กัน
    final safe = currentIndex.value.clamp(0, tabs.length - 1);
    if (safe != currentIndex.value) {
      currentIndex.value = safe;
      titleIndex.value = safe;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed && (_pageController?.hasClients ?? false)) {
          _pageController!.jumpToPage(safe);
        }
      });
    }
  }

  /// 🎯 Default = ລາຍການໄມ້ (ທັງ admin ແລະ user)
  int _computeDefaultIndex() {
    if (tabs.isEmpty) return 0;
    final i = tabs.indexWhere((t) => t.key == MenuKey.woodList);
    return i >= 0 ? i : 0;
  }

  // ══════════════════════════════════════════
  // User actions
  // ══════════════════════════════════════════
  void setTab(int index) {
    if (currentIndex.value == index) return;
    if (index < 0 || index >= tabs.length) return;
    if (!barsVisible.value) barsVisible.value = true;
  }

  void onPageChanged(int i) {
    // ⭐ ข้ามถ้ากำลัง programmatic animate → กัน nav/title กระตุก
    if (_isAnimating) return;

    currentIndex.value = i;
    _scheduleBump();
    if (!barsVisible.value) barsVisible.value = true;

    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 120), () {
      titleIndex.value = i;
    });
  }

  void _scheduleBump() {
    _bumpTimer?.cancel();
    _bumpTimer = Timer(const Duration(milliseconds: 280), () {
      PageRouteNotifier.instance.bump();
    });
  }

  // ══════════════════════════════════════════
  // Scroll → hide/show bars
  // ══════════════════════════════════════════
  void onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return;

    if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0;
      final pixels = n.metrics.pixels;

      if (pixels <= 20) {
        if (!barsVisible.value) barsVisible.value = true;
        return;
      }
      if (delta > 6 && barsVisible.value) {
        barsVisible.value = false;
      } else if (delta < -6 && !barsVisible.value) {
        barsVisible.value = true;
      }
    } else if (n is ScrollEndNotification) {
      if (n.metrics.pixels <= 20 && !barsVisible.value) {
        barsVisible.value = true;
      }
    }
  }

  @override
  void onClose() {
    _bumpTimer?.cancel();
    _titleDebounce?.cancel();
    _authWorker?.dispose();
    _pageController?.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════
  // 🎯 goToTab — เปลี่ยน tab ด้วย MenuKey
  //    distance == 1 → animate
  //    distance >  1 → jump (ไม่ scroll ผ่าน pages กลาง)
  // ══════════════════════════════════════════
  void goToTab(MenuKey key) {
    final idx = tabs.indexWhere((t) => t.key == key);
    if (idx < 0) return;
    if (currentIndex.value == idx) return;
    if (idx >= tabs.length) return;

    final distance = (idx - currentIndex.value).abs();

    // set ทันที → nav + title sync
    currentIndex.value = idx;
    titleIndex.value = idx;
    if (!barsVisible.value) barsVisible.value = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isClosed || !(_pageController?.hasClients ?? false)) return;

      if (distance == 1) {
        // ⭐ ข้ามใกล้ → animate นุ่มนวล + block onPageChanged
        _isAnimating = true;
        try {
          await _pageController!.animateToPage(
            idx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } finally {
          _isAnimating = false;
        }
      } else {
        // ⭐ ข้ามไกล → jump ทันที (ไม่ scroll ผ่าน pages กลาง)
        _pageController!.jumpToPage(idx);
      }
    });
  }
}