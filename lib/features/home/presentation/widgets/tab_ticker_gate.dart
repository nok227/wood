import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TabTickerGate extends StatelessWidget {
  final int index;
  final ValueListenable<int> currentIndex;
  final Widget child;

  const TabTickerGate({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, current, child) {
        final active = current == index;
        return TickerMode(
          enabled: active,
          child: ExcludeFocus(excluding: !active, child: child!),
        );
      },
      child: child,
    );
  }
}