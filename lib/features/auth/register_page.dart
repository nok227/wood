import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'auth_controller.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('ລົງທະບຽນເຂົ້າໃຊ້ງານ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'ຊື່ ແລະ ນາມສະກຸນ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'ອີເມວ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'ລະຫັດຜ່ານ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.brown,
                        ),
                        onPressed: controller.registerWithEmail,
                        child: const Text('ລົງທະບຽນ',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ມີບັນຊີຢູ່ແລ້ວ? '),
                          TextButton(
                            onPressed: () {
                              Get.off(() => LoginPage());
                            },
                            child: const Text('ເຂົ້າສູ່ລະບົບ'),
                          ),
                        ],
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}