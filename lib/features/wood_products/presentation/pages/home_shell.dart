import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int _index = 1;
  late final bool _isAdmin;

  final ValueNotifier<bool> _lockSwipe = ValueNotifier<bool>(false);
  late final int _wood3dIndex;

  late final List<Widget> _pages;
  late final List<String> _titles;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _isAdmin = Get.find<AuthController>().isAdmin;

    _index = _isAdmin ? 1 : 0;
    _pageController = PageController(initialPage: _index);

    // ✅ ແຕ່ລະໜ້າຫໍ່ RepaintBoundary — ແຍກ layer ຂອງຕົນເອງ
    _pages = [
      if (_isAdmin) RepaintBoundary(child: WoodProductFormPage()),
      const RepaintBoundary(child: WoodProductListPage()),
      RepaintBoundary(child: SalesListPage()),
      RepaintBoundary(child: AccountPage()),
      RepaintBoundary(child: Wood3DPage(swipeLock: _lockSwipe)),
    ];
    _wood3dIndex = _pages.length - 1;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _lockSwipe.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_index == index) return;
    // ✅ ໃຊ້ jumpToPage ຖ້າຢາກໄວສຸດ (ບໍ່ມີ animation)
    // ຫຼື ໃຊ້ animateToPage ກັບເວລາສັ້ນ
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 180), // ✅ ຫຼຸດ 250 → 180
      curve: Curves.easeOutCubic, // ✅ ເບົາກວ່າ fastOutSlowIn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar ແຍກ widget ຕ່າງຫາກ — ບໍ່ rebuild ທັງ tree
      appBar: _HomeAppBar(title: _titles[_index]),
      body: ValueListenableBuilder<bool>(
        valueListenable: _lockSwipe,
        builder: (context, locked, _) {
          final lockNow = locked && _index == _wood3dIndex;
          // ✅ ໃຊ້ PageView.builder ແທນ PageView(children:) → lazy build
          return PageView.builder(
            controller: _pageController,
            physics: lockNow
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            itemCount: _pages.length,
            onPageChanged: (i) {
              if (_index != i) setState(() => _index = i);
            },
            itemBuilder: (context, i) => _pages[i],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: _navItems,
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ✅ ແຍກ AppBar ຕ່າງຫາກ — ບໍ່ rebuild ຕອນ setState
// ══════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _HomeAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      key: ValueKey(title), // ✅ ບັງຄັບ recreate ຕອນ title ປ່ຽນ
      title: title,
    );
  }
}