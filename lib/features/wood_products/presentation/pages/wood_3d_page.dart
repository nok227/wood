import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/auth/register_page.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import '../widgets/wood_3d_scene.dart';


class Wood3DPage extends StatefulWidget {
  /// แจ้ง HomeShell ว่ามีการเลือก dropdown / แสดงโมเดลอยู่ไหม (true = ล็อกการปัดเปลี่ยนหน้า)
  final ValueNotifier<bool>? swipeLock;

  const Wood3DPage({super.key, this.swipeLock});

  @override
  State<Wood3DPage> createState() => _Wood3DPageState();
}

class _Wood3DPageState extends State<Wood3DPage> {
  final controller = Get.find<WoodProductController>();

  String selectedWoodType = 'ທັງໝົດ';
  String? selectedName;
  WoodProductModel? selectedVariant;
  String? focusedDimension;
  bool showColor = false; // เริ่มต้น: ไม่มีสี กดปุ่ม "ສີ" ถึงจะใส่สีไม้

  String _fmt(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // มีการเลือก dropdown ตัวใดตัวหนึ่งอยู่ไหม (ค่าเริ่มต้น 'ທັງໝົດ' ไม่นับ)
  bool get _hasAnyChoice =>
      selectedWoodType != 'ທັງໝົດ' || selectedName != null || selectedVariant != null;

  // ส่งสถานะล็อกการปัดไปให้ HomeShell (ทำหลังเฟรมนี้เสร็จ กันไม่ให้ set ค่าระหว่าง build)
  void _syncSwipeLock(bool locked) {
    final lock = widget.swipeLock;
    if (lock == null || lock.value == locked) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) lock.value = locked;
    });
  }

  // 🧹 ล้าง dropdown ทั้งหมด และล้างโมเดล 3D
  void _clearAll() {
    setState(() {
      selectedWoodType = 'ທັງໝົດ';
      selectedName = null;
      selectedVariant = null;
      focusedDimension = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final allProducts = controller.products;

        // 1. รายการชนิดไม้ทั้งหมด
        final woodTypeOptions = ['ທັງໝົດ', ...controller.uniqueWoodTypes];

        // 2. กรองตามชนิดไม้
        final filteredProducts = selectedWoodType == 'ທັງໝົດ'
            ? allProducts
            : allProducts.where((p) => p.woodType.trim() == selectedWoodType).toList();

        // 3. ชื่อไม้ที่ไม่ซ้ำกัน
        final names = filteredProducts.map((p) => p.name).toSet().toList();

        if (selectedName != null && !names.contains(selectedName)) {
          selectedName = null;
          selectedVariant = null;
        }

        // 4. รายการขนาดไม้
        final variants = selectedName == null
            ? <WoodProductModel>[]
            : filteredProducts.where((p) => p.name == selectedName).toList();

        if (variants.isEmpty) {
          selectedVariant = null;
        } else {
          final matched = variants.where((v) => v.id == selectedVariant?.id).toList();
          selectedVariant = matched.isNotEmpty ? matched.first : variants.first;
        }

        final hasSelection = selectedVariant != null;

        // 🔒 ถ้ามีการเลือก dropdown หรือแสดงโมเดลอยู่ -> ล็อกการปัดเปลี่ยนหน้า
        _syncSwipeLock(_hasAnyChoice);

        return Column(
          children: [
            // 🎨 ปุ่ม "สี" ด้านบน (เปิด/ปิดสีไม้)
            if (hasSelection)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _colorButton(),
                ),
              ),

            Expanded(
              child: hasSelection
                  ? Wood3DScene(
                      key: ValueKey(selectedName),
                      productName: selectedVariant!.name,
                      width: selectedVariant!.width,
                      length: selectedVariant!.length,
                      thickness: selectedVariant!.thickness,
                      sizeUnit: selectedVariant!.sizeUnit,
                      unit: selectedVariant!.unit,
                      focusedDimension: focusedDimension,
                      showColor: showColor,
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.brown[50],
                      child: const Center(
                        child: Text(
                          'ພື້ນທີ່ສະແດງໂມເດວໄມ້ 3D',
                          style: TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                      ),
                    ),
            ),

            if (hasSelection)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: _dimButton('ກວ້າງ', 'width')),
                    const SizedBox(width: 8),
                    Expanded(child: _dimButton('ຍາວ', 'length')),
                    const SizedBox(width: 8),
                    Expanded(child: _dimButton('ໜາ', 'thickness')),
                  ],
                ),
              ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: allProducts.isEmpty
                  ? const Text(
                      'ຍັງບໍ່ມີຂໍ້ມູນໃນຄັງ ກະລຸນາເພີ່ມຂໍ້ມູນກ່ອນ',
                      style: TextStyle(color: Colors.black54),
                    )
                  : Column(
                      children: [
                        // Dropdown ชนิดไม้ + ปุ่มล้าง
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedWoodType,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'ຊະນິດໄມ້',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: woodTypeOptions
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type == 'ທັງໝົດ' ? 'ທັງໝົດ (ສະແດງທັງໝົດ)' : type,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() {
                                  selectedWoodType = v ?? 'ທັງໝົດ';
                                  selectedName = null;
                                  selectedVariant = null;
                                  focusedDimension = null;
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _clearButton(),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dropdown ชื่อไม้
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedName,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'ຊື່ໄມ້',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                hint: const Text('ເລືອກຊື່ໄມ້'),
                                items: names
                                    .map((n) => DropdownMenuItem(
                                          value: n,
                                          child: Text(n, overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() {
                                  selectedName = v;
                                  focusedDimension = null;
                                  final vs = v == null
                                      ? <WoodProductModel>[]
                                      : filteredProducts.where((p) => p.name == v).toList();
                                  selectedVariant = vs.isNotEmpty ? vs.first : null;
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Dropdown ขนาดไม้
                            Expanded(
                              child: DropdownButtonFormField<WoodProductModel>(
                                value: selectedVariant,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'ຂະໜາດ',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                hint: const Text('ເລືອກຂະໜາດ'),
                                items: variants
                                    .map((v) => DropdownMenuItem<WoodProductModel>(
                                          value: v,
                                          child: Text(
                                            '${_fmt(v.width)}×${_fmt(v.length)}×${_fmt(v.thickness)} ${v.sizeUnit}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: selectedName == null
                                    ? null
                                    : (v) => setState(() {
                                          selectedVariant = v;
                                          focusedDimension = null;
                                        }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }

  // 🧹 ปุ่มล้าง (กดได้เฉพาะตอนมีการเลือก dropdown อยู่)
  Widget _clearButton() {
    final enabled = _hasAnyChoice;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: enabled ? Colors.red : Colors.black12),
        ),
        onPressed: enabled ? _clearAll : null,
        icon: const Icon(Icons.clear_all, size: 18),
        label: const Text('ລ້າງ'),
      ),
    );
  }

  // 🎨 ปุ่มเปิด/ปิดสีไม้
  Widget _colorButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: showColor ? Colors.brown : null,
        foregroundColor: showColor ? Colors.white : Colors.brown,
        side: const BorderSide(color: Colors.brown),
      ),
      onPressed: () => setState(() => showColor = !showColor),
      icon: const Icon(Icons.palette, size: 18),
      label: const Text('ສີ'),
    );
  }

  Widget _dimButton(String label, String value) {
    final active = focusedDimension == value;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? Colors.brown : null,
        foregroundColor: active ? Colors.white : Colors.brown,
        side: const BorderSide(color: Colors.brown),
      ),
      onPressed: () => setState(() {
        focusedDimension = active ? null : value;
      }),
      child: Text(label),
    );
  }

  // 🔴 ฟังก์ชันยืนยันและดำเนินการ Logout
  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      title: 'ຍືນຍັນການອອກຈາກລະບົບ',
      middleText: 'ທ່ານຕ້ອງການອອກຈາກລະບົບ ແມ່ນຫຼືບໍ່?',
      textConfirm: 'ອອກຈາກລະບົບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // ปิด Dialog
        try {
          await Get.find<AuthController>().logout();
          Get.offAll(() => const RegisterPage());
        } catch (e) {
          Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອອກຈາກລະບົບໄດ້: $e');
        }
      },
    );
  }
}