import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_form_controller.dart';
import '../../widgets/form/recipe_form_basic.dart';
import '../../widgets/form/recipe_form_bottom_bar.dart';
import '../../widgets/form/recipe_form_images.dart';
import '../../widgets/form/recipe_form_ingredients.dart';
import '../../widgets/form/recipe_form_section.dart';
import '../../widgets/form/recipe_form_status.dart';
import '../../widgets/form/recipe_form_steps.dart';

class RecipeFormPage extends StatelessWidget {
  final RecipeEntity? existing;
  const RecipeFormPage({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RecipeFormController(existing: existing));

    return Scaffold(
      backgroundColor: RecipeStyle.bg,
      appBar: AppBar(
        title: Text(
          c.isEdit ? RecipeStyle.formTitleEdit : RecipeStyle.formTitleAdd,
        ),
        backgroundColor: RecipeStyle.primary,
        foregroundColor: RecipeStyle.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: RecipeStyle.padFormPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecipeFormSection(
                number: '1',
                title: RecipeStyle.sectionBasic,
                icon: Icons.restaurant,
                child: RecipeFormBasic(controller: c),
              ),
              RecipeStyle.gap14,
              RecipeFormSection(
                number: '2',
                title: RecipeStyle.sectionIngredients,
                icon: Icons.egg_alt_outlined,
                child: RecipeFormIngredients(controller: c),
              ),
              RecipeStyle.gap14,
              RecipeFormSection(
                number: '3',
                title: RecipeStyle.sectionSteps,
                icon: Icons.menu_book_outlined,
                child: RecipeFormSteps(controller: c),
              ),
              RecipeStyle.gap14,
              RecipeFormSection(
                number: '4',
                title: RecipeStyle.sectionStatus,
                icon: Icons.star_outline,
                child: RecipeFormStatus(controller: c),
              ),
              RecipeStyle.gap14,
              RecipeFormSection(
                number: '5',
                title: RecipeStyle.sectionImages,
                icon: Icons.photo_library_outlined,
                child: RecipeFormImages(controller: c),
              ),
              RecipeStyle.gap14,
              RecipeFormSection(
                number: '6',
                title: RecipeStyle.sectionNote,
                icon: Icons.sticky_note_2_outlined,
                child: TextField(
                  controller: c.noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: RecipeStyle.noteHint,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RecipeFormBottomBar(controller: c),
    );
  }
}