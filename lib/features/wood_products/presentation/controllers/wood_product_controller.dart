import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/wood_remote_data_source.dart';
import '../../data/models/wood_product_model.dart';

class WoodProductController extends GetxController {
  final WoodRemoteDataSource dataSource = WoodRemoteDataSource();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var products = <WoodProductModel>[].obs;
  var errorMessage = RxnString();

  // ---------- รูปภาพ (สูงสุด 6 รูปต่อรายการ) ----------
  static const maxImages = 6;
  var existingImageUrls = <String>[].obs;
  var selectedImages = <File>[].obs;

  // ---------- หน่วยวัดขนาด ----------
  final List<String> sizeUnitOptions = ['mm', 'cm', 'm'];
  var selectedSizeUnit = 'mm'.obs;

  // ---------- หน่วยนับจำนวน ----------
  final List<String> unitOptions = ['ແຜ່ນ', 'ທ່ອນ', 'ວົງ', 'ອື່ນໆ'];
  var selectedUnit = 'ແຜ່ນ'.obs;

  // ---------- โหมดแก้ไข ----------
  var editingProductId = RxnString();

  final nameController = TextEditingController();
  final woodTypeController = TextEditingController(); // ✅ เพิ่ม Controller ชนิดไม้
  final widthController = TextEditingController();
  final lengthController = TextEditingController();
  final thicknessController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final customUnitController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    woodTypeController.dispose(); // ✅ dispose
    widthController.dispose();
    lengthController.dispose();
    thicknessController.dispose();
    quantityController.dispose();
    customUnitController.dispose();
    priceController.dispose();
    super.onClose();
  }

  // ---------- รูปภาพ ----------
  Future<void> pickImages() async {
    try {
      final remainingSlots = maxImages - (existingImageUrls.length + selectedImages.length);
      if (remainingSlots <= 0) {
        Get.snackbar('ແຈ້ງເຕືອນ', 'ເລືອກໄດ້ສູງສຸດ $maxImages ຮູບເທົ່ານັ້ນ');
        return;
      }
      final pickedFiles = await ImagePicker().pickMultiImage(maxWidth: 1200, imageQuality: 75);
      if (pickedFiles.isEmpty) return;

      final toAdd = pickedFiles.take(remainingSlots).map((x) => File(x.path)).toList();
      if (pickedFiles.length > remainingSlots) {
        Get.snackbar('ແຈ້ງເຕືອນ', 'ເລືອກໄດ້ສູງສຸດ $maxImages ຮູບ — ເກັບ $remainingSlots ຮູບທຳອິດໄຫ້ເທົ່ານັ້ນ');
      }
      selectedImages.addAll(toAdd);
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('pickImages error: $e');
      Get.snackbar('ຂໍ້ຜິດພາດ', 'ເລືອກຮູບບໍ່ສໍາເລັດ: $e');
    }
  }

  void removeNewImage(int index) => selectedImages.removeAt(index);
  void removeExistingImage(int index) => existingImageUrls.removeAt(index);

  // ---------- ดึงข้อมูล ----------
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await dataSource.getWoodProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('fetchProducts error: $e');
      Get.snackbar('ຂໍ້ຜິດພາດ', 'ບໍ່ສາມາດດືງຂໍ້ມູນໄດ້: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- ดึงรายการ ชนิดไม้ แบบไม่ซ้ำกัน ----------
  List<String> get uniqueWoodTypes =>
      products.map((p) => p.woodType.trim()).where((t) => t.isNotEmpty).toSet().toList();

  List<String> get uniqueProductNames => products.map((p) => p.name).toSet().toList();
  
  List<WoodProductModel> variantsForName(String name) =>
      products.where((p) => p.name == name).toList();

  // ---------- เริ่มแก้ไขรายการ ----------
  void startEdit(WoodProductModel product) {
    editingProductId.value = product.id;
    nameController.text = product.name;
    woodTypeController.text = product.woodType; // ✅ ดึงชนิดไม้เดิมมาใส่
    widthController.text = _fmt(product.width);
    lengthController.text = _fmt(product.length);
    thicknessController.text = _fmt(product.thickness);
    quantityController.text = '1';
    priceController.text = _fmtPrice(product.price);
    selectedSizeUnit.value =
        sizeUnitOptions.contains(product.sizeUnit) ? product.sizeUnit : 'cm';

    if (unitOptions.contains(product.unit)) {
      selectedUnit.value = product.unit;
      customUnitController.clear();
    } else {
      selectedUnit.value = 'ອື່ນໆ';
      customUnitController.text = product.unit;
    }

    existingImageUrls.assignAll(product.imageUrls);
    selectedImages.clear();
  }

  void cancelEdit() {
    clearForm();
  }

  String _fmt(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // ---------- บันทึก (เพิ่มใหม่ หรือ แก้ไข) ----------
  Future<bool> saveProduct() async {
    final name = nameController.text.trim();
    final woodType = woodTypeController.text.trim(); // ✅ อ่านค่าชนิดไม้
    final width = double.tryParse(widthController.text.trim());
    final length = double.tryParse(lengthController.text.trim());
    final thickness = double.tryParse(thicknessController.text.trim());
    const quantity = 1;
    final price = double.tryParse(priceController.text.replaceAll(',', '').trim());
    final unit =
        selectedUnit.value == 'ອື່ນໆ' ? customUnitController.text.trim() : selectedUnit.value;
    final totalImages = existingImageUrls.length + selectedImages.length;

    if (name.isEmpty) {
      Get.snackbar('ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນຊື່ໄມ້');
      return false;
    }
    if (totalImages == 0) {
      Get.snackbar('ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນຮູບຢ່າງນ້ອຍ 1 ຮູບ');
      return false;
    }
    if (width == null || length == null || thickness == null) {
      Get.snackbar('ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນ ກວ້າງ/ຍາວ/ໜາ ເປັນຕົວເລກ');
      return false;
    }
    if (unit.isEmpty) {
      Get.snackbar('ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນໜ່ວຍນັບ');
      return false;
    }
    if (price == null || price < 0) {
      Get.snackbar('ແຈ້ງເຕືອນ', 'ກະລຸນາປ້ອນຂໍ້ມູນເປັນຕົວເລກ');
      return false;
    }

    bool isSuccess = false;

    try {
      isSaving.value = true;
      errorMessage.value = null;

      final newUrls = <String>[];
      for (final file in selectedImages) {
        final url = await dataSource.uploadImageToCloudinary(file);
        newUrls.add(url);
      }
      final finalImageUrls = [...existingImageUrls, ...newUrls];

      final isEditing = editingProductId.value != null;
      final product = WoodProductModel(
        id: isEditing
            ? editingProductId.value!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        woodType: woodType, // ✅ บันทึกชนิดไม้
        imageUrls: finalImageUrls,
        width: width,
        length: length,
        thickness: thickness,
        sizeUnit: selectedSizeUnit.value,
        quantity: quantity,
        unit: unit,
        price: price,
      );

      if (isEditing) {
        await dataSource.updateWoodProduct(product);
      } else {
        await dataSource.saveWoodProduct(product);
      }

      clearForm();
      isSuccess = true;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('saveProduct error: $e');
      Get.snackbar('ຂໍ້ຜິດພາດ', 'ບັນທຶກບໍ່ສໍາເລັດ: $e');
      return false;
    } finally {
      isSaving.value = false;
    }

    if (isSuccess) {
      fetchProducts();
    }

    return isSuccess;
  }

  // ---------- ลบ ----------
  Future<void> deleteProduct(String id) async {
    try {
      isLoading.value = true;
      await dataSource.deleteWoodProduct(id);
      Get.snackbar('ສຳເລັດ', 'ລົບຂໍ້ມູນແລ້ວ');
      await fetchProducts();
    } catch (e) {
      debugPrint('deleteProduct error: $e');
      Get.snackbar('ຂໍ້ຜຶດພາດ', 'ລົບບໍ່ສໍາເລັດ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    editingProductId.value = null;
    nameController.clear();
    woodTypeController.clear(); // ✅ ล้างค่าชนิดไม้
    widthController.clear();
    lengthController.clear();
    thicknessController.clear();
    quantityController.text = '1';
    customUnitController.clear();
    priceController.clear();
    selectedUnit.value = 'ແຜ່ນ';
    selectedSizeUnit.value = 'cm';
    existingImageUrls.clear();
    selectedImages.clear();
  }

  String _fmtPrice(num v) {
    String text = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return text.replaceAllMapped(regExp, (Match match) => '${match[1]},');
  }
}