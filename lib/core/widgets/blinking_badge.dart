import 'package:flutter/material.dart';

class BlinkingBadge extends StatefulWidget {
  final String text;
  final Color color;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;
  final double fontSize;
  final EdgeInsets padding;

  const BlinkingBadge({
    super.key,
    required this.text,
    required this.color,
    this.duration = const Duration(milliseconds: 800),
    this.minOpacity = 0.35,
    this.maxOpacity = 1.0,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
  });

  @override
  State<BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  late Animation<double> _fade = Tween<double>(
    begin: widget.minOpacity,
    end: widget.maxOpacity,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void didUpdateWidget(covariant BlinkingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _ctrl.duration = widget.duration;
      _ctrl
        ..reset()
        ..repeat(reverse: true);
    }
    if (oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _fade = Tween<double>(
        begin: widget.minOpacity,
        end: widget.maxOpacity,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: widget.color.withOpacity(0.6), width: 0.8),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w900,
            color: widget.color,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}