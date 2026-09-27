import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/util/page_route_notifier.dart';
import 'package:wood/features/auth/auth_controller.dart';
import '../widgets/custom_app_bar.dart';
import 'wood_product_form_page.dart';
import 'wood_product_list_page.dart';
import 'wood_3d_page.dart';
import 'sales_list_page.dart';
import 'account_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // ══════════════════════════════════════════════
  // ✅ Static — ຈື່ tab ລ່າສຸດ ຂ້າມ dispose/recreate
  // ══════════════════════════════════════════════
  static int? _lastTabIndex;

  late final PageController _pageController;
  late final bool _isAdmin;
  late final int _wood3dIndex;
  late final List<String> _titles;
  late final List<BottomNavigationBarItem> _navItems;

  /// ✅ Cache ทุกหน้าไว้ครั้งเดียว
  late final List<Widget> _pages;

  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _lockSwipe = ValueNotifier<bool>(false);

  // ✅ Title/WaveText ໃຊ້ index ແຍກຕ່າງຫາກ + debounce
  // ບໍ່ໃຫ້ replay ອະນິເມຊັນຕອນນິ້ວຍັງລາກຢູ່ (ລໍຖ້າ settle ກ່ອນ)
  final ValueNotifier<int> _titleIndexNotifier = ValueNotifier<int>(0);
  Timer? _titleDebounce;

  Timer? _bumpTimer;

  @override
  void initState() {
    super.initState();
    _isAdmin = Get.find<AuthController>().isAdmin;
    _wood3dIndex = _isAdmin ? 4 : 3;
    final maxIndex = _isAdmin ? 4 : 3;

    // ✅ ກັບມາຢູ່ tab ເກົ່າ ຖ້າເຄີຍເປີດໄວ້ — ບໍ່ດັ່ງນັ້ນ ໃຊ້ default
    final fallback = _isAdmin ? 1 : 0;
    final initial = (_lastTabIndex != null &&
            _lastTabIndex! >= 0 &&
            _lastTabIndex! <= maxIndex)
        ? _lastTabIndex!
        : fallback;

    _indexNotifier.value = initial;
    _titleIndexNotifier.value = initial;
    _pageController = PageController(initialPage: initial);

    _titles = [
      if (_isAdmin) 'ເພີ່ມໄມ້ໃໝ່',
      'ລາຍການໄມ້ໃນຄັງ',
      'ລາຍການຂາຍ',
      'ບັນຊີ ລາຍຮັບ-ລາຍຈ່າຍ',
      'ໂມເດວ 3D ທຽບໄມ້ໃນຄັງ',
    ];

    _navItems = [
      if (_isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'ເພີ່ມໄມ້',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        label: 'ລາຍການໄມ້',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.point_of_sale_outlined),
        label: 'ການຂາຍ',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        label: 'ບັນຊີ',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.view_in_ar_rounded),
        label: 'ໂມເດວ 3D',
      ),
    ];

    _pages = _buildAllPages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preWarm();
    });
  }

  List<Widget> _buildAllPages() {
    if (_isAdmin) {
      return [
        _gate(0, const RepaintBoundary(child: WoodProductFormPage())),
        _gate(1, const RepaintBoundary(child: WoodProductListPage())),
        _gate(
            2,
            const RepaintBoundary(
                child: _KeepAlivePage(child: SalesListPage()))),
        _gate(
            3,
            const RepaintBoundary(
                child: _KeepAlivePage(child: AccountPage()))),
        _gate(4, _build3DPage()),
      ];
    }
    return [
      _gate(0, const RepaintBoundary(child: WoodProductListPage())),
      _gate(
          1,
          const RepaintBoundary(
              child: _KeepAlivePage(child: SalesListPage()))),
      _gate(
          2,
          const RepaintBoundary(
              child: _KeepAlivePage(child: AccountPage()))),
      _gate(3, _build3DPage()),
    ];
  }

  /// ✅ ຄຸມ TickerMode ຂອງແຕ່ລະ tab — tab ທີ່ບໍ່ໄດ້ສະແດງຢູ່ ຈະຢຸດ
  /// AnimationController/AnimatedNumber ທັງໝົດຂອງມັນໂດຍອັດຕະໂນມັດ
  Widget _gate(int index, Widget child) {
    return _TabTickerGate(
      index: index,
      currentIndex: _indexNotifier,
      child: child,
    );
  }

  Widget _build3DPage() {
    return RepaintBoundary(
      child: _Lazy3DWrapper(swipeLock: _lockSwipe),
    );
  }

  void _preWarm() {}

  @override
  void dispose() {
    _bumpTimer?.cancel();
    _titleDebounce?.cancel();
    _pageController.dispose();
    _indexNotifier.dispose();
    _titleIndexNotifier.dispose();
    _lockSwipe.dispose();
    super.dispose();
  }

  int get _pageCount => _isAdmin ? 5 : 4;

  void _scheduleBump() {
    _bumpTimer?.cancel();
    _bumpTimer = Timer(const Duration(milliseconds: 280), () {
      PageRouteNotifier.instance.bump();
    });
  }

  void _onItemTapped(int index) {
    if (_indexNotifier.value == index) return;
    // ✅ ບັນທຶກທັນທີ
    _lastTabIndex = index;

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<int>(
          valueListenable: _titleIndexNotifier,
          builder: (context, idx, child) {
            return _HomeAppBar(title: _titles[idx]);
          },
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _lockSwipe,
        builder: (context, locked, child) {
          final lockNow = locked && _indexNotifier.value == _wood3dIndex;
          return PageView(
            controller: _pageController,
            physics: lockNow
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            allowImplicitScrolling: true,
            onPageChanged: (i) {
              _indexNotifier.value = i;
              _lastTabIndex = i;      // ✅ ບັນທຶກທຸກຄັ້ງທີ່ປ່ຽນ tab
              _scheduleBump();

              // ✅ ລໍໃຫ້ນິ້ວນິ່ງກ່ອນ ຄ່ອຍປ່ຽນ title (ບໍ່ໃຫ້ WaveText
              // replay ອະນິເມຊັນຕອນ PageView ຍັງກຳລັງ scroll ຢູ່)
              _titleDebounce?.cancel();
              _titleDebounce = Timer(const Duration(milliseconds: 120), () {
                if (mounted) _titleIndexNotifier.value = i;
              });
            },
            children: _pages,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _indexNotifier,
        builder: (context, idx, child) {
          return BottomNavigationBar(
            currentIndex: idx,
            selectedItemColor: Colors.brown,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: const IconThemeData(size: 26),
            unselectedIconTheme: const IconThemeData(size: 22),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            items: _navItems,
          );
        },
      ),
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
        child: Center(
          child: CircularProgressIndicator(color: Colors.brown),
        ),
      );
    }
    return Wood3DPage(swipeLock: widget.swipeLock);
  }
}

// ══════════════════════════════════════════════
// 🎯 TickerMode Gate — ຢຸດອະນິເມຊັນຂອງ tab ທີ່ບໍ່ໄດ້ສະແດງ
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
      // ✅ child ຖືກສົ່ງຜ່ານ builder — ຂອງເດີມບໍ່ຖືກ rebuild ໃໝ່
      // ມີແຕ່ TickerMode enabled flag ທີ່ toggle
      builder: (context, current, child) {
        return TickerMode(enabled: current == index, child: child!);
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