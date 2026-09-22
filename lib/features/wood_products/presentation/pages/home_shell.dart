import 'package:flutter/material.dart';
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
  int _index = 2;

  // ✅ IndexedStack คงสถานะของแต่ละหน้าไว้ตอนสลับแท็บ
  final List<Widget> _pages = [
    WoodProductFormPage(),
    const WoodProductListPage(),
    const Wood3DPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'ເພີ່ມໄມ້'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'ລາຍການໄມ້'),
          BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'ໂມເດວ 3D'),
        ],
      ),
    );
  }
}
