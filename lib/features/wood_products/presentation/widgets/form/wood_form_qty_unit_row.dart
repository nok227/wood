import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import '../../controllers/wood_product_controller.dart';
import 'wood_form_input_deco.dart';

class WoodFormQtyUnitRow extends StatelessWidget {
  final WoodProductController controller;
  const WoodFormQtyUnitRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                decoration: WoodFormInputDeco.build(WoodStyle.qtyLabel).copyWith(
                  filled: true,
                  fillColor: WoodStyle.grey100,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: controller.selectedUnit.value.isEmpty
                    ? null
                    : controller.selectedUnit.value,
                isExpanded: true,
                hint: const Text(
                  WoodStyle.unitHint,
                  style: TextStyle(color: WoodStyle.grey500, fontSize: 14),
                ),
                decoration: WoodFormInputDeco.build(WoodStyle.unitLabel),
                items: controller.unitOptions
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u, overflow: TextOverflow.ellipsis),
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
              decoration: WoodFormInputDeco.build(WoodStyle.customUnit),
            ),
          ),
      ],
    );
  }
}