import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/home_style.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.bg,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: HomeStyle.primary),
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