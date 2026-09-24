import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/auth_controller.dart';
import '../widgets/custom_app_bar.dart';
import 'wood_product_form_page.dart';
import 'wood_product_list_page.dart';
import 'wood_3d_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final PageController _pageController;
  int _index = 1;
  late final bool _isAdmin;

  // 🔒 true = หน้า 3D มีการเลือก dropdown / แสดงโมเดลอยู่ -> ห้ามปัดเปลี่ยนหน้า
  final ValueNotifier<bool> _lockSwipe = ValueNotifier<bool>(false);
  late final int _wood3dIndex; // ตำแหน่งของหน้า 3D ใน PageView

  // 🚀 ประกาศ List ไว้ระดับ State เพื่อไม่ให้สร้างใหม่ทุกครั้งที่ Rebuild
  late final List<Widget> _pages;
  late final List<String> _titles;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _isAdmin = Get.find<AuthController>().isAdmin;

    // ตั้งค่า Index เริ่มต้นให้ถูกต้องตามสิทธิ์ Admin
    _index = _isAdmin ? 1 : 0;
    _pageController = PageController(initialPage: _index);

    // 📌 กำหนดค่าครั้งเดียวใน initState
    _pages = [
      if (_isAdmin) WoodProductFormPage(), // หน้า Form
      const WoodProductListPage(),
      Wood3DPage(swipeLock: _lockSwipe),
    ];
    _wood3dIndex = _pages.length - 1;

    _titles = [
      if (_isAdmin) 'ເພີ່ມໄມ້ໃໝ່',
      'ລາຍການໄມ້ໃນຄັງ',
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

    // ⚡ ปรับ Duration และ Curve ให้ตอบสนองเร็วขึ้น ลื่นไหลไม่หนืด
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves
          .fastOutSlowIn, // Curve นี้จะให้ความรู้สึกสมูธเบาแรงกว่า easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _titles[_index]),
      body: ValueListenableBuilder<bool>(
        valueListenable: _lockSwipe,
        builder: (context, locked, _) {
          // ล็อกการปัด เฉพาะตอนอยู่หน้า 3D และมีการเลือก dropdown / แสดงโมเดลอยู่
          // (ปุ่มเมนูด้านล่างยังกดเปลี่ยนหน้าได้ตามปกติ)
          final lockNow = locked && _index == _wood3dIndex;
          return PageView(
            controller: _pageController,
            physics: lockNow
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _index = i);
            },
            children: _pages,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,

        // 🚀 เพิ่ม 2 บรรทัดนี้: กำหนดขนาดไอคอนตอนเลือกให้ขยายขึ้น (28px) และตอนไม่เลือก (24px)
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),

        // 💡 (แถม) ขยายขนาดตัวหนังสือตอนเลือกขึ้นเล็กน้อยให้รับกัน
        selectedFontSize: 13,
        unselectedFontSize: 12,

        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: _navItems,
      ),
    );
  }
}
