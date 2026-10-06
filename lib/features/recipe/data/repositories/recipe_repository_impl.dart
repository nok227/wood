import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../models/recipe_model.dart';

/// ══════════════════════════════════════════════
/// 📦 RECIPE REPOSITORY IMPL
/// แปลง Model ↔ Entity
/// ══════════════════════════════════════════════
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;

  RecipeRepositoryImpl({required this.remote});

  // ── ดึง: Model → Entity ──
  @override
  Future<List<RecipeEntity>> getRecipes() async {
    final models = await remote.getRecipes();
    return models.map((m) => m.toEntity()).toList();
  }

  // ── เพิ่ม: Entity → Model ──
  @override
  Future<void> addRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await remote.addRecipe(model);
  }

  // ── อัปเดต: Entity → Model ──
  @override
  Future<void> updateRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await remote.updateRecipe(model);
  }

  // ── ลบ ──
  @override
  Future<void> deleteRecipe(String id) => remote.deleteRecipe(id);

  // ── mark eaten ──
  @override
  Future<void> markAsEaten(String id) => remote.markAsEaten(id);
}