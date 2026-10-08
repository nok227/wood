import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_controller.dart';

class RecipeStatsRow extends StatelessWidget {
  final RecipeController controller;
  const RecipeStatsRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.allRecipes.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: RecipeStyle.padStatsRow,
        child: Row(
          children: [
            _Bubble('${controller.totalCount}', RecipeStyle.statAll,
                RecipeStyle.brown600),
            RecipeStyle.gap6,
            _Bubble('${controller.wantCount}', RecipeStyle.statWant,
                RecipeStyle.amber800),
            RecipeStyle.gap6,
            _Bubble('${controller.neverCount}', RecipeStyle.statNever,
                RecipeStyle.grey600),
          ],
        ),
      );
    });
  }
}

class _Bubble extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Bubble(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RecipeStyle.padStatBubble,
      decoration: BoxDecoration(
        color: color.withValues(alpha: RecipeStyle.bubbleOpacity),
        borderRadius: RecipeStyle.r20,
        border: Border.all(
          color: color.withValues(alpha: RecipeStyle.bubbleBorderOpacity),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: RecipeStyle.statBubbleValue.copyWith(color: color)),
          RecipeStyle.gap4,
          Text(label,
              style: RecipeStyle.statBubbleLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}