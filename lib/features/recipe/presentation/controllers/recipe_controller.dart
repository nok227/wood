import 'dart:math';
import 'package:get/get.dart';
import 'package:wood/core/utils/cloudinary_service.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

enum RecipeSortBy { leastRecentlyEaten, newest, highestRating }

class RecipeController extends GetxController {
  final RecipeRepository repository;
  RecipeController({required this.repository});

  final allRecipes = <RecipeEntity>[].obs;
  final isLoading = false.obs;

  final selectedCategory = 'all'.obs;
  final selectedStatus = 'all'.obs;
  final searchQuery = ''.obs;
  final sortBy = RecipeSortBy.leastRecentlyEaten.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    isLoading.value = true;
    try {
      final list = await repository.getRecipes();
      allRecipes.assignAll(list);
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດດຶງຂໍ້ມູນໄດ້: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<RecipeEntity> get filteredRecipes {
    final q = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;
    final st = selectedStatus.value;

    final list = allRecipes.where((r) {
      if (cat != 'all' && r.category.name != cat) return false;
      if (st != 'all' && r.status.name != st) return false;
      if (q.isNotEmpty) {
        final matchName = r.name.toLowerCase().contains(q);
        final matchIng = r.ingredients
            .any((i) => i.toLowerCase().contains(q));
        final matchSteps = (r.steps ?? '').toLowerCase().contains(q);
        if (!matchName && !matchIng && !matchSteps) return false;
      }
      return true;
    }).toList();

    switch (sortBy.value) {
      case RecipeSortBy.leastRecentlyEaten:
        list.sort((a, b) {
          if (a.lastEatenAt == null && b.lastEatenAt == null) {
            return b.updatedAt.compareTo(a.updatedAt);
          }
          if (a.lastEatenAt == null) return -1;
          if (b.lastEatenAt == null) return 1;
          return a.lastEatenAt!.compareTo(b.lastEatenAt!);
        });
        break;
      case RecipeSortBy.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case RecipeSortBy.highestRating:
        list.sort((a, b) {
          final rc = b.rating.compareTo(a.rating);
          if (rc != 0) return rc;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }
    return list;
  }

  int get totalCount => allRecipes.length;
  int get wantCount =>
      allRecipes.where((r) => r.status == RecipeStatus.want).length;
  int get neverCount =>
      allRecipes.where((r) => r.status == RecipeStatus.never).length;

  Future<bool> addRecipe({
    required String name,
    required RecipeCategory category,
    required List<String> ingredients,
    required RecipeStatus status,
    required int rating,
    required List<String> imageUrls,
    String? steps,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final recipe = RecipeEntity(
        id: now.millisecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category,
        ingredients: ingredients,
        steps: steps,
        status: status,
        rating: rating,
        imageUrls: imageUrls,
        note: note,
        createdAt: now,
        updatedAt: now,
        lastEatenAt: status == RecipeStatus.tried ? now : null,
      );
      await repository.addRecipe(recipe);
      allRecipes.insert(0, recipe);
      return true;
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
      return false;
    }
  }

  Future<bool> updateRecipe({
    required String id,
    required String name,
    required RecipeCategory category,
    required List<String> ingredients,
    required RecipeStatus status,
    required int rating,
    required List<String> imageUrls,
    String? steps,
    String? note,
  }) async {
    try {
      final idx = allRecipes.indexWhere((r) => r.id == id);
      if (idx < 0) return false;

      final old = allRecipes[idx];
      final updated = old.copyWith(
        name: name.trim(),
        category: category,
        ingredients: ingredients,
        steps: steps,
        status: status,
        rating: rating,
        imageUrls: imageUrls,
        note: note,
        updatedAt: DateTime.now(),
        lastEatenAt: (old.status != RecipeStatus.tried &&
                status == RecipeStatus.tried)
            ? DateTime.now()
            : old.lastEatenAt,
      );

      await repository.updateRecipe(updated);
      allRecipes[idx] = updated;
      return true;
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອັບເດດໄດ້: $e');
      return false;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      final removed = allRecipes.firstWhereOrNull((r) => r.id == id);
      await repository.deleteRecipe(id);
      allRecipes.removeWhere((r) => r.id == id);

      if (removed != null && removed.imageUrls.isNotEmpty) {
        try {
          await CloudinaryService.deleteImages(removed.imageUrls);
        } catch (_) {}
      }
      Get.snackbar('ສຳເລັດ', 'ລຶບຮຽບຮ້ອຍແລ້ວ');
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດລຶບໄດ້: $e');
    }
  }

  Future<void> markAsEaten(String id) async {
    try {
      final idx = allRecipes.indexWhere((r) => r.id == id);
      if (idx < 0) return;
      await repository.markAsEaten(id);
      allRecipes[idx] = allRecipes[idx].copyWith(
        lastEatenAt: DateTime.now(),
        status: RecipeStatus.tried,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອັບເດດໄດ້: $e');
    }
  }

  RecipeEntity? pickRandom({bool dueOnly = true}) {
    final pool = filteredRecipes.where((r) {
      if (!dueOnly) return true;
      return !r.isFreshlyEaten;
    }).toList();

    if (pool.isEmpty) {
      final all = filteredRecipes;
      if (all.isEmpty) return null;
      return all[Random().nextInt(all.length)];
    }
    return pool[Random().nextInt(pool.length)];
  }

  void clearFilters() {
    selectedCategory.value = 'all';
    selectedStatus.value = 'all';
    searchQuery.value = '';
  }

  bool get hasFilter =>
      selectedCategory.value != 'all' ||
      selectedStatus.value != 'all' ||
      searchQuery.value.isNotEmpty;

  Future<String?> uploadImage(dynamic file) async {
    try {
      return await CloudinaryService.uploadImage(
        file,
        folder: 'recipes',
      ).timeout(const Duration(seconds: 60));
    } catch (_) {
      return null;
    }
  }
}