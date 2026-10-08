import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import '../../controllers/wood_product_controller.dart';

class WoodFormSavingBox extends StatelessWidget {
  final WoodProductController controller;
  const WoodFormSavingBox({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
}