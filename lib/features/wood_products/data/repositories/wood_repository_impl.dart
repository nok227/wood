import 'dart:io';
import '../../domain/entities/wood_product.dart';
import '../../domain/repositories/wood_repository.dart';
import '../datasources/wood_remote_data_source.dart';
import '../models/wood_product_model.dart';

class WoodRepositoryImpl implements WoodRepository {
  final WoodRemoteDataSource remoteDataSource;

  WoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadImageToCloudinary(File imageFile) =>
      remoteDataSource.uploadImageToCloudinary(imageFile);

  @override
  Future<void> saveWoodProduct(WoodProduct product) =>
      remoteDataSource.saveWoodProduct(WoodProductModel.fromEntity(product));

  @override
  Future<void> updateWoodProduct(WoodProduct product) =>
      remoteDataSource.updateWoodProduct(WoodProductModel.fromEntity(product));

  @override
  Future<void> deleteWoodProduct(String id) =>
      remoteDataSource.deleteWoodProduct(id);

  @override
  Future<List<WoodProduct>> getWoodProducts() async {
    final models = await remoteDataSource.getWoodProducts();
    return models.map((m) => m.toEntity()).toList();
  }
}