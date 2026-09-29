// lib/features/wood_products/presentation/pages/wood_product_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:wood/features/wood_products/presentation/widgets/custom_app_bar.dart';
import 'package:wood/features/wood_products/presentation/widgets/wood_product_preview_card.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import 'package:wood/core/util/currency_formatter.dart';

class WoodProductFormPage extends StatefulWidget {
  final bool isPage;
  const WoodProductFormPage({super.key, this.isPage = false});

  @override
  State<WoodProductFormPage> createState() => _WoodProductFormPageState();
}

class _WoodProductFormPageState extends State<WoodProductFormPage>
    with AutomaticKeepAliveClientMixin {
  final WoodProductController controller = Get.find<WoodProductController>();

  late final Listenable _formListenable = Listenable.merge([
    controller.woodTypeController,
    controller.nameController,
    controller.widthController,
    controller.lengthController,
    controller.thicknessController,
    controller.priceController,
    controller.customUnitController,
  ]);

  @override
  bool get wantKeepAlive => true;

  // ══════════════════════════════════════════════
  // 🔍 ກວດສອບສິນຄ້າຊ້ຳ
  // ══════════════════════════════════════════════
  WoodProductModel? _findDuplicate() {
    final editingId = controller.editingProductId.value;

    final woodType = controller.woodTypeController.text.trim().toLowerCase();
    final name = controller.nameController.text.trim().toLowerCase();
    final width = controller.widthController.text.trim();
    final length = controller.lengthController.text.trim();
    final thickness = controller.thicknessController.text.trim();
    final sizeUnit = controller.selectedSizeUnit.value.trim().toLowerCase();
    final unit = controller.selectedUnit.value.trim().toLowerCase();
    final price = controller.priceController.text.trim().replaceAll(',', '');

    for (final p in controller.products) {
      if (editingId != null && p.id == editingId) continue;

      final sameWoodType = p.woodType.trim().toLowerCase() == woodType;
      final sameName = p.name.trim().toLowerCase() == name;
      final sameWidth = _numEq(p.width, width);
      final sameLength = _numEq(p.length, length);
      final sameThickness = _numEq(p.thickness, thickness);
      final sameSizeUnit = p.sizeUnit.trim().toLowerCase() == sizeUnit;
      final sameUnit = p.unit.trim().toLowerCase() == unit;
      final samePrice = _numEq(p.price, price.replaceAll(RegExp(r'\.0+$'), ''));

      if (sameWoodType &&
          sameName &&
          sameWidth &&
          sameLength &&
          sameThickness &&
          sameSizeUnit &&
          sameUnit &&
          samePrice) {
        return p;
      }
    }
    return null;
  }

  bool _numEq(num a, String bStr) {
    final b = double.tryParse(bStr);
    if (b == null) return false;
    return (a - b).abs() < 0.001;
  }

  // ══════════════════════════════════════════════
  // ✅ ເງື່ອນໄຂ done
  // ══════════════════════════════════════════════
  bool get _doneImages =>
      controller.existingImageUrls.isNotEmpty ||
      controller.selectedImages.isNotEmpty;

  bool get _doneWoodType =>
      controller.woodTypeController.text.trim().isNotEmpty;

  bool get _doneName => controller.nameController.text.trim().isNotEmpty;

  bool get _doneSize {
    final w = double.tryParse(controller.widthController.text.trim());
    final l = double.tryParse(controller.lengthController.text.trim());
    final t = double.tryParse(controller.thicknessController.text.trim());
    return w != null && w > 0 && l != null && l > 0 && t != null && t > 0;
  }

  bool get _donePrice {
    final p = double.tryParse(
      controller.priceController.text.replaceAll(',', '').trim(),
    );
    return p != null && p > 0;
  }

  // ✅ ໜ່ວຍນັບ done — default ຂຽວທັນທີ, 'ອື່ນໆ' ຕ້ອງພິມ
  bool get _doneUnit {
    final u = controller.selectedUnit.value.trim();
    if (u.isEmpty) return false;
    if (u == 'ອື່ນໆ') {
      return controller.customUnitController.text.trim().isNotEmpty;
    }
    return true;
  }

  // ✅ ມີ input ຫຍັງກໍ່ໄດ້ → ສະແດງ preview ທັນທີ
  bool get _hasAnyInput =>
      controller.woodTypeController.text.trim().isNotEmpty ||
      controller.nameController.text.trim().isNotEmpty ||
      controller.widthController.text.trim().isNotEmpty ||
      controller.lengthController.text.trim().isNotEmpty ||
      controller.thicknessController.text.trim().isNotEmpty ||
      controller.priceController.text.trim().isNotEmpty ||
      controller.selectedImages.isNotEmpty ||
      controller.existingImageUrls.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.isPage
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
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: _formListenable,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ① ຮູບໄມ້
              Obx(
                () => _section(
                  number: '1',
                  title: 'ຮູບໄມ້ (ສູງສຸດ 6 ຮູບ)',
                  icon: Icons.photo_library_outlined,
                  color: Colors.brown,
                  done: _doneImages,
                  child: _buildImagesPicker(controller),
                ),
              ),
              const SizedBox(height: 14),

              // ② ຊະນິດໄມ້
              _section(
                number: '2',
                title: 'ຊະນິດໄມ້',
                icon: Icons.local_florist,
                color: Colors.brown,
                done: _doneWoodType,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.woodTypeController,
                      decoration: _minimalInputDecoration('ຊະນິດໄມ້'),
                    ),
                    Obx(
                      () => _suggestionChips(
                        items: controller.uniqueWoodTypes,
                        onTap: (t) {
                          controller.woodTypeController.text = t;
                          controller.woodTypeController.selection =
                              TextSelection.collapsed(offset: t.length);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ③ ຊື່ໄມ້
              _section(
                number: '3',
                title: 'ຊື່ໄມ້',
                icon: Icons.inventory_2_outlined,
                color: Colors.brown,
                done: _doneName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.nameController,
                      decoration: _minimalInputDecoration('ຊື່ໄມ້'),
                    ),
                    Obx(
                      () => _suggestionChips(
                        items: controller.uniqueProductNames,
                        onTap: (t) {
                          controller.nameController.text = t;
                          controller.nameController.selection =
                              TextSelection.collapsed(offset: t.length);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ④ ຂະໜາດ
              _section(
                number: '4',
                title: 'ຂະໜາດ',
                icon: Icons.straighten,
                color: Colors.brown,
                done: _doneSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            controller.selectedSizeUnit.value = v;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ⑤ ຈຳນວນ ແລະ ໜ່ວຍນັບ
              // ✅ done: _doneUnit (ແທນ false ເກົ່າ)
              Obx(
                () => _section(
                  number: '5',
                  title: 'ຈຳນວນ ແລະ ໜ່ວຍນັບ',
                  icon: Icons.numbers,
                  color: Colors.brown,
                  done: _doneUnit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.quantityController,
                              readOnly: true,
                              enabled: false,
                              decoration: _minimalInputDecoration('ຈຳນວນ')
                                  .copyWith(
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              // ✅ ຖ້າຫວ່າງ → null ຈຶ່ງສະແດງ hint
                              value: controller.selectedUnit.value.isEmpty
                                  ? null
                                  : controller.selectedUnit.value,
                              hint: Text(
                                'ເລືອກໜ່ວຍນັບ',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              decoration: _minimalInputDecoration('ໜ່ວຍນັບ'),
                              items: controller.unitOptions
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  controller.selectedUnit.value = v;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (controller.selectedUnit.value == 'ອື່ນໆ')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextField(
                            controller: controller.customUnitController,
                            decoration: _minimalInputDecoration('ລະບຸໜ່ວຍນັບ'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ⑥ ລາຄາຂາຍ
              _section(
                number: '6',
                title: 'ລາຄາຂາຍ',
                icon: Icons.sell_outlined,
                color: Colors.brown,
                done: _donePrice,
                child: TextField(
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
              ),

              // ══════════════════════════════════════════
              // ✅ Preview Card — ຢູ່ຕຳແໜ່ງເກົ່າ (inline)
              //    ປ່ຽນເງື່ອນໄຂ: ສະແດງທັນທີເມື່ອມີ input ຫຍັງກໍ່ໄດ້
              //    (ເກົ່າແມ່ນ _previewReady = ຕ້ອງຄົບ 6 ຢ່າງ)
              // ══════════════════════════════════════════
              Obx(() {
                if (!_hasAnyInput) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: WoodProductPreviewCard(
                    existingImages: controller.existingImageUrls.toList(),
                    newImages: controller.selectedImages.toList(),
                    woodType: controller.woodTypeController.text.trim(),
                    name: controller.nameController.text.trim(),
                    width:
                        double.tryParse(
                          controller.widthController.text.trim(),
                        ) ??
                        0,
                    length:
                        double.tryParse(
                          controller.lengthController.text.trim(),
                        ) ??
                        0,
                    thickness:
                        double.tryParse(
                          controller.thicknessController.text.trim(),
                        ) ??
                        0,
                    sizeUnit: controller.selectedSizeUnit.value,
                    unit: controller.selectedUnit.value == 'ອື່ນໆ'
                        ? controller.customUnitController.text.trim()
                        : controller.selectedUnit.value,
                    price:
                        double.tryParse(
                          controller.priceController.text
                              .replaceAll(',', '')
                              .trim(),
                        ) ??
                        0,
                    isEditing: controller.editingProductId.value != null,
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ══════════════════════════════════════════
              // 🚀 ປຸ່ມ ບັນທຶກ/ຍົກເລີກ
              // ══════════════════════════════════════════
              Obx(() {
                if (controller.isSaving.value) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: controller.saveProgress.value > 0
                                ? controller.saveProgress.value / 100
                                : null,
                            backgroundColor: Colors.brown.shade50,
                            color: Colors.brown,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                controller.saveStep.value.isEmpty
                                    ? 'ກຳລັງບັນທຶກ...'
                                    : controller.saveStep.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            ),
                            Text(
                              '${controller.saveProgress.value}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.brown.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Row(
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
                          final dup = _findDuplicate();
                          if (dup != null) {
                            _showDuplicateDialog(dup);
                            return;
                          }

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
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section wrapper ───
  Widget _section({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    bool done = false,
  }) {
    final effectiveColor = done ? Colors.green.shade700 : color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: effectiveColor.withOpacity(done ? 0.5 : 0.25),
          width: done ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(done ? 0.12 : 0.06),
            blurRadius: done ? 10 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: effectiveColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: effectiveColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (done)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text(
                          'ສຳເລັດ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  // ─── Dialog duplicate ───
  void _showDuplicateDialog(WoodProductModel dup) {
    Get.defaultDialog(
      title: 'ມີສິນຄ້ານີ້ແລ້ວ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade800,
              size: 48,
            ),
            const SizedBox(height: 10),
            Text(
              'ສິນຄ້ານີ້ມີຢູ່ໃນລະບົບແລ້ວ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dupRow('ຊະນິດໄມ້', dup.woodType),
                  _dupRow('ຊື່ໄມ້', dup.name),
                  _dupRow(
                    'ຂະໜາດ',
                    '${_fmtNum(dup.width)}×${_fmtNum(dup.length)}×${_fmtNum(dup.thickness)} ${dup.sizeUnit}',
                  ),
                  _dupRow('ໜ່ວຍນັບ', dup.unit),
                  _dupRow(
                    'ລາຄາ',
                    '${NumberFormat('#,###').format(dup.price)} ກີບ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ກະລຸນາແກ້ໄຂຂໍ້ມູນໃຫ້ແຕກຕ່າງກ່ອນບັນທຶກ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      textConfirm: 'ຕົກລົງ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.brown,
      barrierDismissible: true,
      onConfirm: () => Get.back(),
    );
  }

  String _fmtNum(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

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

// ══════════════════════════════════════════════
// Helper widgets (top-level) — ຄົງເດີມ
// ══════════════════════════════════════════════

Widget _dupRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

Widget _suggestionChips({
  required List<String> items,
  required ValueChanged<String> onTap,
}) {
  if (items.isEmpty) return const SizedBox.shrink();

  final sorted = List<String>.from(items);

  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 13,
              color: Colors.brown.shade400,
            ),
            const SizedBox(width: 4),
            Text(
              'ເຄີຍປ້ອນ (${sorted.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: sorted.map((t) {
            return ActionChip(
              label: Text(
                t,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              backgroundColor: Colors.brown.shade50,
              side: BorderSide(color: Colors.brown.shade200),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () => onTap(t),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

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
