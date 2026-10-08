import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_form_controller.dart';

class RecipeFormIngredients extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormIngredients({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.ingredientCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.addIngredient(),
                decoration: const InputDecoration(
                  hintText: RecipeStyle.ingredientHint,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            RecipeStyle.gap6,
            IconButton.filled(
              onPressed: controller.addIngredient,
              style: IconButton.styleFrom(
                backgroundColor: RecipeStyle.primary,
              ),
              icon: const Icon(Icons.add, color: RecipeStyle.white),
            ),
          ],
        ),
        Obx(() {
          if (controller.ingredients.isEmpty) {
            return Padding(
              padding: RecipeStyle.padIngredientEmpty,
              child: Text(
                RecipeStyle.noIngredients,
                style: RecipeStyle.noIngredientsText,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: RecipeStyle.wrapSpacing,
              runSpacing: RecipeStyle.wrapRunSpacing,
              children: controller.ingredients.asMap().entries.map((e) {
                return Chip(
                  label: Text(e.value, style: RecipeStyle.chipTiny),
                  deleteIcon:
                      const Icon(Icons.close, size: RecipeStyle.iconSmMd),
                  onDeleted: () => controller.removeIngredient(e.key),
                  backgroundColor: RecipeStyle.brown50,
                  side: const BorderSide(color: RecipeStyle.brown200),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}