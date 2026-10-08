import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

class RecipeEmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClearFilter;
  const RecipeEmptyState({
    super.key,
    required this.hasFilter,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        RecipeStyle.gap80,
        const Icon(
          Icons.restaurant_menu,
          size: RecipeStyle.emptyIconLg,
          color: RecipeStyle.brown200,
        ),
        RecipeStyle.gap12,
        Center(
          child: Text(
            hasFilter ? RecipeStyle.notFound : RecipeStyle.emptyLibrary,
            style: RecipeStyle.emptyTitle,
          ),
        ),
        if (hasFilter) ...[
          RecipeStyle.gap12,
          Center(
            child: TextButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(Icons.clear_all, size: RecipeStyle.iconSm),
              label: const Text(RecipeStyle.clearFilter),
            ),
          ),
        ] else ...[
          RecipeStyle.gap12,
          const Center(
            child: Text(
              RecipeStyle.addFirstHint,
              style: RecipeStyle.emptyHint,
            ),
          ),
        ],
      ],
    );
  }
}