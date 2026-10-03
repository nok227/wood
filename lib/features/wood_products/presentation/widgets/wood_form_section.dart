import 'package:flutter/material.dart';
import 'package:wood/core/widgets/section_wrapper.dart';

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
      color: Colors.brown,
      done: done,
      warning: warning,
      child: child,
    );
  }
}