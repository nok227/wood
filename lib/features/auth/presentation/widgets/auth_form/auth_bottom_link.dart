import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AuthBottomLink extends StatelessWidget {
  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  const AuthBottomLink({
    super.key,
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            buttonLabel,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.brown700,
            ),
          ),
        ),
      ],
    );
  }
}