import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('ຄັງເມນູອາຫານ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<RecipeSortBy>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (v) => c.sortBy.value = v,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: RecipeSortBy.leastRecentlyEaten,
                child: Text('ຍັງບໍ່ກິນດົນ'),
              ),
              PopupMenuItem(
                value: RecipeSortBy.newest,
                child: Text('ເພີ່ມໃໝ່ສຸດ'),
              ),
              PopupMenuItem(
                value: RecipeSortBy.highestRating,
                child: Text('ຄະແນນສູງສຸດ'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => c.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາເມນູ ຫຼື ສ່ວນປະກອບ...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                suffixIcon: Obx(() => c.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          c.searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink()),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.shade200),
                ),
              ),
            ),
          ),
          Obx(() {
            final items = [
              ('all', 'ທັງໝົດ'),
              ('want', '⏳ ຢາກລອງ'),
              ('tried', '✓ ເຄີຍເຮັດ'),
              ('never', '· ຍັງບໍ່ເຄີຍ'),
            ];
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
              child: Row(
                children: items.map((e) {
                  final selected = c.selectedStatus.value == e.$1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => c.selectedStatus.value = e.$1,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.brown.shade700
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              e.$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? Colors.white
                                    : Colors.brown.shade800,
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
          }),
          Obx(() {
            if (c.allRecipes.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Row(
                children: [
                  _statBubble('${c.totalCount}', 'ທັງໝົດ',
                      Colors.brown.shade600),
                  const SizedBox(width: 6),
                  _statBubble('${c.wantCount}', 'ຢາກລອງ',
                      Colors.amber.shade800),
                  const SizedBox(width: 6),
                  _statBubble('${c.neverCount}', 'ຍັງບໍ່ເຄີຍ',
                      Colors.grey.shade600),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.allRecipes.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                );
              }

              final list = c.filteredRecipes;

              if (list.isEmpty) {
                return RefreshIndicator(
                  color: Colors.brown,
                  onRefresh: c.fetchRecipes,
                  child: ListView(
                    children: [
                      const SizedBox(height: 80),
                      Icon(Icons.restaurant_menu,
                          size: 72, color: Colors.brown.shade200),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          c.hasFilter
                              ? 'ບໍ່ພົບເມນູທີ່ຄົ້ນຫາ'
                              : 'ຍັງບໍ່ມີເມນູອາຫານ',
                          style: TextStyle(
                            color: Colors.brown.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (c.hasFilter) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: c.clearFilters,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('ລ້າງຕົວກອງ'),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'ກົດປຸ່ມ + ເພື່ອເພີ່ມເມນູທຳອິດ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.brown,
                onRefresh: c.fetchRecipes,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 120),
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
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
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
              backgroundColor: Colors.brown.shade800,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'ເພີ່ມເມນູໃໝ່',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: 'btnMainFab',
            backgroundColor: Colors.brown.shade800,
            onPressed: () => setState(() => _fabOpen = !_fabOpen),
            child: Icon(
              _fabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBubble(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RecipeEntity r) {
    if (Get.isDialogOpen ?? false) return;
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      middleText: 'ລຶບເມນູ "${r.name}" ອອກບໍ?',
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () {
        Get.back();
        c.deleteRecipe(r.id);
      },
    );
  }
}