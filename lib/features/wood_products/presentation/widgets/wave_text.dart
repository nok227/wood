import 'package:flutter/material.dart';
import 'package:wood/core/util/page_route_notifier.dart';

class WaveText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const WaveText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.forward();

    // 🔔 replay ຕອນ route/tab ປ່ຽນ
    PageRouteNotifier.instance.tick.addListener(_onRouteTick);
  }

  @override
  void didUpdateWidget(covariant WaveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    PageRouteNotifier.instance.tick.removeListener(_onRouteTick);
    _controller.dispose();
    super.dispose();
  }

  void _onRouteTick() {
    if (!mounted) return;
    if (!TickerMode.of(context)) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');
    final int count = characters.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final double maxDelay = 0.3;
        final double delay =
            count > 1 ? (index / (count - 1)) * maxDelay : 0.0;
        const double durationRatio = 0.7;

        final Animation<double> animation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: -14.0)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -14.0, end: 0.0)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay,
              (delay + durationRatio).clamp(0.0, 1.0),
            ),
          ),
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, animation.value),
              child: child,
            );
          },
          child: Text(characters[index], style: widget.style),
        );
      }),
    );
  }
}