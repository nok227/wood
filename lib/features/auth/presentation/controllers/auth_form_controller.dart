import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthFormController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clear() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'email required';
    if (!GetUtils.isEmail(v.trim())) return 'email invalid';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'password required';
    if (v.trim().length < 6) return 'password too short';
    return null;
  }
}