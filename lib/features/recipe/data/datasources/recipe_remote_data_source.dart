import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

/// ══════════════════════════════════════════════
/// 📡 RECIPE REMOTE DATA SOURCE
/// หน้าที่: คุยกับ Firestore เท่านั้น
/// คืน Model — ไม่แปลงเป็น Entity
/// ══════════════════════════════════════════════
class RecipeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'recipes';

  // ── อ่าน (คืน Model) ──
  Future<List<RecipeModel>> getRecipes() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .get();

    return snap.docs
        .map((d) => RecipeModel.fromMap(d.data(), d.id))
        .toList();
  }

  // ── เพิ่ม (รับ Model) ──
  Future<void> addRecipe(RecipeModel model) async {
    await _firestore
        .collection(_collection)
        .doc(model.id)
        .set(model.toMap());
  }

  // ── อัปเดต (รับ Model) ──
  Future<void> updateRecipe(RecipeModel model) async {
    await _firestore
        .collection(_collection)
        .doc(model.id)
        .update(model.toMap());
  }

  // ── ลบ ──
  Future<void> deleteRecipe(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // ── mark eaten ──
  Future<void> markAsEaten(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'lastEatenAt': DateTime.now().toIso8601String(),
      'status': 'tried',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}