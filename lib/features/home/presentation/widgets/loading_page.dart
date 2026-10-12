import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/core/widgets/global/loading/rotating_squares_loader.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3 สี่เหลี่ยมหมุนวน
            const RotatingSquaresLoader(),
            HomeStyle.gapLg,
            Text(
              HomeStyle.loading,
              style: HomeStyle.loadingText,
            ),
          ],
        ),
      ),
    );
  }
}