// lib\core\widgets\global\loading\loading_page.dart
import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/home_style.dart';
import 'rotating_squares_loader.dart';

class LoadingPage extends StatelessWidget {
  final String? message;
  final double loaderSize;
  final Color? backgroundColor;

  const LoadingPage({
    super.key,
    this.message,
    this.loaderSize = 90,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? HomeStyle.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotatingSquaresLoader(size: loaderSize),   // ⭐
            HomeStyle.gapLg,
            Text(
              message ?? HomeStyle.loading,
              style: HomeStyle.loadingText,
            ),
          ],
        ),
      ),
    );
  }
}