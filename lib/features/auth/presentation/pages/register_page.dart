import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:wood/core/constants/specific/auth_style.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AuthStyle.registerTitle)),
      body: SingleChildScrollView(
        padding: AuthStyle.padPageAuth,
        child: Column(
          children: [
            AuthStyle.gap20W,
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: AuthStyle.nameLabel,
                border: OutlineInputBorder(),
              ),
            ),
            AuthStyle.gapMd,
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: AuthStyle.emailLabel,
                border: OutlineInputBorder(),
              ),
            ),
            AuthStyle.gapMd,
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AuthStyle.passwordLabel,
                border: OutlineInputBorder(),
              ),
            ),
            AuthStyle.gap24W,
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                              AuthStyle.buttonHeight),
                          backgroundColor: AuthStyle.primary,
                        ),
                        onPressed: controller.registerWithEmail,
                        child: const Text(
                          AuthStyle.registerBtn,
                          style: AuthStyle.loginBtnText,
                        ),
                      ),
                      AuthStyle.gapLg,
                      const Text(AuthStyle.orLabel),
                      AuthStyle.gapLg,
                      SizedBox(
                        width: double.infinity,
                        height: AuthStyle.buttonHeight,
                        child: SignInButton(
                          Buttons.google,
                          text: AuthStyle.googleBtn,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AuthStyle.inputRadius,
                          ),
                          onPressed: controller.signInWithGoogle,
                        ),
                      ),
                      AuthStyle.gap24W,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(AuthStyle.hasAccount),
                          TextButton(
                            onPressed: () {
                              Get.off(() => LoginPage());
                            },
                            child: const Text(AuthStyle.loginBtn),
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