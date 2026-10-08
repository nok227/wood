import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown700.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}