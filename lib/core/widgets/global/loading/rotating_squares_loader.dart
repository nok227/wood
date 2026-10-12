// lib\core\widgets\global\loading\rotating_squares_loader.dart
import 'package:flutter/material.dart';

/// Loader แบบ "sliding puzzle": สี่เหลี่ยมมนสามอันสไลด์ไปช่องว่างในตาราง 2x2
class RotatingSquaresLoader extends StatefulWidget {
  const RotatingSquaresLoader({
    super.key,
    this.size = 64,
    this.red = const Color(0xFFD34A62),
    this.green = const Color(0xFFABC284),
    this.orange = const Color(0xFFEFAF6C),
  });

  final double size;
  final Color red;
  final Color green;
  final Color orange;

  @override
  State<RotatingSquaresLoader> createState() => _RotatingSquaresLoaderState();
}

class _RotatingSquaresLoaderState extends State<RotatingSquaresLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _Painter.periodMs),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _Painter(
          progress: _controller,
          colors: [widget.red, widget.green, widget.orange],
        ),
      ),
    );
  }
}

class _Move {
  const _Move(this.square, this.from, this.to);
  final int square;
  final int from;
  final int to;
}

class _Painter extends CustomPainter {
  _Painter({required this.progress, required this.colors})
      : super(repaint: progress);

  final Animation<double> progress;
  final List<Color> colors;

  static const int moveMs = 200;
  static const int moveCount = 12;
  static const int pauseMs = 1400;
  static const int periodMs = moveMs * moveCount + pauseMs;

  static const List<Offset> _slots = [
    Offset(0, 0),
    Offset(1, 0),
    Offset(1, 1),
    Offset(0, 1),
  ];

  static final List<List<int?>> _states = [];
  static final List<_Move> _moves = [];
  static bool _built = false;

  static void _build() {
    if (_built) return;
    _built = true;
    final ring = <int?>[0, 1, null, 2];
    for (var i = 0; i < moveCount; i++) {
      _states.add(List<int?>.of(ring));
      final empty = ring.indexOf(null);
      final source = (empty + 3) % 4;
      _moves.add(_Move(ring[source]!, source, empty));
      ring[empty] = ring[source];
      ring[source] = null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _build();

    final side = size.width;
    final sq = side * 0.454;
    final step = side - sq;
    final radius = Radius.circular(sq * 0.14);

    final ms = progress.value * periodMs;

    List<int?> ring;
    _Move? move;
    var t = 0.0;
    if (ms >= moveMs * moveCount) {
      ring = _states[0];
    } else {
      final k = ms ~/ moveMs;
      ring = _states[k];
      move = _moves[k];
      t = Curves.easeInOutCubic.transform((ms % moveMs) / moveMs);
    }

    for (var slot = 0; slot < 4; slot++) {
      final id = ring[slot];
      if (id == null) continue;

      var pos = _slots[slot] * step;
      if (move != null && slot == move.from) {
        pos = Offset.lerp(_slots[move.from] * step, _slots[move.to] * step, t)!;
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pos.dx, pos.dy, sq, sq),
          radius,
        ),
        Paint()..color = colors[id],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => old.colors != colors;
}