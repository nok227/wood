// lib\core\widgets\global\loading\loading_dialog.dart
import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/home_style.dart';
import 'rotating_squares_loader.dart';

/// 💬 Loading Dialog — box ลอยกลางจอ มี backdrop
class LoadingDialog extends StatelessWidget {
  final double loaderSize;
  final String? message;
  final Color? backgroundColor;

  const LoadingDialog({
    super.key,
    this.loaderSize = 64,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: backgroundColor ?? HomeStyle.bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotatingSquaresLoader(size: loaderSize),   // ⭐
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: HomeStyle.loadingText,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}