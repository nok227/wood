import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/core/widgets/shared/custom_app_bar.dart';
import 'package:wood/features/auth/domain/entities/menu_permission.dart';
import 'package:wood/features/wood_products/presentation/pages/form/wood_product_form_page.dart';
import 'package:wood/features/wood_products/presentation/pages/list/wood_product_list_page.dart';
import 'package:wood/features/sales/presentation/pages/list/sales_list_page.dart';
import 'package:wood/features/account/presentation/pages/account_page.dart';

import '../controllers/home_controller.dart';
import '../widgets/keep_alive_page.dart';
import '../widgets/lazy_3d_wrapper.dart';
import '../widgets/loading_page.dart';
import '../widgets/pending_approval_page.dart';
import '../widgets/tab_ticker_gate.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeController());

    return Obx(() {
      if (!ctrl.auth.isAdmin && !ctrl.auth.permissionLoaded.value) {
        return const LoadingPage();
      }
      if (!ctrl.auth.isAdmin && !ctrl.auth.hasAnyPermission) {
        return const PendingApprovalPage();
      }
      if (ctrl.tabs.isEmpty) return const PendingApprovalPage();
      return _scaffold(ctrl);
    });
  }

  Widget _scaffold(HomeController ctrl) {
    return Scaffold(
      backgroundColor: HomeStyle.bg,
      body: Column(
        children: [
          // ── AppBar (hide/show) ──
          Obx(
            () => AnimatedSize(
              duration: HomeStyle.barsAnim,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: ctrl.barsVisible.value
                  ? _appBar(ctrl)
                  : const SizedBox(width: double.infinity),
            ),
          ),

          // ── Body ──
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                ctrl.onScroll(n);
                return false;
              },
              child: Obx(() {
                final on3D =
                    ctrl.currentIndex.value < ctrl.tabs.length &&
                    ctrl.tabs[ctrl.currentIndex.value].key == MenuKey.wood3d;
                final lock = ctrl.lockSwipe.value && on3D;
                return PageView(
                  controller: ctrl.pageController,
                  physics: lock
                      ? const NeverScrollableScrollPhysics()
                      : const ClampingScrollPhysics(),
                  onPageChanged: ctrl.onPageChanged,
                  children: [
                    for (int i = 0; i < ctrl.tabs.length; i++)
                      RepaintBoundary(
                        key: ValueKey('tab-${ctrl.tabs[i].key.key}'),
                        child: _pageFor(ctrl.tabs[i].key, i, ctrl),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Obx(
        () => AnimatedSize(
          duration: HomeStyle.barsAnim,
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: ctrl.barsVisible.value
              ? _bottomNav(ctrl)
              : const SizedBox(width: double.infinity),
        ),
      ),
    );
  }

  Widget _appBar(HomeController ctrl) {
    return Obx(() {
      final safe = ctrl.titleIndex.value.clamp(0, ctrl.tabs.length - 1);
      return CustomAppBar(title: ctrl.tabs[safe].title);
    });
  }

  Widget _bottomNav(HomeController ctrl) {
    return Obx(() {
      final safe = ctrl.currentIndex.value.clamp(0, ctrl.tabs.length - 1);
      return BottomNavigationBar(
        currentIndex: safe,
        selectedItemColor: HomeStyle.navSelected,
        unselectedItemColor: HomeStyle.navUnselected,
        selectedIconTheme: const IconThemeData(size: HomeStyle.navIconSelected),
        unselectedIconTheme: const IconThemeData(
          size: HomeStyle.navIconUnselected,
        ),
        selectedFontSize: HomeStyle.navFontSelected,
        unselectedFontSize: HomeStyle.navFontUnselected,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          ctrl.setTab(i);
          final distance = (i - ctrl.currentIndex.value).abs();
          if (distance == 1) {
            ctrl.pageController.animateToPage(
              i,
              duration: HomeStyle.pageSlide,
              curve: Curves.easeOutCubic,
            );
          } else {
            ctrl.pageController.jumpToPage(i);
          }
        },
        items: ctrl.tabs.map((t) {
          final def = MenuKey.values.firstWhere((m) => m.key == t.key.key);
          return BottomNavigationBarItem(icon: Icon(def.icon), label: t.label);
        }).toList(),
      );
    });
  }

  Widget _pageFor(MenuKey key, int i, HomeController ctrl) {
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
      currentIndex: ctrl.currentIndex,
      child: page,
    );
  }
}