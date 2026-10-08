import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_form_controller.dart';

class RecipeFormBottomBar extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: RecipeStyle.padBottomBar,
        decoration: BoxDecoration(
          color: RecipeStyle.white,
          boxShadow: RecipeStyle.bottomBarShadow,
        ),
        child: Obx(() {
          final saving = controller.saving.value;
          return ElevatedButton.icon(
            onPressed: saving ? null : controller.save,
            style: ElevatedButton.styleFrom(
              backgroundColor: RecipeStyle.primary,
              foregroundColor: RecipeStyle.white,
              padding: RecipeStyle.padBottomBarBtn,
              shape: const RoundedRectangleBorder(
                borderRadius: RecipeStyle.r12,
              ),
              elevation: 0,
            ),
            icon: saving
                ? const SizedBox(
                    width: RecipeStyle.spinnerSmall,
                    height: RecipeStyle.spinnerSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: RecipeStyle.spinnerStroke,
                      color: RecipeStyle.white,
                    ),
                  )
                : const Icon(Icons.save, size: RecipeStyle.iconMdLg),
            label: Text(
              saving
                  ? RecipeStyle.saving
                  : (controller.isEdit
                      ? RecipeStyle.saveEditBtn
                      : RecipeStyle.saveNewBtn),
              style: RecipeStyle.saveBtnText,
            ),
          );
        }),
      ),
    );
  }
}