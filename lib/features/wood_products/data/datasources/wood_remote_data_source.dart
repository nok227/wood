import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wood_product_model.dart';

class WoodRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ⚠️ เปลี่ยนเป็นข้อมูล Cloudinary ของคุณ
  final String cloudName = 'onvap9ey';
  final String uploadPreset = 'wood_preset';

  // 1. อัปโหลดรูปไป Cloudinary
  Future<String> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);

    if (response.statusCode == 200) {
      return jsonMap['secure_url'] as String;
    } else {
      throw Exception('Upload image failed: ${jsonMap['error']?['message'] ?? 'Unknown'}');
    }
  }

  // 2. บันทึกลง Firestore (สร้างใหม่)
  Future<void> saveWoodProduct(WoodProductModel product) async {
    await firestore.collection('wood_products').doc(product.id).set(product.toMap());
  }

  // 3. ✅ เพิ่มฟังก์ชัน อัปเดตข้อมูล ใน Firestore
  Future<void> updateWoodProduct(WoodProductModel product) async {
    await firestore.collection('wood_products').doc(product.id).update(product.toUpdateMap());
  }

  // 4. ✅ เพิ่มฟังก์ชัน ลบข้อมูล จาก Firestore
  Future<void> deleteWoodProduct(String id) async {
    await firestore.collection('wood_products').doc(id).delete();
  }

  // 5. ดึงรายการทั้งหมดจาก Firestore
  Future<List<WoodProductModel>> getWoodProducts() async {
    final snapshot = await firestore.collection('wood_products').get();
    return snapshot.docs
        .map((doc) => WoodProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}