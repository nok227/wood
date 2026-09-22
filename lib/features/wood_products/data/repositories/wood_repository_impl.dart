import 'dart:io';
import '../../domain/entities/wood_product.dart';
import '../../domain/repositories/wood_repository.dart';
import '../datasources/wood_remote_data_source.dart';
import '../models/wood_product_model.dart';

// หมายเหตุ: ปัจจุบัน WoodProductController เรียก WoodRemoteDataSource ตรง ๆ
// ไม่ได้ผ่าน repository นี้ (ตามแพทเทิร์นเดิมของโปรเจกต์) — คงไฟล์นี้ไว้ให้
// สอดคล้องกันเผื่ออนาคตอยากสลับมาใช้งานผ่าน repository แทน
class WoodRepositoryImpl implements WoodRepository {
  final WoodRemoteDataSource remoteDataSource;

  WoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadImageToCloudinary(File imageFile) async {
    return await remoteDataSource.uploadImageToCloudinary(imageFile);
  }

  WoodProductModel _toModel(WoodProduct p) => WoodProductModel(
        id: p.id,
        name: p.name,
        imageUrls: p.imageUrls,
        width: p.width,
        length: p.length,
        thickness: p.thickness,
        sizeUnit: p.sizeUnit,
        quantity: p.quantity,
        unit: p.unit,
        price: p.price,
      );

  WoodProduct _toEntity(WoodProductModel m) => WoodProduct(
        id: m.id,
        name: m.name,
        imageUrls: m.imageUrls,
        width: m.width,
        length: m.length,
        thickness: m.thickness,
        sizeUnit: m.sizeUnit,
        quantity: m.quantity,
        unit: m.unit,
        price: m.price,
      );

  @override
  Future<void> saveWoodProduct(WoodProduct product) async {
    await remoteDataSource.saveWoodProduct(_toModel(product));
  }

  @override
  Future<void> updateWoodProduct(WoodProduct product) async {
    await remoteDataSource.updateWoodProduct(_toModel(product));
  }

  @override
  Future<void> deleteWoodProduct(String id) async {
    await remoteDataSource.deleteWoodProduct(id);
  }

  @override
  Future<List<WoodProduct>> getWoodProducts() async {
    final models = await remoteDataSource.getWoodProducts();
    return models.map(_toEntity).toList();
  }
}
