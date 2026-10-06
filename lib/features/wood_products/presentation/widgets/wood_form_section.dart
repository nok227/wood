import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import 'package:wood/features/wood_products/presentation/widgets/section_wrapper.dart';

class WoodFormSection extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Widget child;
  final bool done;
  final bool warning;

  const WoodFormSection({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.child,
    this.done = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      number: number,
      title: title,
      icon: icon,
      color: WoodStyle.brown700,
      done: done,
      warning: warning,
      child: child,
    );
  }
}