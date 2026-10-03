import 'package:flutter/material.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double progress;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
    required this.progress,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final dx = (progress * 3) - 1.5;
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        colors: const [
          Color(0xFFE0E0E0),
          Color(0xFFF5F5F5),
          Color(0xFFE0E0E0),
        ],
        stops: const [0.35, 0.5, 0.65],
        begin: Alignment(-1 + dx, 0),
        end: Alignment(1 + dx, 0),
      ).createShader(rect),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: shape,
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}