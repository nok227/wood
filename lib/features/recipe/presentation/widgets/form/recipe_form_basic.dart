import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_form_controller.dart';

class RecipeFormBasic extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormBasic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.nameCtrl,
          decoration: InputDecoration(
            labelText: RecipeStyle.nameLabel,
            border: const OutlineInputBorder(),
            prefixIcon:
                const Icon(Icons.restaurant, color: RecipeStyle.primary),
            hintText: RecipeStyle.nameHint,
          ),
        ),
        RecipeStyle.gap12,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(RecipeStyle.suggestionLabel,
              style: RecipeStyle.fieldHint),
        ),
        RecipeStyle.gap6,
        Wrap(
          spacing: RecipeStyle.wrapSpacing,
          runSpacing: RecipeStyle.wrapRunSpacing,
          children: RecipeStyle.nameSuggestions
              .map((text) => ActionChip(
                    label: Text(text,
                        style: RecipeStyle.chipText
                            .copyWith(color: RecipeStyle.primary)),
                    backgroundColor: RecipeStyle.white,
                    side: const BorderSide(color: RecipeStyle.brown200),
                    onPressed: () => controller.insertNameSuggestion(text),
                  ))
              .toList(),
        ),
        RecipeStyle.gap14,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(RecipeStyle.categoryLabel,
              style: RecipeStyle.fieldHint),
        ),
        RecipeStyle.gap6,
        DropdownButtonFormField<RecipeCategory>(
          initialValue: controller.category.value,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: RecipeStyle.padDropdown,
            prefixIcon: Icon(Icons.category, color: RecipeStyle.primary),
          ),
          items: RecipeCategory.values
              .map((cat) => DropdownMenuItem<RecipeCategory>(
                    value: cat,
                    child: Text('${cat.emoji} ${cat.label}',
                        style: RecipeStyle.dropdownItemText),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setCategory(v);
          },
        ),
      ],
    );
  }
}