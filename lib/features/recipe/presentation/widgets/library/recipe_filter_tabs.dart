import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_controller.dart';

class RecipeFilterTabs extends StatelessWidget {
  final RecipeController controller;
  const RecipeFilterTabs({super.key, required this.controller});

  static const items = [
    ('all', RecipeStyle.filterAll),
    ('want', RecipeStyle.filterWant),
    ('tried', RecipeStyle.filterTried),
    ('never', RecipeStyle.filterNever),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: RecipeStyle.padFilterTabs,
        child: Row(
          children: items.map((e) {
            final selected = controller.selectedStatus.value == e.$1;
            return Expanded(
              child: Padding(
                padding: RecipeStyle.padFilterChip,
                child: InkWell(
                  onTap: () => controller.selectedStatus.value = e.$1,
                  borderRadius: RecipeStyle.r8,
                  child: Container(
                    padding: RecipeStyle.padVertical6,
                    decoration: BoxDecoration(
                      color: selected
                          ? RecipeStyle.primary
                          : RecipeStyle.white,
                      borderRadius: RecipeStyle.r8,
                      border: Border.all(
                        color: selected
                            ? RecipeStyle.brown800
                            : RecipeStyle.brown200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        e.$2,
                        style: RecipeStyle.statusTab.copyWith(
                          fontSize: 11,
                          color: selected
                              ? RecipeStyle.white
                              : RecipeStyle.brown800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}