import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/sale_style.dart';

class FullImageViewer extends StatefulWidget {
  final File file;
  const FullImageViewer({super.key, required this.file});

  @override
  State<FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<FullImageViewer> {
  final _tc = TransformationController();
  double _dy = 0;
  int _pointers = 0;
  bool _dragging = false;

  bool get _zoomed => _tc.value.getMaxScaleOnAxis() > 1.02;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _onMove(PointerMoveEvent e) {
    if (_pointers != 1 || _zoomed) return;
    setState(() { _dragging = true; _dy += e.delta.dy; });
  }

  void _onEnd() {
    if (_pointers > 0) return;
    if (!_dragging) return;
    final h = MediaQuery.of(context).size.height;
    if (_dy.abs() > 110) {
      setState(() { _dragging = false; _dy = _dy > 0 ? h : -h; });
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) Get.back();
      });
    } else {
      setState(() { _dragging = false; _dy = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final progress = (_dy.abs() / (h * 0.4)).clamp(0.0, 1.0);
    final dur = _dragging ? Duration.zero : const Duration(milliseconds: 180);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        duration: dur,
        color: SaleStyle.black.withOpacity(1 - 0.75 * progress),
        child: Stack(children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) {
                _pointers++;
                if (_pointers > 1) setState(() => _dy = 0);
              },
              onPointerMove: _onMove,
              onPointerUp: (_) { _pointers--; _onEnd(); },
              onPointerCancel: (_) { _pointers--; _onEnd(); },
              child: AnimatedContainer(
                duration: dur,
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _dy, 0),
                child: InteractiveViewer(
                  transformationController: _tc,
                  minScale: 1, maxScale: 6,
                  child: Center(child: Image.file(widget.file, fit: BoxFit.contain)),
                ),
              ),
            ),
          ),
          SafeArea(child: Align(
            alignment: Alignment.topRight,
            child: Opacity(
              opacity: 1 - progress,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: SaleStyle.white, size: 28),
              ),
            ),
          )),
        ]),
      ),
    );
  }
}