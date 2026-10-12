// lib\core\widgets\global\loading\loading_overlay.dart
import 'package:flutter/material.dart';
import 'loading_dialog.dart';

/// 🌫️ Loading Overlay — ครอบ widget แล้วโชว์ loader ทับ
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final double loaderSize;
  final Color barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.loaderSize = 64,
    this.barrierColor = const Color(0x40000000),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: barrierColor,
                child: LoadingDialog(
                  loaderSize: loaderSize,
                  message: message,
                ),
              ),
            ),
          ),
      ],
    );
  }
}