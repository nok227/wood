import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/util/page_route_notifier.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/auth/menu_permission.dart';
import 'package:wood/features/auth/register_page.dart';
import '../widgets/custom_app_bar.dart';
import 'wood_product_form_page.dart';
import 'wood_product_list_page.dart';
import 'wood_3d_page.dart';
import 'sales_list_page.dart';
import 'account_page.dart';

class _TabDef {
  final MenuKey key;
  final String title;
  final String label;
  final IconData icon;

  const _TabDef({
    required this.key,
    required this.title,
    required this.label,
    required this.icon,
  });
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static int? _lastTabIndex;

  late final AuthController _auth;
  late PageController _pageController;
  late List<_TabDef> _currentTabs;
  late List<Widget> _currentPages;

  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _lockSwipe = ValueNotifier<bool>(false);
  final ValueNotifier<int> _titleIndexNotifier = ValueNotifier<int>(0);

  // 🆕 ຄຸມການເຊື່ອງ AppBar + BottomNav
  final ValueNotifier<bool> _barsVisible = ValueNotifier<bool>(true);
  double _lastScrollPixels = 0;

  Timer? _titleDebounce;
  Timer? _bumpTimer;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();

    _currentTabs = _buildTabs();
    _currentPages = _buildPages(_currentTabs);

    final fallback = _auth.isAdmin ? 1 : 0;
    final initial =
        (_lastTabIndex != null &&
            _lastTabIndex! >= 0 &&
            _lastTabIndex! < _currentTabs.length)
        ? _lastTabIndex!
        : _currentTabs.isEmpty
        ? 0
        : fallback.clamp(0, _currentTabs.length - 1);

    _indexNotifier.value = initial;
    _titleIndexNotifier.value = initial;
    _pageController = PageController(initialPage: initial);

    _auth.allowedMenus.listen((_) => _onPermissionsChanged());

