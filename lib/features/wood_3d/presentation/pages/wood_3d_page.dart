import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/wood_3d_style.dart';

import '../controllers/wood_3d_controller.dart';
import '../widgets/filters/wood_3d_filter_panel.dart';
import '../widgets/wood_3d_scene.dart';

class Wood3DPage extends StatelessWidget {
  final ValueNotifier<bool>? swipeLock;
  const Wood3DPage({super.key, this.swipeLock});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(Wood3DController(swipeLock: swipeLock));

    return Scaffold(
      body: Obx(() {
        ctrl.recomputeIfNeeded();
        ctrl.syncSwipeLock();

        final v = ctrl.selectedVariant.value;

        return Column(
          children: [
            Expanded(
              child: v != null
                  ? RepaintBoundary(
                      child: Wood3DScene(
                        key: ValueKey(v.id),
                        productName: v.name,
                        width: v.width,
                        length: v.length,
                        thickness: v.thickness,
                        sizeUnit: v.sizeUnit,
                        unit: v.unit,
                        focusedDimension: ctrl.focusedDimension.value,
                        showColor: ctrl.showColor.value,
                        onToggleColor: ctrl.toggleColor,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      color: Wood3DStyle.brown50,
                      child: const Center(
                        child: Text(
                          Wood3DStyle.wood3dPlaceholder,
                          style: Wood3DStyle.txPlaceholder,
                        ),
                      ),
                    ),
            ),
            Wood3DFilterPanel(ctrl: ctrl),
          ],
        );
      }),
    );
  }
}