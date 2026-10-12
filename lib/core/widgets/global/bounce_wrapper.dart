import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wood/core/utils/page_route_notifier.dart';

/// ══════════════════════════════════════════════
/// 🎈 BOUNCE WRAPPER — เด้งขึ้น-ลงในจังหวะเดียว (ลื่น)
/// ══════════════════════════════════════════════
class BounceWrapper extends StatefulWidget {
  final Widget child;
  final bool replayOnRouteChange;
  final double bounceHeight;
  final Duration duration;
  final Duration delay;

  const BounceWrapper({
    super.key,
    required this.child,
    this.replayOnRouteChange = true,
    this.bounceHeight = -10,   // ⭐ ลดจาก -12 → -10 (ดูนุ่ม)
    this.duration = const Duration(milliseconds: 500),  // ⭐ เร็วกว่าเดิม
    this.delay = Duration.zero,
  });

  @override
  State<BounceWrapper> createState() => _BounceWrapperState();
}

class _BounceWrapperState extends State<BounceWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  Timer? _delayTimer;
  DateTime _lastStart = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minReplayGap = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // ⭐ TweenSequence — เด้งขึ้น + ลง ในครั้งเดียว
    _anim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: widget.bounceHeight)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.bounceHeight, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 65,
      ),
    ]).animate(_controller);

    _start();

    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.addListener(_onRouteTick);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.removeListener(_onRouteTick);
    }
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _delayTimer?.cancel();
    _controller.stop();
    _controller.value = 0;

    if (widget.delay == Duration.zero) {
      _run();
    } else {
      _delayTimer = Timer(widget.delay, _run);
    }
    _lastStart = DateTime.now();
  }

  void _run() {
    if (!mounted) return;
    _controller.forward(from: 0);
  }

  void _onRouteTick() {
    if (!mounted) return;
    if (!TickerMode.of(context)) return;
    if (DateTime.now().difference(_lastStart) < _minReplayGap) return;

    // ⭐ ถ้ากำลัง animate อยู่ — ข้ามเลย ไม่ทับ
    if (_controller.isAnimating) return;

    _start();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _anim.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}