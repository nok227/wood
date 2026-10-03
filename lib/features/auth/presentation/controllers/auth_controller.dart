import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/menu_permission.dart';
import 'package:wood/features/home/presentation/pages/home_shell.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  static const String adminEmail = 'wood1002@gmail.com';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var currentUser = Rxn<User>();

  var allowedMenus = <String>{}.obs;
  var permissionLoaded = false.obs;

  StreamSubscription? _userDocSub;
  String? _lastBoundUid;

  bool get isAdmin =>
      currentUser.value?.email?.toLowerCase().trim() == adminEmail;

  bool canAccess(MenuKey k) {
    if (isAdmin) return true;
    if (allowedMenus.isEmpty) return false;
    return allowedMenus.contains(k.key);
  }

  bool get hasAnyPermission {
    if (isAdmin) return true;
    return allowedMenus.isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(
      FirebaseAuth.instance.authStateChanges().map((u) {
        _bindUserDoc(u?.uid);
        return u;
      }),
    );
  }

  void _bindUserDoc(String? uid) {
    if (_lastBoundUid == uid && _userDocSub != null) return;
    _lastBoundUid = uid;

    _userDocSub?.cancel();
    _userDocSub = null;

    if (uid == null) {
      debugPrint('🚪 [Auth] logout — clear allowedMenus');
      allowedMenus.clear();
      permissionLoaded.value = false;
      return;
    }

    permissionLoaded.value = false;

    debugPrint('🔗 [Auth] bind stream uid=$uid');
    _userDocSub = authRepository.userDocStream(uid).listen(
      (snap) {
        final data = snap.data();
        final list = (data?['allowedMenus'] as List?)
            ?.map((e) => e.toString())
            .toList();
        debugPrint('📥 [Auth] allowedMenus: $list');
        allowedMenus.assignAll(list ?? const []);
        permissionLoaded.value = true;
      },
      onError: (e) {
        debugPrint('❌ [Auth] stream error: $e');
        allowedMenus.clear();
        permissionLoaded.value = true;
      },
    );
  }

  Future<bool> updateUserMenuPermissions(
    String uid,
    List<String> menus,
  ) async {
    if (!isAdmin) return false;
    try {
      await authRepository.updateAllowedMenus(uid, menus);
      return true;
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກສິດໄດ້: $e');
      return false;
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  void _linkOneSignalUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      OneSignal.login(user.uid);
      debugPrint('OneSignal logged in with UID: ${user.uid}');
    }
  }

  Future<void> registerWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.registerWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _linkOneSignalUser();
      clearForm();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _linkOneSignalUser();
      clearForm();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final result = await authRepository.signInWithGoogle();
      if (result != null) {
        _linkOneSignalUser();
        clearForm();
        Get.offAll(() => const HomeShell());
      }
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      OneSignal.logout();
    } catch (_) {}
    await authRepository.signOut();
    clearForm();
  }

  @override
  void onClose() {
    _userDocSub?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}