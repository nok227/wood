import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_controller.dart';

class RecipeFab extends StatelessWidget {
  final RecipeController controller;
  final VoidCallback onOpenForm;
  const RecipeFab({
    super.key,
    required this.controller,
    required this.onOpenForm,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final open = controller.fabOpen.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (open) ...[
            FloatingActionButton.extended(
              heroTag: 'btnAddRecipe',
              onPressed: () {
                controller.closeFab();
                onOpenForm();
              },
              backgroundColor: RecipeStyle.brown800,
              icon: const Icon(Icons.add, color: RecipeStyle.white),
              label: const Text(
                RecipeStyle.addRecipe,
                style: TextStyle(
                  color: RecipeStyle.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            RecipeStyle.gap10,
          ],
          FloatingActionButton(
            heroTag: 'btnMainFab',
            backgroundColor: RecipeStyle.brown800,
            onPressed: controller.toggleFab,
            child: Icon(
              open ? Icons.close : Icons.add,
              color: RecipeStyle.white,
            ),
          ),
        ],
      );
    });
  }
}