    WidgetsBinding.instance.addPostFrameCallback((_) => _preWarm());
  }

  List<_TabDef> _buildTabs() {
    final all = <_TabDef>[
      const _TabDef(
        key: MenuKey.woodForm,
        title: 'ເພີ່ມໄມ້ໃໝ່',
        label: 'ເພີ່ມໄມ້',
        icon: Icons.add_box_outlined,
      ),
      const _TabDef(
        key: MenuKey.woodList,
        title: 'ລາຍການໄມ້ໃນຄັງ',
        label: 'ລາຍການໄມ້',
        icon: Icons.inventory_2_outlined,
      ),
      const _TabDef(
        key: MenuKey.salesList,
        title: 'ລາຍການຂາຍ',
        label: 'ການຂາຍ',
        icon: Icons.point_of_sale_outlined,
      ),
      const _TabDef(
        key: MenuKey.account,
        title: 'ບັນຊີ ລາຍຮັບ-ລາຍຈ່າຍ',
        label: 'ບັນຊີ',
        icon: Icons.account_balance_wallet_outlined,
      ),
      const _TabDef(
        key: MenuKey.wood3d,
        title: 'ໂມເດວ 3D ທຽບໄມ້ໃນຄັງ',
        label: 'ໂມເດວ 3D',
        icon: Icons.view_in_ar_rounded,
      ),
    ];
    return all.where((t) => _auth.canAccess(t.key)).toList();
  }

  List<Widget> _buildPages(List<_TabDef> tabs) {
    return List.generate(tabs.length, (i) {
      final t = tabs[i];
      Widget page;
      switch (t.key) {
        case MenuKey.woodForm:
          page = const WoodProductFormPage();
          break;
        case MenuKey.woodList:
          page = const WoodProductListPage();
          break;
        case MenuKey.salesList:
          page = const _KeepAlivePage(child: SalesListPage());
          break;
        case MenuKey.account:
          page = const _KeepAlivePage(child: AccountPage());
          break;
        case MenuKey.wood3d:
          page = _Lazy3DWrapper(swipeLock: _lockSwipe);
          break;
      }
      return _gate(
        i,
        RepaintBoundary(key: ValueKey('tab-${t.key.key}'), child: page),
      );
    });
  }

  Widget _gate(int index, Widget child) {
    return _TabTickerGate(
      index: index,
      currentIndex: _indexNotifier,
      child: child,
    );
  }

  void _preWarm() {}

  // ══════════════════════════════════════════════
  // 🆕 ຈັບ scroll → ເຊື່ອງ/ສະແດງ bars
  //   • ປັດຂຶ້ນ (delta > 0)  → ເຊື່ອງ
  //   • ປັດລົງ (delta < 0)  → ສະແດງ
  //   • ຢູ່ເທິງສຸດ (pixels ≤ 20) → ສະແດງສະເໝີ
  // ══════════════════════════════════════════════
  bool _onScrollNotification(ScrollNotification notification) {
    // ກັ່ນເອົາສະເພາະ scroll ແນວຕັ້ງ
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final pixels = notification.metrics.pixels;

      // ຢູ່ເທິງສຸດ → ສະແດງສະເໝີ
      if (pixels <= 20) {
        if (!_barsVisible.value) _barsVisible.value = true;
        _lastScrollPixels = pixels;
        return false;
      }

      // ປັດຂຶ້ນ → ເຊື່ອງ
      if (delta > 6 && _barsVisible.value) {
        _barsVisible.value = false;
      }
      // ປັດລົງ → ສະແດງ
      else if (delta < -6 && !_barsVisible.value) {
        _barsVisible.value = true;
      }

      _lastScrollPixels = pixels;
    } else if (notification is ScrollEndNotification) {
      // ປັດຈົບ → ຖ້າຢູ່ເທິງສຸດ ສະແດງຄືນ
      if (notification.metrics.pixels <= 20 &&
          !_barsVisible.value) {
        _barsVisible.value = true;
      }
    }
    return false; // ບໍ່ consume
  }

  void _onPermissionsChanged() {
    if (!mounted) return;
    final newTabs = _buildTabs();
    if (!_tabsChanged(newTabs)) {
      setState(() {});
      return;
    }

    MenuKey? currentKey;
    final oldIdx = _indexNotifier.value;
    if (oldIdx >= 0 && oldIdx < _currentTabs.length) {
      currentKey = _currentTabs[oldIdx].key;
    }

    int newIdx = 0;
    if (currentKey != null) {
      final found = newTabs.indexWhere((t) => t.key == currentKey);
      if (found >= 0) newIdx = found;
    }
    if (newTabs.isNotEmpty) {
      newIdx = newIdx.clamp(0, newTabs.length - 1);
    } else {
      newIdx = 0;
    }

    final oldController = _pageController;
    final newPages = _buildPages(newTabs);

    setState(() {
      _currentTabs = newTabs;
      _currentPages = newPages;
      _pageController = PageController(initialPage: newIdx);
    });

    _indexNotifier.value = newIdx;
    _titleIndexNotifier.value = newIdx;
    _lastTabIndex = newIdx;
    _barsVisible.value = true; // ສະແດງ bars ຕອນ permission ປ່ຽນ

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        oldController.dispose();
      } catch (_) {}
    });
  }

  bool _tabsChanged(List<_TabDef> other) {
    if (other.length != _currentTabs.length) return true;
    for (int i = 0; i < other.length; i++) {
      if (other[i].key != _currentTabs[i].key) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _bumpTimer?.cancel();
    _titleDebounce?.cancel();
    _pageController.dispose();
    _indexNotifier.dispose();
    _titleIndexNotifier.dispose();
    _lockSwipe.dispose();
    _barsVisible.dispose();
    super.dispose();
  }

  bool get _isOn3DTab {
    final idx = _indexNotifier.value;
    if (idx < 0 || idx >= _currentTabs.length) return false;
    return _currentTabs[idx].key == MenuKey.wood3d;
  }

  void _scheduleBump() {
    _bumpTimer?.cancel();
    _bumpTimer = Timer(const Duration(milliseconds: 280), () {
      PageRouteNotifier.instance.bump();
    });
  }

  void _onItemTapped(int index) {
    if (_indexNotifier.value == index) return;
    if (index < 0 || index >= _currentTabs.length) return;
    _lastTabIndex = index;
    // ສະແດງ bars ທຸກຄັ້ງທີ່ປ່ຽນ tab
    if (!_barsVisible.value) _barsVisible.value = true;

    final distance = (index - _indexNotifier.value).abs();
    if (distance == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_auth.isAdmin && !_auth.permissionLoaded.value) {
        return const _LoadingPage();
      }
      if (!_auth.isAdmin && !_auth.hasAnyPermission) {
        return const _PendingApprovalPage();
      }
      if (_currentTabs.isEmpty) {
        return const _PendingApprovalPage();
      }
      return _buildMainScaffold();
    });
  }

  // ══════════════════════════════════════════════
  // 🎯 Scaffold ຫຼັກ — AppBar + BottomNav ເຊື່ອງໄດ້
  // ══════════════════════════════════════════════
  Widget _buildMainScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: Column(
        children: [
          // ── AppBar (ເຊື່ອງ/ສະແດງໄດ້) ──
          ValueListenableBuilder<bool>(
            valueListenable: _barsVisible,
            builder: (context, visible, child) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: visible
                    ? child!
                    : const SizedBox(width: double.infinity),
              );
            },
            child: ValueListenableBuilder<int>(
              valueListenable: _titleIndexNotifier,
              builder: (context, idx, _) {
                final safeIdx = idx.clamp(0, _currentTabs.length - 1);
                return _HomeAppBar(title: _currentTabs[safeIdx].title);
              },
            ),
          ),

          // ── Body (PageView) ──
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ValueListenableBuilder<bool>(
                valueListenable: _lockSwipe,
                builder: (context, locked, child) {
                  final lockNow = locked && _isOn3DTab;
                  return PageView(
                    controller: _pageController,
                    physics: lockNow
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    allowImplicitScrolling: true,
                    onPageChanged: (i) {
                      _indexNotifier.value = i;
                      _lastTabIndex = i;
                      _scheduleBump();

                      // ສະແດງ bars ຕອນປ່ຽນ tab
                      if (!_barsVisible.value) _barsVisible.value = true;

                      _titleDebounce?.cancel();
                      _titleDebounce =
                          Timer(const Duration(milliseconds: 120), () {
                        if (mounted) _titleIndexNotifier.value = i;
                      });
                    },
                    children: _currentPages,
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ── BottomNav (ເຊື່ອງ/ສະແດງໄດ້) ──
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _barsVisible,
        builder: (context, visible, child) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: visible
                ? child!
                : const SizedBox(width: double.infinity),
          );
        },
        child: ValueListenableBuilder<int>(
          valueListenable: _indexNotifier,
          builder: (context, idx, _) {
            final safeIdx = idx.clamp(0, _currentTabs.length - 1);
            return BottomNavigationBar(
              currentIndex: safeIdx,
              selectedItemColor: Colors.brown,
              unselectedItemColor: Colors.grey,
              selectedIconTheme: const IconThemeData(size: 26),
              unselectedIconTheme: const IconThemeData(size: 22),
              selectedFontSize: 12,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
              items: _currentTabs
                  .map(
                    (t) => BottomNavigationBarItem(
                      icon: Icon(t.icon),
                      label: t.label,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ⏳ Loading Page
// ══════════════════════════════════════════════
class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F0EA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.brown),
            SizedBox(height: 16),
            Text(
              'ກຳລັງໂຫຼດ...',
              style: TextStyle(color: Colors.brown, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ⏸️ Pending Approval Page
// ══════════════════════════════════════════════
class _PendingApprovalPage extends StatelessWidget {
  const _PendingApprovalPage();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      appBar: AppBar(
        title: const Text('ລໍຖ້າການອະນຸມັດ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 26),
            tooltip: 'ໂປຣຟາຍ',
            onPressed: () => Get.to(() => const ProfileViewPage()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            tooltip: 'ອອກຈາກລະບົບ',
            onPressed: () => _showLogoutSheet(auth),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade200,
                          Colors.orange.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: 60,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'ຢູ່ລະຫວ່າງການກວດສອບ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.brown,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ບັນຊີຂອງທ່ານຍັງບໍ່ໄດ້ຮັບການກຳນົດສິດ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ກະລຸນາລໍຖ້າໃຫ້ Admin ກຳນົດສິດການເຂົ້າເຖິງ\n'
                        'ຈຶ່ງຈະສາມາດເຂົ້າໃຊ້ງານໄດ້',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.brown.shade200,
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ??
                                    user.email?.split('@').first ??
                                    'ຜູ້ໃຊ້',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email ?? '-',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.brown.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'ກຳລັງກວດສອບ',
                      'ກຳລັງກວດສອບສິດອີກຄັ້ງ...',
                      backgroundColor: Colors.brown,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 1),
                      margin: const EdgeInsets.all(12),
                      borderRadius: 12,
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('ກວດສອບອີກຄັ້ງ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown,
                    side: BorderSide(color: Colors.brown.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet ອອກຈາກລະບົບ ──
  void _showLogoutSheet(AuthController auth) {
    var isLoggingOut = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: isLoggingOut
                    ? _loadingContent()
                    : _confirmContent(
                        onCancel: () => Get.back(),
                        onConfirm: () async {
                          setSheetState(() => isLoggingOut = true);
                          try {
                            await auth.logout();
                          } catch (_) {}
                          Get.back();
                          Get.offAll(() => const RegisterPage());
                        },
                      ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }

  Widget _confirmContent({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ອອກຈາກລະບົບ',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ທ່ານຕ້ອງການອອກຈາກລະບົບແມ່ນບໍ່?',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ຍົກເລີກ',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'ອອກຈາກລະບົບ',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 32),
        const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            color: Colors.brown,
            strokeWidth: 3.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'ກຳລັງອອກຈາກລະບົບ...',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.brown,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ກະລຸນາລໍຖ້າໜຶ່ງຄູ່',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 🎯 3D Lazy Wrapper
// ══════════════════════════════════════════════
class _Lazy3DWrapper extends StatefulWidget {
  final ValueNotifier<bool>? swipeLock;
  const _Lazy3DWrapper({this.swipeLock});

  @override
  State<_Lazy3DWrapper> createState() => _Lazy3DWrapperState();
}

class _Lazy3DWrapperState extends State<_Lazy3DWrapper>
    with AutomaticKeepAliveClientMixin {
  bool _ready = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ready) {
      return const ColoredBox(
        color: Color(0xFFEFEBE9),
        child: Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }
    return Wood3DPage(swipeLock: widget.swipeLock);
  }
}

// ══════════════════════════════════════════════
// 🎯 Tab Gate
// ══════════════════════════════════════════════
class _TabTickerGate extends StatelessWidget {
  final int index;
  final ValueListenable<int> currentIndex;
  final Widget child;

  const _TabTickerGate({
    required this.index,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, current, child) {
        final active = current == index;
        return TickerMode(
          enabled: active,
          child: ExcludeFocus(excluding: !active, child: child!),
        );
      },
      child: child,
    );
  }
}

// ══════════════════════════════════════════════
// KeepAlive
// ══════════════════════════════════════════════
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ══════════════════════════════════════════════
// AppBar
// ══════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _HomeAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(title: title);
  }
}