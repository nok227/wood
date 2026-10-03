import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;

  RecipeRepositoryImpl({required this.remote});

  @override
  Future<List<RecipeEntity>> getRecipes() => remote.getRecipes();

  @override
  Future<void> addRecipe(RecipeEntity recipe) => remote.addRecipe(recipe);

  @override
  Future<void> updateRecipe(RecipeEntity recipe) =>
      remote.updateRecipe(recipe);

  @override
  Future<void> deleteRecipe(String id) => remote.deleteRecipe(id);

  @override
  Future<void> markAsEaten(String id) => remote.markAsEaten(id);
}