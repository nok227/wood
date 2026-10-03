import 'dart:io';
import '../wood_product.dart';
import '../../repositories/wood_repository.dart';

import '../datasources/wood_remote_data_source.dart';
import '../models/wood_product_model.dart';

class WoodRepositoryImpl implements WoodRepository {
  final WoodRemoteDataSource remoteDataSource;

  WoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadImageToCloudinary(File imageFile) async {
    return await remoteDataSource.uploadImageToCloudinary(imageFile);
  }

  @override
  Future<void> saveWoodProduct(WoodProduct product) async {
    final model = WoodProductModel(
      id: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      width: product.width,
      length: product.length,
      thickness: product.thickness,
      quantity: product.quantity,
      unit: product.unit,
      price: product.price,
    );
    await remoteDataSource.saveWoodProduct(model);
  }

  @override
  Future<List<WoodProduct>> getWoodProducts() async {
    final models = await remoteDataSource.getWoodProducts();
    return models
        .map((m) => WoodProduct(
              id: m.id,
              name: m.name,
              imageUrl: m.imageUrl,
              width: m.width,
              length: m.length,
              thickness: m.thickness,
              quantity: m.quantity,
              unit: m.unit,
              price: m.price,
            ))
        .toList();
  }
}
