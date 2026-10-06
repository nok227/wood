import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/utils/page_route_notifier.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/domain/entities/menu_permission.dart';

class TabDef {
  final MenuKey key;
  final String title;
  final String label;
  const TabDef({required this.key, required this.title, required this.label});
}

class HomeController extends GetxController {
  final AuthController auth = Get.find<AuthController>();

  static int? _lastTabIndex;
  int? get lastTabIndex => _lastTabIndex;

  final ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> lockSwipe = ValueNotifier<bool>(false);
  final ValueNotifier<int> titleIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> barsVisible = ValueNotifier<bool>(true);

  final tabs = <TabDef>[].obs;

  Timer? _bumpTimer;
  Timer? _titleDebounce;

  @override
  void onInit() {
    super.onInit();
    _rebuildTabs();

    // ⭐ เปลี่ยน: listen currentUser แทน allowedMenus
    auth.currentUser.listen((_) => _rebuildTabs());

    final fallback = auth.isAdmin ? 1 : 0;
    final initial = (_lastTabIndex != null &&
            _lastTabIndex! >= 0 &&
            _lastTabIndex! < tabs.length)
        ? _lastTabIndex!
        : (tabs.isEmpty ? 0 : fallback.clamp(0, tabs.length - 1));
    indexNotifier.value = initial;
    titleIndexNotifier.value = initial;
    _lastTabIndex = initial;
  }

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
  }

  void setTab(int index) {
    if (indexNotifier.value == index) return;
    if (index < 0 || index >= tabs.length) return;
    _lastTabIndex = index;
    if (!barsVisible.value) barsVisible.value = true;
  }

  void onPageChanged(int i) {
    indexNotifier.value = i;
    _lastTabIndex = i;
    _scheduleBump();
    if (!barsVisible.value) barsVisible.value = true;
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 120), () {
      titleIndexNotifier.value = i;
    });
  }

  void _scheduleBump() {
    _bumpTimer?.cancel();
    _bumpTimer = Timer(const Duration(milliseconds: 280), () {
      PageRouteNotifier.instance.bump();
    });
  }

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
    indexNotifier.dispose();
    titleIndexNotifier.dispose();
    lockSwipe.dispose();
    barsVisible.dispose();
    super.onClose();
  }
}