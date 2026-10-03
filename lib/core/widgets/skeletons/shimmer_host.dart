import 'package:flutter/material.dart';

class ShimmerHost extends StatefulWidget {
  final Widget Function(BuildContext context, double progress) builder;
  const ShimmerHost({super.key, required this.builder});

  @override
  State<ShimmerHost> createState() => _ShimmerHostState();
}

class _ShimmerHostState extends State<ShimmerHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => widget.builder(context, _ctrl.value),
      ),
    );
  }
}