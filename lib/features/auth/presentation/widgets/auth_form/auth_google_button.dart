import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class AuthGoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: SignInButton(
          Buttons.google,
          text: label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}