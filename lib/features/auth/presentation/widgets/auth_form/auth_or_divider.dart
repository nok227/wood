import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.grey300),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.grey300),
        ),
      ],
    );
  }
}