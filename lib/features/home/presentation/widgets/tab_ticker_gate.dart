import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabTickerGate extends StatelessWidget {
  final int index;
  final RxInt currentIndex;
  final Widget child;

  const TabTickerGate({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = currentIndex.value == index;
      return TickerMode(
        enabled: active,
        child: ExcludeFocus(excluding: !active, child: child),
      );
    });
  }
}