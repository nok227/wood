import 'package:flutter/material.dart';
import '../../../../core/util/page_route_notifier.dart';

class WaveText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// 🔔 replay ອະນິເມຊັນຕອນ route/tab ປ່ຽນ
  /// - ສຳລັບ title ໃນ AppBar ແນະນຳໃຫ້ຕັ້ງເປັນ `false` ເພື່ອກັນກະຕຸກ
  final bool replayOnRouteChange;

  const WaveText({
    super.key,
    required this.text,
    this.style,
    this.replayOnRouteChange = true,
  });

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// ✅ ເວລາທີ່ເລີ່ມ replay ຫຼ້າສຸດ — ກັນ replay ຊ້ອນກັນໃນເວລາສັ້ນ
  DateTime _lastStart = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minReplayGap = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _start();

    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.addListener(_onRouteTick);
    }
  }

  @override
  void didUpdateWidget(covariant WaveText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ ຖ້າ flag ປ່ຽນ — ຈັດການ listener
    if (oldWidget.replayOnRouteChange != widget.replayOnRouteChange) {
      if (widget.replayOnRouteChange) {
        PageRouteNotifier.instance.tick.addListener(_onRouteTick);
      } else {
        PageRouteNotifier.instance.tick.removeListener(_onRouteTick);
      }
    }

    if (oldWidget.text != widget.text) {
      _start();
    }
  }

  @override
  void dispose() {
    if (widget.replayOnRouteChange) {
      PageRouteNotifier.instance.tick.removeListener(_onRouteTick);
    }
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _controller.reset();
    _controller.forward();
    _lastStart = DateTime.now();
  }

  void _onRouteTick() {
    if (!mounted) return;
    if (!TickerMode.of(context)) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    // ✅ ຖ້າຫາກເລີ່ມໄປບໍ່ຮອດ _minReplayGap ຢ່າລົບກວນ (ກັນກະຕຸກ)
    if (DateTime.now().difference(_lastStart) < _minReplayGap) return;

    _start();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.split('');
    final n = chars.length;

    // ✅ ໃຊ້ AnimatedBuilder ອັນດຽວຄຸມທັງ Row — ບໍ່ໃຊ້ per-char
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(n, (i) {
            final delay = n > 1 ? (i / (n - 1)) * 0.3 : 0.0;

            final seq = TweenSequence<double>([
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
                  (delay + 0.7).clamp(0.0, 1.0),
                ),
              ),
            );

            return Transform.translate(
              offset: Offset(0, seq.value),
              child: Text(chars[i], style: widget.style),
            );
          }),
        );
      },
    );
  }
}