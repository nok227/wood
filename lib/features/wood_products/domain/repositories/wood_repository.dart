import 'dart:io';
import '../entities/wood_product.dart';

abstract class WoodRepository {
  Future<String> uploadImageToCloudinary(File imageFile);
  Future<void> saveWoodProduct(WoodProduct product);
  Future<List<WoodProduct>> getWoodProducts();
  Future<void> updateWoodProduct(WoodProduct product);
  Future<void> deleteWoodProduct(String id);
}