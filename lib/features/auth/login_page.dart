import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Key สำหรับตรวจสอบ Validation ของ Form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('ເຂົ້າສູ່ລະບົບ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // 📌 ผูก FormKey ที่นี่
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. ช่องกรอก Email + Validator
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ອີເມວ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ກະລຸນາປ້ອນອີເມວ';
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'ຮູບແບບອີເມວບໍ່ຖືກຕ້ອງ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. ช่องกรอก Password + Validator
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'ລະຫັດຜ່ານ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
                  }
                  if (value.trim().length < 6) {
                    return 'ລະຫັດຜ່ານຕ້ອງຢ່າງນ້ອຍ 6 ຕົວອັກສອນ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 3. ปุ่มกดเข้าสู่ระบบ
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // 📌 ตรวจสอบเงื่อนไขผ่าน Validator ก่อนเรียก Login
                            if (_formKey.currentState!.validate()) {
                              controller.signInWithEmail();
                            }
                          },
                          child: const Text(
                            'ເຂົ້າສູ່ລະບົບ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('ຫຼື'),
                        const SizedBox(height: 16),

                        // ✅ ปุ่มเข้าสู่ระบบด้วย Google ตามสเปกดีไซน์จริงของ Google
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: SignInButton(
                            Buttons.google,
                            text: 'ເຂົ້າສູ່ລະບົບດ້ວຍ Google',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onPressed: controller.signInWithGoogle,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ปุ่มสลับไปหน้าลงทะเบียน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ຍັງບໍ່ມີບັນຊີ? '),
                            TextButton(
                              onPressed: () {
                                controller.clearForm(); // ล้างฟอร์มเมื่อสลับหน้า
                                Get.to(() => const RegisterPage());
                              },
                              child: const Text('ລົງທະບຽນ'),
                            ),
                          ],
                        ),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }
}