import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F0EA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.brown),
            SizedBox(height: 16),
            Text(
              'ກຳລັງໂຫຼດ...',
              style: TextStyle(color: Colors.brown, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}