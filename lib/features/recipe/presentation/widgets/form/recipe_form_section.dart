import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

class RecipeFormSection extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Widget child;

  const RecipeFormSection({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RecipeStyle.white,
        borderRadius: RecipeStyle.sectionRadius,
        border: Border.all(
          color: RecipeStyle.brown200,
          width: RecipeStyle.borderWidthNormal,
        ),
        boxShadow: RecipeStyle.sectionShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: RecipeStyle.padSectionHeader,
            decoration: const BoxDecoration(
              color: RecipeStyle.brown50,
              borderRadius: RecipeStyle.topR13,
            ),
            child: Row(
              children: [
                Container(
                  width: RecipeStyle.sectionNumberSize,
                  height: RecipeStyle.sectionNumberSize,
                  decoration: const BoxDecoration(
                    color: RecipeStyle.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(number, style: RecipeStyle.sectionNumber),
                  ),
                ),
                RecipeStyle.gapSm,
                Icon(icon,
                    color: RecipeStyle.primary, size: RecipeStyle.iconMdSm),
                RecipeStyle.gap6,
                Expanded(
                  child: Text(title, style: RecipeStyle.sectionTitle),
                ),
              ],
            ),
          ),
          Padding(padding: RecipeStyle.padSection, child: child),
        ],
      ),
    );
  }
}