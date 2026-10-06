import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:wood/core/constants/specific/auth_style.dart';
import '../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AuthStyle.loginTitle)),
      body: SingleChildScrollView(
        padding: AuthStyle.padPageAuth,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthStyle.gap20W,
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: AuthStyle.emailLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AuthStyle.emailRequired;
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return AuthStyle.emailInvalid;
                  }
                  return null;
                },
              ),
              AuthStyle.gapLg,
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AuthStyle.passwordLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AuthStyle.passwordRequired;
                  }
                  if (value.trim().length < 6) {
                    return AuthStyle.passwordTooShort;
                  }
                  return null;
                },
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
                            shape: const RoundedRectangleBorder(
                              borderRadius: AuthStyle.inputRadius,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.signInWithEmail();
                            }
                          },
                          child: const Text(
                            AuthStyle.loginBtn,
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
                            const Text(AuthStyle.noAccount),
                            TextButton(
                              onPressed: () {
                                controller.clearForm();
                                Get.to(() => const RegisterPage());
                              },
                              child: const Text(AuthStyle.registerBtn),
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