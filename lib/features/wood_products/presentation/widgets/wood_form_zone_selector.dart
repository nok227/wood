import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/widgets/dashed_divider.dart';
import '../controllers/wood_product_controller.dart';

class WoodFormZoneSelector extends StatelessWidget {
  final WoodProductController controller;
  const WoodFormZoneSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (
            int i = 0;
            i < WoodProductController.zoneLetters.length;
            i++
          ) ...[
            _zoneRow(WoodProductController.zoneLetters[i]),
            if (i < WoodProductController.zoneLetters.length - 1) ...[
              const SizedBox(height: 4),
              const DashedDivider(
                dashWidth: 5,
                dashSpace: 4,
                height: 1,
                color: Color(0xFFD7CCC8),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 4),
            ],
          ],
          if (controller.allZones.isNotEmpty) ...[
            const SizedBox(height: 10),
            _selectedPanel(),
          ],
        ],
      ),
    );
  }

  Widget _zoneRow(String letter) {
    final selected = controller.selectedZones.toSet();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              letter.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (
                int i = 1;
                i <= WoodProductController.zoneNumbersPerLetter;
                i++
              )
                _chip(
                  label: '$letter$i',
                  selected: selected.contains('$letter$i'),
                  onTap: () => controller.toggleZone('$letter$i'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.brown.shade700 : Colors.brown.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.brown.shade700 : Colors.brown.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.brown.shade700,
          ),
        ),
      ),
    );
  }

  Widget _selectedPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade300, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.green.shade800),
              const SizedBox(width: 5),
              Text(
                'ເລືອກແລ້ວ ${controller.allZones.length} ໂຊນ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: controller.allZones
                .map(
                  (z) => GestureDetector(
                    onTap: () => controller.removeZone(z),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            z,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.close,
                            size: 11,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
