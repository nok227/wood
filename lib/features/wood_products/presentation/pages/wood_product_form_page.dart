// lib/features/wood_products/presentation/pages/wood_product_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/features/wood_products/presentation/widgets/custom_app_bar.dart';
import '../controllers/wood_product_controller.dart';
import 'package:wood/core/util/currency_formatter.dart';

// 🚀 เปลี่ยนเป็น StatefulWidget เพื่อรองรับการ Keep State
class WoodProductFormPage extends StatefulWidget {
  final bool isPage;
  const WoodProductFormPage({super.key, this.isPage = false});

  @override
  State<WoodProductFormPage> createState() => _WoodProductFormPageState();
}

class _WoodProductFormPageState extends State<WoodProductFormPage> with AutomaticKeepAliveClientMixin {
  final WoodProductController controller = Get.find<WoodProductController>();

  // 🚀 คืนค่า true เพื่อจำฟอร์มที่กรอกค้างไว้ ไม่ให้รีเซ็ตตอนสไลด์หน้า
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🚀 อย่าลืมเรียก super.build

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.isPage // 👈 อ้างอิงตัวแปร isPage ผ่าน widget.isPage
          ? CustomAppBar(
              titleWidget: Obx(
                () => Text(
                  controller.editingProductId.value == null
                      ? 'ເພີ່ມໄມ້ໃໝ່'
                      : 'ແກ້ໄຂຂໍ້ມູນໄມ້',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຮູບໄມ້ ສູງສຸດ 6 ຮູບ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => _buildImagesPicker(controller)),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຊະນິດໄມ້ (ເຊັ່ນ: ໄມ້ຍາງ, ໄມ້ດູ່)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.woodTypeController,
              decoration: _minimalInputDecoration('ຊະນິດໄມ້'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຊື່ໄມ້',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              decoration: _minimalInputDecoration('ຊື່ໄມ້'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຂະໜາດ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.widthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _minimalInputDecoration('ກວ້າງ'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.lengthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _minimalInputDecoration('ຍາວ'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.thicknessController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _minimalInputDecoration('ໜາ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedSizeUnit.value,
                decoration: _minimalInputDecoration('ໜ່ວຍຂະໜາດ'),
                items: controller.sizeUnitOptions
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedSizeUnit.value = v;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.quantityController,
                    readOnly: true,
                    enabled: false,
                    decoration: _minimalInputDecoration(
                      'ຈຳນວນ',
                    ).copyWith(filled: true, fillColor: Colors.grey.shade100),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedUnit.value,
                      decoration: _minimalInputDecoration('ໜ່ວຍນັບ'),
                      items: controller.unitOptions
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedUnit.value = v;
                      },
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.selectedUnit.value == 'ອື່ນໆ'
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: controller.customUnitController,
                        decoration: _minimalInputDecoration('ລະບຸໜ່ວຍນັບ'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                CurrencyFormatter(),
              ],
              decoration: _minimalInputDecoration(
                'ລາຄາຂາຍ xxx ກີບ',
              ).copyWith(suffixText: 'ກີບ '),
            ),
            const SizedBox(height: 24),
            Obx(
              () => controller.isSaving.value
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              elevation: 0,
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final isEditing =
                                  controller.editingProductId.value != null;
                              final isSuccess = await controller.saveProduct();
                              if (isSuccess) {
                                Get.back();
                                Get.snackbar(
                                  'ສຳເລັດ',
                                  isEditing
                                      ? 'ແກ້ໄຂຂໍ້ມູນແລ້ວ'
                                      : 'ບັນທຶກຂໍ້ມູນແລ້ວ',
                                );
                              }
                            },
                            child: Text(
                              controller.editingProductId.value == null
                                  ? 'ບັນທຶກ'
                                  : 'ບັນທຶກແກ້ໄຂ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              controller.cancelEdit();
                              Get.back();
                            },
                            child: Text(
                              'ຍົກເລີກ',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _minimalInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
      ),
    );
  }
}

// ฟังก์ชัน Build Image Picker ถูกแยกอยู่นอก Class ใช้งานได้ตามปกติ
Widget _buildImagesPicker(WoodProductController controller) {
  final totalCount =
      controller.existingImageUrls.length + controller.selectedImages.length;
  final tiles = <Widget>[];

  for (int i = 0; i < controller.existingImageUrls.length; i++) {
    final url = controller.existingImageUrls[i];
    tiles.add(
      _imageThumb(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (c, u) => const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (c, u, e) => const Icon(Icons.broken_image),
        ),
        onRemove: () => controller.removeExistingImage(i),
      ),
    );
  }
  for (int i = 0; i < controller.selectedImages.length; i++) {
    final file = controller.selectedImages[i];
    tiles.add(
      _imageThumb(
        child: Image.file(file, fit: BoxFit.cover),
        onRemove: () => controller.removeNewImage(i),
      ),
    );
  }
  if (totalCount < WoodProductController.maxImages) {
    tiles.add(
      GestureDetector(
        onTap: controller.pickImages,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  return Wrap(spacing: 8, runSpacing: 8, children: tiles);
}

Widget _imageThumb({required Widget child, required VoidCallback onRemove}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 72, height: 72, child: child),
      ),
      Positioned(
        top: -4,
        right: -4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}