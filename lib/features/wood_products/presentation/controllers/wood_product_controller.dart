import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wood/features/wood_products/domain/entities/app_notification.dart';
import 'package:wood/features/wood_products/presentation/controllers/notification_controller.dart';
import '../../data/datasources/wood_remote_data_source.dart';
import '../../data/models/wood_product_model.dart';

class WoodProductController extends GetxController {
  final WoodRemoteDataSource dataSource = WoodRemoteDataSource();

  var isLoading = false.obs;
  var isSaving = false.obs;

  // ✅ ຕົວບອກຄວາມຄືບໜ້າ (progress bar)
  var saveProgress = 0.obs;      // 0-100
  var saveStep = ''.obs;         // ຂໍ້ຄວາມສະຖານະ

  var productList = <WoodProductModel>[].obs;
  var products = <WoodProductModel>[].obs;
  var errorMessage = RxnString();

  // ✅ ເກັບຄ່າເດີມ
  double? _originalPrice;
  DateTime? _originalPriceUpdatedAt;

  // ---------- ຮູບພາບ ----------
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
  final woodTypeController = TextEditingController();
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
    woodTypeController.dispose();
    widthController.dispose();
    lengthController.dispose();
    thicknessController.dispose();
    quantityController.dispose();
    customUnitController.dispose();
    priceController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════
  // 📷 ເລືອກຮູບ — ບີບອັດແຮງຂຶ້ນ ເພື່ອ upload ໄວ
  // ══════════════════════════════════════════════
  Future<void> pickImages() async {
    try {
      final remainingSlots =
          maxImages - (existingImageUrls.length + selectedImages.length);
      if (remainingSlots <= 0) {
        Get.snackbar('ແຈ້ງເຕືອນ', 'ເລືອກໄດ້ສູງສຸດ $maxImages ຮູບເທົ່ານັ້ນ');
        return;
      }
      final pickedFiles = await ImagePicker().pickMultiImage(
        maxWidth: 900,        // ✅ ຫຼຸດຈາກ 1200 → 900
        maxHeight: 900,
        imageQuality: 60,     // ✅ ຫຼຸດຈາກ 75 → 60 (ໄວຂຶ້ນ 40%)
      );
      if (pickedFiles.isEmpty) return;

      final toAdd =
          pickedFiles.take(remainingSlots).map((x) => File(x.path)).toList();
      if (pickedFiles.length > remainingSlots) {
        Get.snackbar('ແຈ້ງເຕືອນ',
            'ເລືອກໄດ້ສູງສຸດ $maxImages ຮູບ — ເກັບ $remainingSlots ຮູບທຳອິດໄຫ້ເທົ່ານັ້ນ');
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

  // ══════════════════════════════════════════════
  // 📥 ດຶງຂໍ້ມູນ
  // ══════════════════════════════════════════════
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

  List<String> get uniqueWoodTypes => products
      .map((p) => p.woodType.trim())
      .where((t) => t.isNotEmpty)
      .toSet()
      .toList();

  List<String> get uniqueProductNames =>
      products.map((p) => p.name).toSet().toList();

  List<WoodProductModel> variantsForName(String name) =>
      products.where((p) => p.name == name).toList();

  // ══════════════════════════════════════════════
  // ✏️ ເລີ່ມແກ້ໄຂ
  // ══════════════════════════════════════════════
  void startEdit(WoodProductModel product) {
    _originalPrice = product.price;
    _originalPriceUpdatedAt = product.priceUpdatedAt;
    editingProductId.value = product.id;
    nameController.text = product.name;
    woodTypeController.text = product.woodType;
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

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // ══════════════════════════════════════════════
  // 🚀 ບັນທຶກ — ເວີຊັ່ນໄວ
  //   ① Upload ຮູບພ້ອມກັນ (parallel)
  //   ② ບັນທຶກ Firestore
  //   ③ ອັບເດດ list ໃນ-memory (ບໍ່ fetch ຄືນ)
  //   ④ ແຈ້ງເຕືອນ fire-and-forget
  // ══════════════════════════════════════════════
  Future<bool> saveProduct() async {
    final name = nameController.text.trim();
    final woodType = woodTypeController.text.trim();
    final width = double.tryParse(widthController.text.trim());
    final length = double.tryParse(lengthController.text.trim());
    final thickness = double.tryParse(thicknessController.text.trim());
    const quantity = 1;
    final price =
        double.tryParse(priceController.text.replaceAll(',', '').trim());
    final unit = selectedUnit.value == 'ອື່ນໆ'
        ? customUnitController.text.trim()
        : selectedUnit.value;
    final totalImages = existingImageUrls.length + selectedImages.length;

    // ── Validation ──
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
      saveProgress.value = 0;
      saveStep.value = 'ກຳລັງກະກຽມ...';
      errorMessage.value = null;

      // ─────────────────────────────────────────
      // ① Upload ຮູບພ້ອມກັນ
      // ─────────────────────────────────────────
      final newUrls = <String>[];
      if (selectedImages.isNotEmpty) {
        final total = selectedImages.length;
        int completed = 0;

        saveStep.value = 'ກຳລັງອັບໂຫຼດຮູບ 0/$total...';
        saveProgress.value = 5;

        final futures = selectedImages.map((file) async {
          final url = await dataSource.uploadImageToCloudinary(file);
          completed++;
          // ✅ progress 5% → 85%
          saveProgress.value = 5 + (completed / total * 80).round();
          saveStep.value = 'ກຳລັງອັບໂຫຼດຮູບ $completed/$total...';
          return url;
        });

        newUrls.addAll(await Future.wait(futures));
      }

      final finalImageUrls = [...existingImageUrls, ...newUrls];
      final isEditing = editingProductId.value != null;

      final priceChanged = isEditing &&
          _originalPrice != null &&
          _originalPrice != price;

      final DateTime? newPriceUpdatedAt = priceChanged
          ? DateTime.now()
          : (isEditing ? _originalPriceUpdatedAt : null);

      final product = WoodProductModel(
        id: isEditing
            ? editingProductId.value!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        woodType: woodType,
        imageUrls: finalImageUrls,
        width: width,
        length: length,
        thickness: thickness,
        sizeUnit: selectedSizeUnit.value,
        quantity: quantity,
        unit: unit,
        price: price,
        priceUpdatedAt: newPriceUpdatedAt,
      );

      // ─────────────────────────────────────────
      // ② ບັນທຶກ Firestore
      // ─────────────────────────────────────────
      saveStep.value = 'ກຳລັງບັນທຶກ...';
      saveProgress.value = 90;

      if (isEditing) {
        await dataSource.updateWoodProduct(product);
      } else {
        await dataSource.saveWoodProduct(product);
      }

      // ─────────────────────────────────────────
      // ③ ອັບເດດ list ໃນ-memory (ບໍ່ fetch ຄືນ)
      // ─────────────────────────────────────────
      final idx = products.indexWhere((p) => p.id == product.id);
      if (idx >= 0) {
        products[idx] = product;
      } else {
        products.insert(0, product);
      }

      saveProgress.value = 100;

      // ─────────────────────────────────────────
      // ④ ແຈ້ງເຕືອນ — fire-and-forget
      // ─────────────────────────────────────────
      if (Get.isRegistered<NotificationController>()) {
        try {
          final noti = Get.find<NotificationController>();
          if (isEditing) {
            final oldP = _originalPrice;
            if (oldP != null && oldP != price) {
              noti.push(
                type: AppNotificationType.priceChange,
                title: 'ປ່ຽນແປງລາຄາໄມ້',
                message:
                    '$name: ${oldP.toStringAsFixed(0)} → ${price.toStringAsFixed(0)} ກີບ',
                audience: NotificationAudience.all,
                targetId: product.id,
                meta: {'oldPrice': oldP, 'newPrice': price},
              );
            } else {
              noti.push(
                type: AppNotificationType.productEdit,
                title: 'ແກ້ໄຂຂໍ້ມູນໄມ້',
                message: 'ແກ້ໄຂ "$name" ຂະໜາດ '
                    '${_fmt(width)}×${_fmt(length)}×${_fmt(thickness)} ${selectedSizeUnit.value}',
                audience: NotificationAudience.all,
                targetId: product.id,
              );
            }
          } else {
            noti.push(
              type: AppNotificationType.productAdd,
              title: 'ເພີ່ມໄມ້ໃໝ່',
              message:
                  'ເພີ່ມ "$name" (${woodType.isEmpty ? "ບໍ່ລະບຸຊະນິດ" : woodType})',
              audience: NotificationAudience.all,
              targetId: product.id,
            );
          }
        } catch (_) {}
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
      saveProgress.value = 0;
      saveStep.value = '';
    }

    return isSuccess;
  }

  // ══════════════════════════════════════════════
  // 🗑 ລຶບ
  // ══════════════════════════════════════════════
  Future<void> deleteProduct(String id) async {
    try {
      isLoading.value = true;
      final removed = products.firstWhereOrNull((p) => p.id == id);

      await dataSource.deleteWoodProduct(id);
      products.removeWhere((p) => p.id == id);   // ✅ ລຶບໃນ-memory

      if (Get.isRegistered<NotificationController>()) {
        try {
          Get.find<NotificationController>().push(
            type: AppNotificationType.saleDelete,
            title: 'ລຶບຂໍ້ມູນໄມ້',
            message: removed != null
                ? 'ລຶບ "${removed.name}" ອອກຈາກລະບົບ'
                : 'ລຶບລາຍການໄມ້ອອກຈາກລະບົບ',
            audience: NotificationAudience.all,
            targetId: id,
          );
        } catch (_) {}
      }

      Get.snackbar('ສຳເລັດ', 'ລົບຂໍ້ມູນແລ້ວ');
    } catch (e) {
      debugPrint('deleteProduct error: $e');
      Get.snackbar('ຂໍ້ຜຶດພາດ', 'ລົບບໍ່ສໍາເລັດ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════
  // 🧹 ລ້າງຟອມ
  // ══════════════════════════════════════════════
  void clearForm() {
    editingProductId.value = null;
    _originalPrice = null;
    _originalPriceUpdatedAt = null;
    nameController.clear();
    woodTypeController.clear();
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