import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double height;
  final Color? color;
  final EdgeInsets padding;

  const DashedDivider({
    super.key,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
    this.height = 1.0,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.grey200;
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(width: dashWidth, height: height, color: c),
            ),
          );
        },
      ),
    );
  }
}