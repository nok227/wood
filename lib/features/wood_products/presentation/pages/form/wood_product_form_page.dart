import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/wood_style.dart';
import 'package:wood/core/utils/currency_formatter.dart';
import 'package:wood/core/widgets/shared/custom_app_bar.dart';
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

  // ══════════════════════════════════════════
  // ✅ Done getters
  // ══════════════════════════════════════════
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
    if (u == WoodStyle.unitOther) {
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
      backgroundColor: WoodStyle.bg,
      appBar: widget.isPage
          ? CustomAppBar(
              titleWidget: Obx(
                () => Text(
                  controller.editingProductId.value == null
                      ? WoodStyle.formTitleAdd
                      : WoodStyle.formTitleEdit,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: WoodStyle.padForm,
        child: ListenableBuilder(
          listenable: _formListenable,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ① ຮູບໄມ້
              Obx(
                () => WoodFormSection(
                  number: '1',
                  title: WoodStyle.secImages,
                  icon: Icons.photo_library_outlined,
                  done: _doneImages,
                  child: WoodFormImagePicker(controller: controller),
                ),
              ),
              WoodStyle.gapLg,

              // ② ຊະນິດໄມ້
              WoodFormSection(
                number: '2',
                title: WoodStyle.secWoodType,
                icon: Icons.local_florist,
                done: _doneWoodType,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.woodTypeController,
                      decoration: _inputDeco(WoodStyle.secWoodType),
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
              WoodStyle.gapLg,

              // ③ ຊື່ໄມ້
              WoodFormSection(
                number: '3',
                title: WoodStyle.secName,
                icon: Icons.inventory_2_outlined,
                done: _doneName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.nameController,
                      decoration: _inputDeco(WoodStyle.secName),
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
              WoodStyle.gapLg,

              // ④ ໂຊນ
              Obx(
                () => WoodFormSection(
                  number: '4',
                  title: WoodStyle.secZone,
                  icon: Icons.place_outlined,
                  done: _doneZone,
                  warning: true,
                  child: WoodFormZoneSelector(controller: controller),
                ),
              ),
              WoodStyle.gapLg,

              // ⑤ ຂະໜາດ
              WoodFormSection(
                number: '5',
                title: WoodStyle.secSize,
                icon: Icons.straighten,
                done: _doneSize,
                child: _sizeRow(),
              ),
              WoodStyle.gapLg,

              // ⑥ ຈຳນວນ + ໜ່ວຍນັບ
              Obx(
                () => WoodFormSection(
                  number: '6',
                  title: WoodStyle.secQtyUnit,
                  icon: Icons.numbers,
                  done: _doneUnit,
                  child: _qtyUnitRow(),
                ),
              ),
              WoodStyle.gapLg,

              // ⑦ ລາຄາ
              WoodFormSection(
                number: '7',
                title: WoodStyle.secPrice,
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
                  decoration: _inputDeco(WoodStyle.priceLabelInput)
                      .copyWith(suffixText: '${WoodStyle.currency} '),
                ),
              ),
              WoodStyle.gapLg,

              // ⑧ ໝາຍເຫດ
              WoodFormSection(
                number: '8',
                title: WoodStyle.secNote,
                icon: Icons.sticky_note_2_outlined,
                done: _doneNote,
                warning: true,
                child: TextField(
                  controller: controller.noteController,
                  maxLines: 4,
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: _inputDeco(WoodStyle.noteHint)
                      .copyWith(alignLabelWithHint: true),
                ),
              ),

              // ── Preview ──
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
                    unit: controller.selectedUnit.value == WoodStyle.unitOther
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

              // ── ປຸ່ມ ບັນທຶກ/ຍົກເລີກ ──
              Obx(() {
                if (controller.isSaving.value) return _savingBox();
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(WoodStyle.buttonHeight),
                          elevation: 0,
                          backgroundColor: WoodStyle.blueAccent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: WoodStyle.r12,
                          ),
                        ),
                        onPressed: _onSave,
                        child: Text(
                          controller.editingProductId.value == null
                              ? WoodStyle.saveAdd
                              : WoodStyle.saveEdit,
                          style: const TextStyle(
                            color: WoodStyle.white,
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
                          minimumSize:
                              const Size.fromHeight(WoodStyle.buttonHeight),
                          side: const BorderSide(color: WoodStyle.grey300),
                          shape: const RoundedRectangleBorder(
                            borderRadius: WoodStyle.r12,
                          ),
                          backgroundColor: WoodStyle.white,
                        ),
                        onPressed: () {
                          controller.cancelEdit();
                          if (widget.isPage) Get.back();
                        },
                        child: const Text(
                          WoodStyle.cancel,
                          style: TextStyle(
                            color: WoodStyle.grey700,
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

  // ══════════════════════════════════════════
  // 📐 ຂະໜາດ
  // ══════════════════════════════════════════
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
                decoration: _inputDeco(WoodStyle.width),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.lengthController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDeco(WoodStyle.length),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.thicknessController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDeco(WoodStyle.thickness),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedSizeUnit.value,
            isExpanded: true,
            decoration: _inputDeco(WoodStyle.sizeUnitLabel),
            items: controller.sizeUnitOptions
                .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) controller.selectedSizeUnit.value = v;
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // 🔢 ຈຳນວນ + ໜ່ວຍນັບ
  // ══════════════════════════════════════════
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
                decoration: _inputDeco(WoodStyle.qtyLabel).copyWith(
                  filled: true,
                  fillColor: WoodStyle.grey100,
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
                hint: const Text(
                  WoodStyle.unitHint,
                  style: TextStyle(
                    color: WoodStyle.grey500,
                    fontSize: 14,
                  ),
                ),
                decoration: _inputDeco(WoodStyle.unitLabel),
                items: controller.unitOptions
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child:
                              Text(u, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedUnit.value = v;
                },
              ),
            ),
          ],
        ),
        if (controller.selectedUnit.value == WoodStyle.unitOther)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: controller.customUnitController,
              decoration: _inputDeco(WoodStyle.customUnit),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // ⏳ Saving box
  // ══════════════════════════════════════════
  Widget _savingBox() {
    return Container(
      padding: WoodStyle.padForm,
      decoration: BoxDecoration(
        color: WoodStyle.white,
        borderRadius: WoodStyle.r12,
        border: Border.all(color: WoodStyle.brown200),
        boxShadow: [
          BoxShadow(
            color: WoodStyle.brown700.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: WoodStyle.r4,
            child: LinearProgressIndicator(
              value: controller.saveProgress.value > 0
                  ? controller.saveProgress.value / 100
                  : null,
              backgroundColor: WoodStyle.brown50,
              color: WoodStyle.brown700,
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
                  color: WoodStyle.brown700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.saveStep.value.isEmpty
                      ? WoodStyle.savingProgress
                      : controller.saveStep.value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: WoodStyle.brown800,
                  ),
                ),
              ),
              Text(
                '${controller.saveProgress.value}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: WoodStyle.brown800,
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
      Get.snackbar(
        WoodStyle.successMsg,
        isEditing ? WoodStyle.savedEdit : WoodStyle.savedNew,
      );
    }
  }

  // ══════════════════════════════════════════
  // 💡 Suggestion chips
  // ══════════════════════════════════════════
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
              const Icon(Icons.lightbulb_outline,
                  size: 13, color: WoodStyle.brown400),
              const SizedBox(width: 4),
              Text(
                '${WoodStyle.prevInput} (${sorted.length})',
                style: WoodStyle.suggestionHeader,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.map((t) {
              return ActionChip(
                label: Text(t, style: WoodStyle.suggestionChip),
                backgroundColor: WoodStyle.brown50,
                side: const BorderSide(color: WoodStyle.brown200),
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

  // ══════════════════════════════════════════
  // 🎨 Input decoration
  // ══════════════════════════════════════════
  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: WoodStyle.formLabel,
        filled: true,
        fillColor: WoodStyle.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: const OutlineInputBorder(
          borderRadius: WoodStyle.r12,
          borderSide: BorderSide(color: WoodStyle.grey300, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: WoodStyle.r12,
          borderSide: BorderSide(color: WoodStyle.black87, width: 1.5),
        ),
      );
}