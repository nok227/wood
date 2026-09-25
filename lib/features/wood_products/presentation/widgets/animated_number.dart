import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/util/page_route_notifier.dart';

/// 🔢 ຕົວເລກວິ່ງ (Count-up animation)
///
/// - ວິ່ງຕອນ mount ຄັ້ງທຳອິດ (animateOnMount)
/// - ວິ່ງໃໝ່ຕອນຄ່າປ່ຽນ (animateOnChange)
/// - ວິ່ງໃໝ່ຕອນ route/tab ປ່ຽນ (replayOnRouteChange)
class AnimatedNumber extends StatefulWidget {
  final num value;
  final TextStyle? style;
  final int duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final String format;
  final int decimals;
  final bool animateOnChange;
  final bool animateOnMount;
  final bool replayOnRouteChange;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = 1600,
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.format = '#,###',
    this.decimals = 0,
    this.animateOnChange = true,
    this.animateOnMount = true,
    this.replayOnRouteChange = true,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  late NumberFormat _fmt;

  @override
  void initState() {
    super.initState();
    _fmt = NumberFormat(widget.format);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _anim = Tween<double>(
      begin: widget.animateOnMount ? 0 : widget.value.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.animateOnMount) _ctrl.forward();

    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.addListener(_onRouteTick);
    }
  }

  @override
  void dispose() {
    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.removeListener(_onRouteTick);
    }
    _ctrl.dispose();
    super.dispose();
  }

  void _onRouteTick() {
    if (!mounted) return;
    if (!TickerMode.of(context)) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    _anim = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));
    _ctrl
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.format != widget.format) {
      _fmt = NumberFormat(widget.format);
    }

    if (oldWidget.value != widget.value && widget.animateOnChange) {
      _anim = Tween<double>(
        begin: oldWidget.value.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final v = _anim.value;
        final text =
            widget.decimals > 0 ? _fmt.format(v) : _fmt.format(v.round());
        return Text(
          '${widget.prefix}$text${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}