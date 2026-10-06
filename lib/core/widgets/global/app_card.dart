import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? radius;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: radius ?? AppLayout.r12,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1.2,
              )
            : null,
        boxShadow: shadow ?? AppShadows.card,
      ),
      child: child,
    );
  }
}