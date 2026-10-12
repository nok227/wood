import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:wood/core/services/local_storage.dart';
import 'package:wood/features/auth/domain/entities/app_user.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'app_theme_registry.dart';

class AppColorService extends GetxController {
  static AppColorService get to => Get.find();

  static const String _userKeyPrefix = 'theme_user_';

  final themeIndex = 0.obs;

  String? _currentUid;
  Worker? _authWorker;

  AppThemeData get current => kAppThemes[themeIndex.value];

  // ══════════════════════════════════════════
  // Init
  // ══════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();

    // ⭐ ให้ post-frame — รอ AuthController พร้อม
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }

  void _bind() {
    if (!Get.isRegistered<AuthController>()) return;

    final auth = Get.find<AuthController>();

    // apply ทันที (ถ้า login อยู่แล้ว)
    _applyForUser(auth.currentUser.value);

    // ฟังต่อจากนี้
    _authWorker = ever(auth.currentUser, _applyForUser);
  }

  // ══════════════════════════════════════════
  // Apply
  // ══════════════════════════════════════════
  void _applyForUser(AppUser? user) {
    _currentUid = user?.uid;

    if (_currentUid == null) {
      _setIndex(0);
      return;
    }

    final key = '$_userKeyPrefix$_currentUid';
    final local = LocalStorage.get<int>(key);
    _setIndex(local ?? 0);
  }

  void _setIndex(int index) {
    index = index.clamp(0, kAppThemes.length - 1);
    if (themeIndex.value == index) return;
    themeIndex.value = index;
    Get.forceAppUpdate();
  }

  // ══════════════════════════════════════════
  // Change
  // ══════════════════════════════════════════
  Future<void> change(int index) async {
    if (index < 0 || index >= kAppThemes.length) return;

    // ⭐ ถ้า uid ยังว่าง → ลองดึงจาก auth อีกที
    if (_currentUid == null) {
      if (Get.isRegistered<AuthController>()) {
        _currentUid = Get.find<AuthController>().currentUser.value?.uid;
      }
      if (_currentUid == null) return;
    }

    if (themeIndex.value == index) return;

    themeIndex.value = index;
    await LocalStorage.set('$_userKeyPrefix$_currentUid', index);
    Get.forceAppUpdate();
  }

  Future<void> reset() async {
    if (_currentUid == null) return;
    await LocalStorage.remove('$_userKeyPrefix$_currentUid');
    _setIndex(0);
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }
}