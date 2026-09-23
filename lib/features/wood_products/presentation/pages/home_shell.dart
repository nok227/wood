import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'wood_product_form_page.dart';
import 'wood_product_list_page.dart';
import 'wood_3d_page.dart';

/// หน้าหลักที่มีเมนูด้านล่าง สลับระหว่าง "เพิ่มไม้" / "รายการไม้" / "โมเดล 3D"
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    // 🔐 เช็คสิทธิ์ Admin จากจุดเดียว (AuthController)
    final bool isAdmin = Get.find<AuthController>().isAdmin;

    // 📄 รายการหน้าเพจ (แสดง Form เพิ่มไม้ เฉพาะ Admin)
    final List<Widget> pages = [
      if (isAdmin) WoodProductFormPage(),
      const WoodProductListPage(),
      const Wood3DPage(),
    ];

    // 🔘 รายการเมนูด้านล่าง (แสดง ปุ่มเพิ่มไม้ เฉพาะ Admin)
    final List<BottomNavigationBarItem> navItems = [
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'ເພີ່ມໄມ້'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'ລາຍການໄມ້'),
      const BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'ໂມເດວ 3D'),
    ];

    // ป้องกันกรณี Index เกินขอบเขตของรายการ
    final safeIndex = _index >= pages.length ? 0 : _index;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: navItems,
      ),
    );
  }
}