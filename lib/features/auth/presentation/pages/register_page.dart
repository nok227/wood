import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/loading/loading.dart';   // ⭐

import '../controllers/auth_controller.dart';
import '../controllers/auth_form_controller.dart';
import '../widgets/auth_form/auth_hero_header.dart';
import '../widgets/auth_form/auth_field.dart';
import '../widgets/auth_form/auth_primary_button.dart';
import '../widgets/auth_form/auth_or_divider.dart';
import '../widgets/auth_form/auth_form_card.dart';
import '../widgets/auth_form/auth_google_button.dart';
import '../widgets/auth_form/auth_bottom_link.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final form = Get.find<AuthFormController>();

    return Scaffold(
      backgroundColor: AuthStyle.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthHeroHeader(),
              const SizedBox(height: 4),

              AuthFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthField(
                      controller: form.nameController,
                      label: AuthStyle.nameLabel,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      controller: form.emailController,
                      label: AuthStyle.emailLabel,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      controller: form.passwordController,
                      label: AuthStyle.passwordLabel,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 22),

                    // ⭐ ใช้ LoadingButton
                    Obx(() => LoadingButton(
                          isLoading: controller.isLoading.value,
                          onPressed: controller.registerWithEmail,
                          backgroundColor: AuthStyle.primary,
                          foregroundColor: AuthStyle.white,
                          loaderSize: 24,
                          height: 52,
                          borderRadius: BorderRadius.circular(14),
                          child: Text(
                            AuthStyle.registerBtn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: AuthOrDivider(label: AuthStyle.orLabel),
              ),
              const SizedBox(height: 20),

              AuthGoogleButton(
                label: AuthStyle.googleBtn,
                onPressed: controller.signInWithGoogle,
              ),

              const SizedBox(height: 24),

              AuthBottomLink(
                label: AuthStyle.hasAccount,
                buttonLabel: AuthStyle.loginBtn,
                onTap: () => Get.off(() => const LoginPage()),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}