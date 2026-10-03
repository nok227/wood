import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/utils/currency_formatter.dart';
import 'package:wood/core/widgets/custom_app_bar.dart';
import '../../controllers/wood_product_controller.dart';
import '../../widgets/wood_product_preview_card.dart';
import '../../widgets/wood_form_section.dart';
import '../../widgets/wood_form_image_picker.dart';
import '../../widgets/wood_form_zone_selector.dart';

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
    controller.customZonesController,
    controller.noteController,
  ]);

  @override
  bool get wantKeepAlive => true;

  // ══════════════════════════════════════════════
  // 🔍 ກວດສອບສິນຄ້າຊ້ຳ
  // ══════════════════════════════════════════════
  Set<String> _normalizeZones(List<String> input) => input
      .map((z) => z.trim().toLowerCase())
      .where((z) => z.isNotEmpty)
      .toSet();

  bool _sameZones(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  bool _numEq(num a, String bStr) {
    final b = double.tryParse(bStr);
    if (b == null) return false;
    return (a - b).abs() < 0.001;
  }

  bool get _doneImages =>
      controller.existingImageUrls.isNotEmpty ||
      controller.selectedImages.isNotEmpty;

  bool get _doneWoodType =>
      controller.woodTypeController.text.trim().isNotEmpty;

  bool get _doneName => controller.nameController.text.trim().isNotEmpty;

  bool get _doneZone => controller.allZones.isNotEmpty;

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

  bool get _doneUnit {
    final u = controller.selectedUnit.value.trim();
    if (u.isEmpty) return false;
    if (u == 'ອື່ນໆ') {
      return controller.customUnitController.text.trim().isNotEmpty;
    }
    return true;
  }

  bool get _doneNote => controller.noteController.text.trim().isNotEmpty;

  bool get _hasAnyInput =>
      controller.woodTypeController.text.trim().isNotEmpty ||
      controller.nameController.text.trim().isNotEmpty ||
      controller.widthController.text.trim().isNotEmpty ||
      controller.lengthController.text.trim().isNotEmpty ||
      controller.thicknessController.text.trim().isNotEmpty ||
      controller.priceController.text.trim().isNotEmpty ||
      controller.selectedImages.isNotEmpty ||
      controller.existingImageUrls.isNotEmpty ||
      controller.selectedZones.isNotEmpty ||
      controller.customZonesController.text.trim().isNotEmpty ||
      controller.noteController.text.trim().isNotEmpty;

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
                () => WoodFormSection(
                  number: '1',
                  title: 'ຮູບໄມ້ (ສູງສຸດ 6 ຮູບ)',
                  icon: Icons.photo_library_outlined,
                  done: _doneImages,
                  child: WoodFormImagePicker(controller: controller),
                ),
              ),
              const SizedBox(height: 14),

              // ② ຊະນິດໄມ້
              WoodFormSection(
                number: '2',
                title: 'ຊະນິດໄມ້',
                icon: Icons.local_florist,
                done: _doneWoodType,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.woodTypeController,
                      decoration: _inputDeco('ຊະນິດໄມ້'),
                    ),
                    Obx(
                      () => _suggestion(
                        controller.uniqueWoodTypes,
                        (t) {
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
              WoodFormSection(
                number: '3',
                title: 'ຊື່ໄມ້',
                icon: Icons.inventory_2_outlined,
                done: _doneName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.nameController,
                      decoration: _inputDeco('ຊື່ໄມ້'),
                    ),
                    Obx(
                      () => _suggestion(
                        controller.uniqueProductNames,
                        (t) {
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

              // ④ ໂຊນ
              Obx(
                () => WoodFormSection(
                  number: '4',
                  title: 'ໂຊນ',
                  icon: Icons.place_outlined,
                  done: _doneZone,
                  warning: true,
                  child: WoodFormZoneSelector(controller: controller),
                ),
              ),
              const SizedBox(height: 14),

              // ⑤ ຂະໜາດ
              WoodFormSection(
                number: '5',
                title: 'ຂະໜາດ',
                icon: Icons.straighten,
                done: _doneSize,
                child: _sizeRow(),
              ),
              const SizedBox(height: 14),

              // ⑥ ຈຳນວນ + ໜ່ວຍນັບ
              Obx(
                () => WoodFormSection(
                  number: '6',
                  title: 'ຈຳນວນ ແລະ ໜ່ວຍນັບ',
                  icon: Icons.numbers,
                  done: _doneUnit,
                  child: _qtyUnitRow(),
                ),
              ),
              const SizedBox(height: 14),

              // ⑦ ລາຄາ
              WoodFormSection(
                number: '7',
                title: 'ລາຄາຂາຍ',
                icon: Icons.sell_outlined,
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
                  decoration: _inputDeco('ລາຄາຂາຍ xxx ກີບ')
                      .copyWith(suffixText: 'ກີບ '),
                ),
              ),
              const SizedBox(height: 14),

              // ⑧ ໝາຍເຫດ
              WoodFormSection(
                number: '8',
                title: 'ໝາຍເຫດ',
                icon: Icons.sticky_note_2_outlined,
                done: _doneNote,
                warning: true,
                child: TextField(
                  controller: controller.noteController,
                  maxLines: 4,
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: _inputDeco(
                    'ໝາຍເຫດເພີ່ມເຕີມ (ຖ້າມີ) — ເຊັ່ນ ສີໄມ້, ຄຸນນະພາບ, ຂໍ້ຄວນລະວັງ',
                  ).copyWith(alignLabelWithHint: true),
                ),
              ),

              // Preview
              Obx(() {
                if (!_hasAnyInput) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: WoodProductPreviewCard(
                    existingImages: controller.existingImageUrls.toList(),
                    newImages: controller.selectedImages.toList(),
                    woodType: controller.woodTypeController.text.trim(),
                    name: controller.nameController.text.trim(),
                    width: double.tryParse(
                          controller.widthController.text.trim(),
                        ) ??
                        0,
                    length: double.tryParse(
                          controller.lengthController.text.trim(),
                        ) ??
                        0,
                    thickness: double.tryParse(
                          controller.thicknessController.text.trim(),
                        ) ??
                        0,
                    sizeUnit: controller.selectedSizeUnit.value,
                    unit: controller.selectedUnit.value == 'ອື່ນໆ'
                        ? controller.customUnitController.text.trim()
                        : controller.selectedUnit.value,
                    price: double.tryParse(
                          controller.priceController.text
                              .replaceAll(',', '')
                              .trim(),
                        ) ??
                        0,
                    zones: controller.allZones,
                    isEditing: controller.editingProductId.value != null,
                    note: controller.noteController.text.trim(),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ປຸ່ມ ບັນທຶກ/ຍົກເລີກ
              Obx(() {
                if (controller.isSaving.value) return _savingBox();
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
                        onPressed: _onSave,
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
                          if (widget.isPage) Get.back();
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

  Widget _sizeRow() {
    return Column(
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
                decoration: _inputDeco('ກວ້າງ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.lengthController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDeco('ຍາວ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.thicknessController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDeco('ໜາ'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedSizeUnit.value,
            isExpanded: true,
            decoration: _inputDeco('ໜ່ວຍຂະໜາດ'),
            items: controller.sizeUnitOptions
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.selectedSizeUnit.value = v;
            },
          ),
        ),
      ],
    );
  }

  Widget _qtyUnitRow() {
    return Column(
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
                decoration: _inputDeco('ຈຳນວນ').copyWith(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: controller.selectedUnit.value.isEmpty
                    ? null
                    : controller.selectedUnit.value,
                isExpanded: true,
                hint: Text(
                  'ເລືອກໜ່ວຍນັບ',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                decoration: _inputDeco('ໜ່ວຍນັບ'),
                items: controller.unitOptions
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedUnit.value = v;
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
              decoration: _inputDeco('ລະບຸໜ່ວຍນັບ'),
            ),
          ),
      ],
    );
  }

  Widget _savingBox() {
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

  Future<void> _onSave() async {
    final isEditing = controller.editingProductId.value != null;
    final ok = await controller.saveProduct();
    if (ok) {
      if (widget.isPage) Get.back();
      Get.snackbar('ສຳເລັດ',
          isEditing ? 'ແກ້ໄຂຂໍ້ມູນແລ້ວ' : 'ບັນທຶກຂໍ້ມູນແລ້ວ');
    }
  }

  Widget _suggestion(List<String> items, ValueChanged<String> onTap) {
    if (items.isEmpty) return const SizedBox.shrink();
    final sorted = List<String>.from(items);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 13, color: Colors.brown.shade400),
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
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () => onTap(t),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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