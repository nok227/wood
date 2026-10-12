// lib\core\widgets\global\loading\loading_button.dart
import 'package:flutter/material.dart';
import 'rotating_squares_loader.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final double loaderSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.loaderSize = 26,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: loaderSize,
                height: loaderSize,
                child: RotatingSquaresLoader(size: loaderSize),   // ⭐
              )
            : child,
      ),
    );
  }
}