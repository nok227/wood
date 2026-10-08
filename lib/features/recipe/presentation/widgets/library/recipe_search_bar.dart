import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_controller.dart';

class RecipeSearchBar extends StatelessWidget {
  final RecipeController controller;
  const RecipeSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RecipeStyle.padSearchBar,
      child: TextField(
        controller: controller.searchCtrl,
        onChanged: (v) => controller.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: RecipeStyle.searchHint,
          prefixIcon:
              const Icon(Icons.search, color: RecipeStyle.primary),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: RecipeStyle.iconSm),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          isDense: true,
          filled: true,
          fillColor: RecipeStyle.white,
          border: const OutlineInputBorder(
            borderRadius: RecipeStyle.r12,
            borderSide: BorderSide(color: RecipeStyle.brown200),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: RecipeStyle.r12,
            borderSide: BorderSide(color: RecipeStyle.brown200),
          ),
        ),
      ),
    );
  }
}