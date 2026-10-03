import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'recipes';

  Future<List<RecipeEntity>> getRecipes() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => RecipeModel.fromMap(d.data(), d.id).toEntity())
        .toList();
  }

  Future<void> addRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _firestore.collection(_collection).doc(recipe.id).set(model.toMap());
  }

  Future<void> updateRecipe(RecipeEntity recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _firestore
        .collection(_collection)
        .doc(recipe.id)
        .update(model.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> markAsEaten(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'lastEatenAt': DateTime.now().toIso8601String(),
      'status': 'tried',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}