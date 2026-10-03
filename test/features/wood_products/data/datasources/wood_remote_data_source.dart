import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wood_product_model.dart';

class WoodRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String cloudName = 'onvap9ey';
  final String uploadPreset = 'wood_preset';

  Future<String> uploadImageToCloudinary(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 45));

      final responseData = await streamedResponse.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (streamedResponse.statusCode == 200 &&
          jsonMap['secure_url'] != null) {
        return jsonMap['secure_url'] as String;
      } else {
        throw Exception(
          'Upload failed: ${jsonMap['error']?['message'] ?? 'Unknown'}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Upload image error: $e');
    }
  }

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