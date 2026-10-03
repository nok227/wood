import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/widgets/custom_app_bar.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/domain/entities/menu_permission.dart';
import 'package:wood/features/wood_products/presentation/pages/form/wood_product_form_page.dart';
import 'package:wood/features/wood_products/presentation/pages/list/wood_product_list_page.dart';
import 'package:wood/features/sales/presentation/pages/list/sales_list_page.dart';
import 'package:wood/features/account/presentation/pages/account_page.dart';

import '../controllers/home_controller.dart';
import '../widgets/loading_page.dart';
import '../widgets/pending_approval_page.dart';
import '../widgets/tab_ticker_gate.dart';
import '../widgets/lazy_3d_wrapper.dart';
import '../widgets/keep_alive_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final HomeController ctrl;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(HomeController());
    _pageController = PageController(initialPage: ctrl.indexNotifier.value);
    ctrl.tabs.listen((_) => _rebuildController());
  }

  void _rebuildController() {
    if (!mounted) return;
    if (ctrl.tabs.isEmpty) return;
    final newIdx =
        ctrl.indexNotifier.value.clamp(0, ctrl.tabs.length - 1);
    final old = _pageController;
    _pageController = PageController(initialPage: newIdx);
    ctrl.indexNotifier.value = newIdx;
    ctrl.titleIndexNotifier.value = newIdx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        old.dispose();
      } catch (_) {}
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _pageFor(MenuKey key, int i) {
    Widget page;
    switch (key) {
      case MenuKey.woodForm:
        page = const WoodProductFormPage();
        break;
      case MenuKey.woodList:
        page = const WoodProductListPage();
        break;
      case MenuKey.salesList:
        page = const KeepAlivePage(child: SalesListPage());
        break;
      case MenuKey.account:
        page = const KeepAlivePage(child: AccountPage());
        break;
      case MenuKey.wood3d:
        page = Lazy3DWrapper(swipeLock: ctrl.lockSwipe);
        break;
    }
    return TabTickerGate(
      index: i,
      currentIndex: ctrl.indexNotifier,
      child: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ctrl.auth.isAdmin && !ctrl.auth.permissionLoaded.value) {
        return const LoadingPage();
      }
      if (!ctrl.auth.isAdmin && !ctrl.auth.hasAnyPermission) {
        return const PendingApprovalPage();
      }
      if (ctrl.tabs.isEmpty) return const PendingApprovalPage();
      return _scaffold();
    });
  }

  Widget _scaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: ctrl.barsVisible,
            builder: (_, v, child) => AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: v ? child! : const SizedBox(width: double.infinity),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: ctrl.titleIndexNotifier,
              builder: (_, idx, __) {
                final safe = idx.clamp(0, ctrl.tabs.length - 1);
                return CustomAppBar(title: ctrl.tabs[safe].title);
              },
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                ctrl.onScroll(n);
                return false;
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: ctrl.lockSwipe,
                builder: (_, locked, __) {
                  final on3D = ctrl.indexNotifier.value >= 0 &&
                      ctrl.indexNotifier.value < ctrl.tabs.length &&
                      ctrl.tabs[ctrl.indexNotifier.value].key ==
                          MenuKey.wood3d;
                  final lock = locked && on3D;
                  return PageView(
                    controller: _pageController,
                    physics: lock
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    onPageChanged: ctrl.onPageChanged,
                    children: [
                      for (int i = 0; i < ctrl.tabs.length; i++)
                        RepaintBoundary(
                          key: ValueKey('tab-${ctrl.tabs[i].key.key}'),
                          child: _pageFor(ctrl.tabs[i].key, i),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: ctrl.barsVisible,
        builder: (_, v, child) => AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: v ? child! : const SizedBox(width: double.infinity),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: ctrl.indexNotifier,
          builder: (_, idx, __) {
            final safe = idx.clamp(0, ctrl.tabs.length - 1);
            return BottomNavigationBar(
              currentIndex: safe,
              selectedItemColor: Colors.brown,
              unselectedItemColor: Colors.grey,
              selectedIconTheme: const IconThemeData(size: 26),
              unselectedIconTheme: const IconThemeData(size: 22),
              selectedFontSize: 12,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              onTap: (i) {
                ctrl.setTab(i);
                final distance = (i - ctrl.indexNotifier.value).abs();
                if (distance == 1) {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                  );
                } else {
                  _pageController.jumpToPage(i);
                }
              },
              items: ctrl.tabs.map((t) {
                final def =
                    MenuKey.values.firstWhere((m) => m.key == t.key.key);
                return BottomNavigationBarItem(
                  icon: Icon(def.icon),
                  label: t.label,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}