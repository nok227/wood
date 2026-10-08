import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import '../../controllers/wood_product_controller.dart';
import 'wood_form_input_deco.dart';

class WoodFormSizeRow extends StatelessWidget {
  final WoodProductController controller;
  const WoodFormSizeRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.widthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: WoodFormInputDeco.build(WoodStyle.width),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.lengthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: WoodFormInputDeco.build(WoodStyle.length),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.thicknessController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: WoodFormInputDeco.build(WoodStyle.thickness),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => DropdownButtonFormField<String>(
              initialValue: controller.selectedSizeUnit.value,
              isExpanded: true,
              decoration: WoodFormInputDeco.build(WoodStyle.sizeUnitLabel),
              items: controller.sizeUnitOptions
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.selectedSizeUnit.value = v;
              },
            )),
      ],
    );
  }
}