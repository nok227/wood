import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getRecipes();
  Future<void> addRecipe(RecipeEntity recipe);
  Future<void> updateRecipe(RecipeEntity recipe);
  Future<void> deleteRecipe(String id);
  Future<void> markAsEaten(String id);
}