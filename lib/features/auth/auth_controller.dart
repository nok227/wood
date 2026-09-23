import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';
import 'package:wood/features/wood_products/presentation/pages/home_shell.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  // 🔐 อีเมล Admin เพียงจุดเดียวของทั้งแอป — แก้ตรงนี้ที่เดียวพอ
  static const String adminEmail = 'wood1002@gmail.com';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var currentUser = Rxn<User>();

  // ✅ ใช้เช็คสิทธิ์ Admin จากที่เดียวทั่วทั้งแอป
  bool get isAdmin =>
      currentUser.value?.email?.toLowerCase().trim() == adminEmail;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  // 🧹 ฟังก์ชันล้างฟอร์ม
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  // ฟังก์ชันสมัครสมาชิก
  Future<void> registerWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.registerWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      clearForm(); // 🧹 ล้างฟอร์มเมื่อสำเร็จ
      Get.offAll(() => const HomeShell());
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชันเข้าสู่ระบบด้วย Email
  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      clearForm(); // 🧹 ล้างฟอร์มเมื่อเข้าสู่ระบบสำเร็จ
      Get.offAll(() => const HomeShell());
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชันเข้าสู่ระบบด้วย Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final result = await authRepository.signInWithGoogle();
      if (result != null) {
        clearForm(); // 🧹 ล้างฟอร์มเมื่อสำเร็จ
        Get.offAll(() => const HomeShell());
      }
    } catch (e) {
      Get.snackbar('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
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