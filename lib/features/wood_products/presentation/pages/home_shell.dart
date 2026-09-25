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
  late final PageController _pageController;
  late final bool _isAdmin;
  late final int _wood3dIndex;
  late final List<String> _titles;
  late final List<BottomNavigationBarItem> _navItems;

  /// ✅ Cache ທຸກໜ້າໄວ້ຄັ້ງດຽວ — ບໍ່ rebuild ຕອນປັດ
  late final List<Widget> _pages;

  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _lockSwipe = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _isAdmin = Get.find<AuthController>().isAdmin;
    _wood3dIndex = _isAdmin ? 4 : 3;

    final initial = _isAdmin ? 1 : 0;
    _indexNotifier.value = initial;
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

    // ✅ ສ້າງ widget ທຸກໜ້າຄັ້ງດຽວ — ບໍ່ສ້າງຊ້ຳຕອນປັດ
    _pages = _buildAllPages();

    // ✅ Pre-warm ຫຼັງ frame ທຳອິດ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preWarm();
    });
  }

  /// ສ້າງ widget ທຸກໜ້າຄັ້ງດຽວ
  List<Widget> _buildAllPages() {
    if (_isAdmin) {
      return [
        const RepaintBoundary(child: WoodProductFormPage()),
        const RepaintBoundary(child: WoodProductListPage()),
        const RepaintBoundary(
            child: _KeepAlivePage(child: SalesListPage())),
        const RepaintBoundary(
            child: _KeepAlivePage(child: AccountPage())),
        _build3DPage(),
      ];
    }
    return [
      const RepaintBoundary(child: WoodProductListPage()),
      const RepaintBoundary(
          child: _KeepAlivePage(child: SalesListPage())),
      const RepaintBoundary(
          child: _KeepAlivePage(child: AccountPage())),
      _build3DPage(),
    ];
  }

  Widget _build3DPage() {
    return RepaintBoundary(
      child: _Lazy3DWrapper(swipeLock: _lockSwipe),
    );
  }

  /// ✅ ບັງຄັບໃຫ້ Flutter pre-mount ທຸກໜ້າໃນ background
  void _preWarm() {
    // ບໍ່ຕ້ອງເຮັດຫຍັງ — ປ່ອຍໃຫ້ allowImplicitScrolling ຈັດການ
    // (ມັນຈະ pre-build ໜ້າ neighbor ອັດຕະໂນມັດ)
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indexNotifier.dispose();
    _lockSwipe.dispose();
    super.dispose();
  }

  int get _pageCount => _isAdmin ? 5 : 4;

  void _onItemTapped(int index) {
    if (_indexNotifier.value == index) return;
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
          valueListenable: _indexNotifier,
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
            // ✅ ສຳຄັນທີ່ສຸດ: pre-build ໜ້າ neighbor ໃນ background
            allowImplicitScrolling: true,
            onPageChanged: (i) {
              _indexNotifier.value = i;
              PageRouteNotifier.instance.bump();
            },
            // ✅ ໃຊ້ children ແທນ builder — ທຸກໜ້າຖືກສ້າງຄັ້ງດຽວ
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
// 🎯 3D Lazy Wrapper — ສ້າງ 3D ຕອນມີຄົນເຂົ້າຄັ້ງທຳອິດ
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
    // ຫຼັງ frame ທຳອິດ → ສ້າງ 3D
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