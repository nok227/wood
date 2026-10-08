import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/recipe_form_controller.dart';
import '../../widgets/library/recipe_empty_state.dart';
import '../../widgets/library/recipe_fab.dart';
import '../../widgets/library/recipe_filter_tabs.dart';
import '../../widgets/library/recipe_search_bar.dart';
import '../../widgets/library/recipe_stats_row.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/recipe_list_skeleton.dart';
import '../form/recipe_form_page.dart';

class RecipeLibraryPage extends StatelessWidget {
  const RecipeLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RecipeController>();

    return Scaffold(
      backgroundColor: RecipeStyle.bg,
      appBar: AppBar(
        title: const Text(RecipeStyle.libraryTitle),
        backgroundColor: RecipeStyle.primary,
        foregroundColor: RecipeStyle.white,
        actions: [
          PopupMenuButton<RecipeSortBy>(
            icon: const Icon(Icons.sort, color: RecipeStyle.white),
            onSelected: (v) => c.sortBy.value = v,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: RecipeSortBy.leastRecentlyEaten,
                child: Text(RecipeStyle.sortLeastRecent),
              ),
              PopupMenuItem(
                value: RecipeSortBy.newest,
                child: Text(RecipeStyle.sortNewest),
              ),
              PopupMenuItem(
                value: RecipeSortBy.highestRating,
                child: Text(RecipeStyle.sortHighestRating),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          RecipeSearchBar(controller: c),
          RecipeFilterTabs(controller: c),
          RecipeStatsRow(controller: c),
          Expanded(child: _Body(controller: c)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: RecipeFab(
        controller: c,
        onOpenForm: () => _openForm(),
      ),
    );
  }

  void _openForm({RecipeEntity? existing}) {
    Get.delete<RecipeFormController>(force: true);
    Get.to(() => RecipeFormPage(existing: existing));
  }
}

class _Body extends StatelessWidget {
  final RecipeController controller;
  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.allRecipes.isEmpty) {
        return const RecipeListSkeleton();
      }

      final list = controller.filteredRecipes;

      if (list.isEmpty) {
        return RefreshIndicator(
          color: RecipeStyle.primary,
          onRefresh: controller.fetchRecipes,
          child: RecipeEmptyState(
            hasFilter: controller.hasFilter,
            onClearFilter: controller.clearFilters,
          ),
        );
      }

      return RefreshIndicator(
        color: RecipeStyle.primary,
        onRefresh: controller.fetchRecipes,
        child: ListView.builder(
          padding: RecipeStyle.padListFAB,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i];
            return RecipeCard(
              key: ValueKey('recipe-${r.id}'),
              recipe: r,
              onTap: () {
                Get.delete<RecipeFormController>(force: true);
                Get.to(() => RecipeFormPage(existing: r));
              },
              onMarkEaten: () => controller.markAsEaten(r.id),
              onDelete: () => _confirmDelete(controller, r),
            );
          },
        ),
      );
    });
  }

  void _confirmDelete(RecipeController c, RecipeEntity r) {
    if (Get.isDialogOpen ?? false) return;
    Get.defaultDialog(
      title: RecipeStyle.confirmDelete,
      middleText:
          '${RecipeStyle.deleteConfirmPrefix}${r.name}${RecipeStyle.deleteConfirmSuffix}',
      textConfirm: RecipeStyle.delete,
      textCancel: RecipeStyle.cancel,
      confirmTextColor: RecipeStyle.white,
      buttonColor: RecipeStyle.error700,
      onConfirm: () {
        Get.back();
        c.deleteRecipe(r.id);
      },
    );
  }
}