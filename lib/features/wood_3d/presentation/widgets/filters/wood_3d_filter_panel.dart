import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/wood_3d_style.dart';

import '../../controllers/wood_3d_controller.dart';
import 'wood_3d_chip_row.dart';
import 'wood_3d_variant_info_card.dart';

class Wood3DFilterPanel extends StatelessWidget {
  final Wood3DController ctrl;
  const Wood3DFilterPanel({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = ctrl.panelExpanded.value;
      final hasSelection = ctrl.hasSelection;

      return AnimatedSize(
        duration: Wood3DStyle.normal,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Wood3DStyle.white,
            boxShadow: [
              BoxShadow(
                color: Wood3DStyle.black
                    .withValues(alpha: Wood3DStyle.panelShadowOpacity),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(expanded),
              if (expanded) ...[
                if (hasSelection)
                  Padding(
                    padding: Wood3DStyle.padPanelRow,
                    child: Row(
                      children: [
                        Expanded(
                          child: _dimBtn(
                            Wood3DStyle.dimWidth,
                            'width',
                          ),
                        ),
                        Wood3DStyle.gap8,
                        Expanded(
                          child: _dimBtn(
                            Wood3DStyle.dimLength,
                            'length',
                          ),
                        ),
                        Wood3DStyle.gap8,
                        Expanded(
                          child: _dimBtn(
                            Wood3DStyle.dimThickness,
                            'thickness',
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: Wood3DStyle.padPanelBottom,
                  child: _content(),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ── Handle ──
  Widget _handle(bool expanded) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ctrl.togglePanel,
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 200 && expanded) {
          ctrl.togglePanel();
        } else if (v < -200 && !expanded) {
          ctrl.togglePanel();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: Wood3DStyle.panelHandlePadV,
        ),
        color: Wood3DStyle.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Wood3DStyle.sliderHandleW,
              height: Wood3DStyle.sliderHandleH,
              decoration: BoxDecoration(
                color: Wood3DStyle.grey400,
                borderRadius: Wood3DStyle.r2,
              ),
            ),
            Wood3DStyle.gap4,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: Wood3DStyle.iconStar14,
                  color: Wood3DStyle.grey500,
                ),
                Wood3DStyle.gap4,
                Text(
                  expanded ? Wood3DStyle.panelHide : Wood3DStyle.panelShow,
                  style: Wood3DStyle.txPanelHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dim buttons ──
  Widget _dimBtn(String label, String value) {
    final active = ctrl.focusedDimension.value == value;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? Wood3DStyle.brown700 : null,
        foregroundColor:
            active ? Wood3DStyle.white : Wood3DStyle.brown700,
        side: const BorderSide(color: Wood3DStyle.brown700),
      ),
      onPressed: () => ctrl.focusDimension(active ? null : value),
      child: Text(label),
    );
  }

  // ── Content ──
  Widget _content() {
    final products = ctrl.products.products;

    if (products.isEmpty) {
      return const Padding(
        padding: Wood3DStyle.padEmpty,
        child: Text(
          Wood3DStyle.noProductsForm,
          style: Wood3DStyle.txPlaceholder,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(Wood3DStyle.woodTypeLabel, Icons.local_florist),
        Wood3DStyle.gap6,
        Wood3DChipRow(
          options: ctrl.woodTypeOptions,
          selected: ctrl.selectedWoodType.value,
          onSelected: ctrl.pickWoodType,
        ),
        Wood3DStyle.gap12,
        _label(Wood3DStyle.unitLabel, Icons.straighten),
        Wood3DStyle.gap6,
        Wood3DChipRow(
          options: ctrl.unitOptions,
          selected: ctrl.selectedUnitFilter.value,
          onSelected: ctrl.pickUnit,
        ),
        Wood3DStyle.gap12,
        _label(Wood3DStyle.nameLabel, Icons.inventory_2_outlined),
        Wood3DStyle.gap6,
        _nameDropdown(),
        if (ctrl.selectedName.value != null &&
            ctrl.variants.isNotEmpty) ...[
          Wood3DStyle.gap12,
          Wood3DVariantInfoCard(
            variant: ctrl.selectedVariant.value!,
            variants: ctrl.variants,
            onVariantChanged: (v) {
              if (v != null) ctrl.pickVariant(v);
            },
          ),
        ],
        if (ctrl.hasAnyChoice) ...[
          Wood3DStyle.gap6,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: ctrl.clearAll,
              icon: const Icon(
                Icons.clear_all,
                size: Wood3DStyle.iconStar14,
              ),
              label: const Text(
                Wood3DStyle.clearSelection,
                style: Wood3DStyle.txClearBtn,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Wood3DStyle.error700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            size: Wood3DStyle.iconStar14, color: Wood3DStyle.brown500),
        Wood3DStyle.gap5,
        Text(text, style: Wood3DStyle.txSectionLabel),
      ],
    );
  }

  Widget _nameDropdown() {
    final list = ctrl.names;
    final isEmpty = list.isEmpty;

    return DropdownButtonFormField<String>(
      initialValue: ctrl.selectedName.value,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        hintText: isEmpty
            ? Wood3DStyle.noNameInCategory
            : Wood3DStyle.pickWoodName,
        hintStyle: const TextStyle(
          color: Wood3DStyle.grey500,
          fontSize: 13,
        ),
        isDense: true,
        filled: true,
        fillColor: Wood3DStyle.brown50
            .withValues(alpha: Wood3DStyle.dropdownFillOpacity),
        contentPadding: Wood3DStyle.padDropdown,
        border: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown200),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown500, width: 1.5),
        ),
      ),
      items: list
          .map(
            (n) => DropdownMenuItem(
              value: n,
              child: Text(n, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: isEmpty ? null : ctrl.pickName,
    );
  }
}