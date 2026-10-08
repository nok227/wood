import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wood/core/utils/cloudinary_service.dart';   // ⭐ import
import '../models/wood_product_model.dart';

class WoodRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String cloudName = 'onvap9ey';
  final String uploadPreset = 'wood_preset';

  // ══════════════════════════════════════════
  // ⬆️ Upload (ของเดิม)
  // ══════════════════════════════════════════
  Future<String> uploadImageToCloudinary(File imageFile) async {
    final url = await CloudinaryService.uploadImage(imageFile, folder: 'wood');
    if (url == null) {
      throw Exception('Upload image failed');
    }
    return url;
  }

  // ══════════════════════════════════════════
  // 🗑️ Delete — delegate ไป CloudinaryService
  // ══════════════════════════════════════════
  Future<void> deleteImageFromCloudinary(String imageUrl) async {
    final ok = await CloudinaryService.deleteImage(imageUrl);
    if (!ok) {
      debugPrint('⚠️ Delete returned false for: $imageUrl');
    }
    // ไม่ throw — ไม่ให้ save/delete fail เพราะลบรูปไม่ได้
  }

  // ══════════════════════════════════════════
  // 📦 Firestore (ของเดิม)
  // ══════════════════════════════════════════
  Future<void> saveWoodProduct(WoodProductModel product) async {
    await firestore
        .collection('wood_products')
        .doc(product.id)
        .set(product.toMap())
        .timeout(const Duration(seconds: 20));
  }

  Future<void> updateWoodProduct(WoodProductModel product) async {
    await firestore
        .collection('wood_products')
        .doc(product.id)
        .update(product.toUpdateMap())
        .timeout(const Duration(seconds: 20));
  }

  Future<void> deleteWoodProduct(String id) async {
    await firestore
        .collection('wood_products')
        .doc(id)
        .delete()
        .timeout(const Duration(seconds: 20));
  }

  Future<List<WoodProductModel>> getWoodProducts() async {
    final snapshot = await firestore
        .collection('wood_products')
        .get()
        .timeout(const Duration(seconds: 30));
    return snapshot.docs
        .map((doc) => WoodProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}