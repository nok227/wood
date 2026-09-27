import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ✅ เพิ่ม
import 'auth_repository.dart';
import 'package:wood/features/wood_products/presentation/pages/home_shell.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  static const String adminEmail = 'wood1002@gmail.com';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var currentUser = Rxn<User>();

  bool get isAdmin =>
      currentUser.value?.email?.toLowerCase().trim() == adminEmail;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  // ✅ Helper: ຜູກ OneSignal ກັບ Firebase UID
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
      _linkOneSignalUser(); // ✅ เพิ่ม
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
      _linkOneSignalUser(); // ✅ เพิ่ม
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
        _linkOneSignalUser(); // ✅ เพิ่ม
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
    OneSignal.logout(); // ✅ เพิ่ม — ຍົກເລີກການຜູກ User
    await authRepository.signOut();
    clearForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}