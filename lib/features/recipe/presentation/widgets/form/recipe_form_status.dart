import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_form_controller.dart';

class RecipeFormStatus extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormStatus({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Row(
              children: RecipeStatus.values.map((s) {
                final sel = controller.status.value == s;
                return Expanded(
                  child: Padding(
                    padding: RecipeStyle.padFilterChip,
                    child: InkWell(
                      onTap: () => controller.setStatus(s),
                      borderRadius: RecipeStyle.r10,
                      child: Container(
                        padding: RecipeStyle.padVertical10,
                        decoration: BoxDecoration(
                          color: sel
                              ? RecipeStyle.primary
                              : RecipeStyle.white,
                          borderRadius: RecipeStyle.r10,
                          border: Border.all(
                            color: sel
                                ? RecipeStyle.brown800
                                : RecipeStyle.grey300,
                            width: sel
                                ? RecipeStyle.borderWidthActive
                                : RecipeStyle.borderWidthNormal,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s.label,
                            style: RecipeStyle.statusTab.copyWith(
                              color: sel
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
            )),
        RecipeStyle.gap14,
        Text(RecipeStyle.ratingLabel, style: RecipeStyle.ratingLabelStyle),
        RecipeStyle.gap6,
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final on = i < controller.rating.value;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: RecipeStyle.starBtnConstraints,
                  onPressed: () {
                    final newVal =
                        (on && i + 1 == controller.rating.value) ? 0 : i + 1;
                    controller.setRating(newVal);
                  },
                  icon: Icon(
                    on ? Icons.star : Icons.star_border,
                    color: on
                        ? RecipeStyle.amber700
                        : RecipeStyle.grey400,
                    size: RecipeStyle.starSize,
                  ),
                );
              }),
            )),
      ],
    );
  }
}