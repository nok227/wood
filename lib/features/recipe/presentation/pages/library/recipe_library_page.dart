import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';
import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_controller.dart';
import '../../widgets/recipe_card.dart';
import '../form/recipe_form_page.dart';

class RecipeLibraryPage extends StatefulWidget {
  const RecipeLibraryPage({super.key});

  @override
  State<RecipeLibraryPage> createState() => _RecipeLibraryPageState();
}

class _RecipeLibraryPageState extends State<RecipeLibraryPage> {
  final c = Get.find<RecipeController>();
  final _searchCtrl = TextEditingController();
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    c.fetchRecipes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openForm({RecipeEntity? existing}) async {
    await Get.to<bool>(() => RecipeFormPage(existing: existing));
  }

  @override
  Widget build(BuildContext context) {
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
          _buildSearchBar(),
          _buildFilterTabs(),
          _buildStatsRow(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFab(),
    );
  }

  // ── Search bar ──
  Widget _buildSearchBar() {
    return Padding(
      padding: RecipeStyle.padSearchBar,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => c.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: RecipeStyle.searchHint,
          prefixIcon:
              const Icon(Icons.search, color: RecipeStyle.primary),
          suffixIcon: Obx(() => c.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: RecipeStyle.iconSm,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    c.searchQuery.value = '';
                  },
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

  // ── Filter tabs ──
  Widget _buildFilterTabs() {
    return Obx(() {
      final items = [
        ('all', RecipeStyle.filterAll),
        ('want', RecipeStyle.filterWant),
        ('tried', RecipeStyle.filterTried),
        ('never', RecipeStyle.filterNever),
      ];
      return Padding(
        padding: RecipeStyle.padFilterTabs,
        child: Row(
          children: items.map((e) {
            final selected = c.selectedStatus.value == e.$1;
            return Expanded(
              child: Padding(
                padding: RecipeStyle.padFilterChip,
                child: InkWell(
                  onTap: () => c.selectedStatus.value = e.$1,
                  borderRadius: RecipeStyle.r8,
                  child: Container(
                    padding: RecipeStyle.padVertical6,
                    decoration: BoxDecoration(
                      color: selected
                          ? RecipeStyle.primary
                          : RecipeStyle.white,
                      borderRadius: RecipeStyle.r8,
                      border: Border.all(
                        color: selected
                            ? RecipeStyle.brown800
                            : RecipeStyle.brown200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        e.$2,
                        style: RecipeStyle.statusTab.copyWith(
                          fontSize: 11,
                          color: selected
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
        ),
      );
    });
  }

  // ── Stats row ──
  Widget _buildStatsRow() {
    return Obx(() {
      if (c.allRecipes.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: RecipeStyle.padStatsRow,
        child: Row(
          children: [
            _statBubble('${c.totalCount}', RecipeStyle.statAll,
                RecipeStyle.brown600),
            RecipeStyle.gap6,
            _statBubble('${c.wantCount}', RecipeStyle.statWant,
                RecipeStyle.amber800),
            RecipeStyle.gap6,
            _statBubble('${c.neverCount}', RecipeStyle.statNever,
                RecipeStyle.grey600),
          ],
        ),
      );
    });
  }

  Widget _statBubble(String value, String label, Color color) {
    return Container(
      padding: RecipeStyle.padStatBubble,
      decoration: BoxDecoration(
        color: color.withOpacity(RecipeStyle.bubbleOpacity),
        borderRadius: RecipeStyle.r20,
        border: Border.all(
          color: color.withOpacity(RecipeStyle.bubbleBorderOpacity),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: RecipeStyle.statBubbleValue.copyWith(color: color),
          ),
          RecipeStyle.gap4,
          Text(
            label,
            style: RecipeStyle.statBubbleLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ── Body ──
  Widget _buildBody() {
    return Obx(() {
      if (c.isLoading.value && c.allRecipes.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: RecipeStyle.primary),
        );
      }

      final list = c.filteredRecipes;

      if (list.isEmpty) {
        return RefreshIndicator(
          color: RecipeStyle.primary,
          onRefresh: c.fetchRecipes,
          child: ListView(
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
                  c.hasFilter
                      ? RecipeStyle.notFound
                      : RecipeStyle.emptyLibrary,
                  style: RecipeStyle.emptyTitle,
                ),
              ),
              if (c.hasFilter) ...[
                RecipeStyle.gap12,
                Center(
                  child: TextButton.icon(
                    onPressed: c.clearFilters,
                    icon: const Icon(
                      Icons.clear_all,
                      size: RecipeStyle.iconSm,
                    ),
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
          ),
        );
      }

      return RefreshIndicator(
        color: RecipeStyle.primary,
        onRefresh: c.fetchRecipes,
        child: ListView.builder(
          padding: RecipeStyle.padListFAB,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i];
            return RecipeCard(
              key: ValueKey('recipe-${r.id}'),
              recipe: r,
              onTap: () => _openForm(existing: r),
              onMarkEaten: () => c.markAsEaten(r.id),
              onDelete: () => _confirmDelete(r),
            );
          },
        ),
      );
    });
  }

  // ── FAB ──
  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabOpen) ...[
          FloatingActionButton.extended(
            heroTag: 'btnAddRecipe',
            onPressed: () {
              setState(() => _fabOpen = false);
              _openForm();
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
          onPressed: () => setState(() => _fabOpen = !_fabOpen),
          child: Icon(
            _fabOpen ? Icons.close : Icons.add,
            color: RecipeStyle.white,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(RecipeEntity r) {
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