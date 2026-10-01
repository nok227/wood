// lib/features/wood_products/presentation/widgets/wood_3d_scene.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'wood_3d_geometry.dart';
import 'wood_3d_painter.dart';

class _ArrowSpec {
  final Offset from, to;
  final Color color;
  const _ArrowSpec(this.from, this.to, this.color);
}

class _ArrowsPainter extends CustomPainter {
  final List<_ArrowSpec> specs;
  _ArrowsPainter(this.specs);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in specs) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(s.from, s.to, paint);
      canvas.drawCircle(s.from, 3, Paint()..color = s.color);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowsPainter oldDelegate) => true;
}

class Wood3DScene extends StatefulWidget {
  final String? productName;
  final double width;
  final double length;
  final double thickness;
  final String sizeUnit;
  final String? unit;
  final String? focusedDimension;
  final bool showColor;
  final VoidCallback? onToggleColor;

  const Wood3DScene({
    super.key,
    this.productName,
    required this.width,
    required this.length,
    required this.thickness,
    required this.sizeUnit,
    this.unit,
    this.focusedDimension,
    this.showColor = false,
    this.onToggleColor,
  });

  @override
  State<Wood3DScene> createState() => _Wood3DSceneState();
}

class _Wood3DSceneState extends State<Wood3DScene> {
  static const double _defaultRotationX = 0.4;
  static const double _defaultRotationY = 2.38;
  static const double _defaultZoom = 1.0;

  TextStyle get _labelStyle => TextStyle(
    color: widget.showColor ? Colors.white : Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  Rot3 _orientation = Rot3.fromYawPitch(_defaultRotationY, _defaultRotationX);
  double _zoom = _defaultZoom;
  double _zoomStart = _defaultZoom;
  Offset _offset = Offset.zero;
  bool _dragging = false;
  bool _showQuickViews = false;
  Timer? _stopTimer;

  @override
  void didUpdateWidget(covariant Wood3DScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productName != widget.productName) {
      _resetView();
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    super.dispose();
  }

  void _resetView() {
    setState(() {
      _orientation = Rot3.fromYawPitch(_defaultRotationY, _defaultRotationX);
      _zoom = _defaultZoom;
      _offset = Offset.zero;
    });
  }

  void _setView(Rot3 targetOrientation) {
    setState(() {
      _orientation = targetOrientation;
      _offset = Offset.zero;
    });
  }

  void _onScaleStart(ScaleStartDetails d) {
    _stopTimer?.cancel();
    _zoomStart = _zoom;
    setState(() => _dragging = true);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      if (d.pointerCount >= 2) {
        _zoom = (_zoomStart * d.scale).clamp(0.5, 3.5);
        _offset += d.focalPointDelta;
      } else {
        _orientation = _orientation.rotatedByScreenDrag(
          d.focalPointDelta.dx * 0.01,
          d.focalPointDelta.dy * 0.01,
        );
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails _) {
    _stopTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _dragging = false);
    });
  }

  // ══════════════════════════════════════════════
  // 🎯 Frame Type Detection
  //   ✅ ລຳດັບການກວດ: leaves → vent → windowFrame → door
  //      (ເພື່ອບໍ່ໃຫ້ 'ວົງປ່ອງລົມ' ຖືກຈັບເປັນ windowFrame ຜິດ)
  // ══════════════════════════════════════════════
  FrameType _getFrameType(String? name, String? unit) {
    final n = name?.trim().toLowerCase() ?? '';
    final u = unit?.trim().toLowerCase() ?? '';

    // ─── helpers ───
    bool isVent(String s) =>
        s.contains('ປ່ອງລົມ') || s.contains('ຊ່ອງລົມ') || s.contains('ช่องลม');

    bool isWindowFrame(String s) =>
        s.contains('ວົງປ່ອງຢ້ຽມ') || // 🆕 ໃໝ່
        s.contains('ວົງໜ້າຕ່າງ') || // ເກົ່າ (backward compat)
        s.contains('วงหน้าต่าง') ||
        s.contains('ວົງປ່ອງ') ||
        s.contains('วงช่อง') ||
        s.contains('ວົງປະຕູລົມ');

    // 🆕 ຮວມຊື່ເກົ່າ + ໃໝ່ (ວົງນ້ອຍ / ວົງໄຫຍ່)
    bool isDoorFrame(String s) =>
        s.contains('ວົງນ້ອຍ') ||
        s.contains('ວົງໄຫຍ່') ||
        s.contains('ວົງປະຕູ') ||
        s.contains('วงประตู');

    bool isDoorLeaf(String s) =>
        s.contains('ບານປະຕູ') || s.contains('บานประตู');

    // ✅ ຮວມຊື່ເກົ່າ + ໃໝ່ (ບານປ່ອງລົມ)
    bool isWindowLeaf(String s) =>
        s.contains('ບານປ່ອງຢ້ຽມ') ||
        s.contains('ບານໜ້າຕ່າງ') ||
        s.contains('บานหน้าต่าง') ||
        s.contains('ບານຊ່ອງ') ||
        s.contains('ບານປ່ອງລົມ') ||   // 🆕
        s.contains('ບານປ່ອງ');

    // ─── ① ກວດ leaves ກ່ອນ (ສຳຄັນທີ່ສຸດ — ບໍ່ໃຫ້ 'ບານປ່ອງລົມ' ຖືກຈັບເປັນ vent) ───
    if (isDoorLeaf(u)) return FrameType.none;
    if (isWindowLeaf(u)) return FrameType.none;

    // ─── ② ກວດ vent ກ່ອນ windowFrame ───
    //     ເພາະ 'ວົງປ່ອງລົມ' ມີຄຳ 'ວົງປ່ອງ' ຄືກັນກັບ windowFrame
    if (isVent(u)) return FrameType.window;

    // ─── ③ ກວດ windowFrame / door ───
    if (isWindowFrame(u)) return FrameType.windowFrame;
    if (isDoorFrame(u)) return FrameType.door;
    if (u == 'ວົງ' || u == 'วง') return FrameType.door;   // 🆕 generic
    if (u == 'ແຜ່ນ' || u == 'ທ່ອນ' || u == 'ແຜ່ນໄມ້' || u == 'ທ່ອນໄມ້') {
      return FrameType.none;
    }

    // ─── ④ Fallback: ກວດ name ───
    if (isVent(n)) return FrameType.window;
    if (isWindowFrame(n)) return FrameType.windowFrame;
    if (isDoorFrame(n)) return FrameType.door;
    if (!isDoorLeaf(n) && !isWindowLeaf(n)) {
      if (n.contains('ປະຕູ') || n.contains('ประตู')) {
        return FrameType.door;
      }
      if (n.contains('ປ່ອງຢ້ຽມ') ||
          n.contains('ໜ້າຕ່າງ') ||
          n.contains('หน้าต่าง')) {
        return FrameType.windowFrame;
      }
    }

    return FrameType.none;
  }

  // ══════════════════════════════════════════════
  // 🎯 Panel Count
  //   ດຶງເລກຈາກ "N ບານ" ກ່ອນ
  //   ຖ້າບໍ່ມີ → ໃຊ້ keyword ນ້ອຍ/ໄຫຍ່ ຫຼື default
  // ══════════════════════════════════════════════
  int _getPanelCount(FrameType ft, String? unit) {
    final u = unit?.trim().toLowerCase() ?? '';

    // ① regex "N ບານ"
    final m = RegExp(r'(\d+)\s*ບານ').firstMatch(u);
    if (m != null) {
      final n = int.tryParse(m.group(1) ?? '');
      if (n != null && n > 0 && n <= 8) return n;
    }

    // ② keyword ນ້ອຍ / ໄຫຍ່
    if (u.contains('ນ້ອຍ')) return 2;   // ວົງນ້ອຍ → 2 ບານ
    if (u.contains('ໄຫຍ່')) return 4;   // ວົງໄຫຍ່ → 4 ບານ

    // ③ default
    if (ft == FrameType.door) return 2;
    if (ft == FrameType.windowFrame) return 1;
    return 1;
  }

  String _formatDimWithConversions(double val, String unit) {
    final u = unit.toLowerCase().trim();
    double mm, cm, m;

    if (u == 'mm') {
      mm = val;
      cm = val / 10;
      m = val / 1000;
    } else if (u == 'cm') {
      mm = val * 10;
      cm = val;
      m = val / 100;
    } else {
      mm = val * 1000;
      cm = val * 100;
      m = val;
    }

    String fmt(double n) {
      if (n == n.roundToDouble()) return n.toStringAsFixed(0);
      if (n < 0.01) return n.toStringAsFixed(3);
      return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }

    if (u == 'mm') {
      return '${fmt(mm)}mm (${fmt(cm)}cm / ${fmt(m)}m)';
    } else if (u == 'cm') {
      return '${fmt(cm)}cm (${fmt(mm)}mm / ${fmt(m)}m)';
    } else {
      return '${fmt(m)}m (${fmt(cm)}cm / ${fmt(mm)}mm)';
    }
  }

  Offset _toScreen(Offset p, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    return c + (p - c) * _zoom + _offset;
  }

  Rect _modelScreenBounds(Wood3DGeometry g, Size size) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final box in g.allBoxesVertices) {
      for (final v in box) {
        final p = _toScreen(g.project(g.transform(v), size), size);
        minX = math.min(minX, p.dx);
        maxX = math.max(maxX, p.dx);
        minY = math.min(minY, p.dy);
        maxY = math.max(maxY, p.dy);
      }
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Size _measureLabel(String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(_labelStyle),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final s = Size(tp.width + 20, tp.height + 7);
    tp.dispose();
    return s;
  }

  double _overlapArea(Rect a, Rect b) {
    final i = a.intersect(b);
    if (i.width <= 0 || i.height <= 0) return 0;
    return i.width * i.height;
  }

  double _clampSafe(double v, double lo, double hi, double fallback) =>
      lo > hi ? fallback : v.clamp(lo, hi).toDouble();

  Rect _placeLabel(
    Size box,
    Offset anchor,
    Rect model,
    Size view,
    List<Rect> placed,
  ) {
    const gap = 10.0;
    const pad = 4.0;
    final w = box.width, h = box.height;

    final xs = [
      anchor.dx,
      model.left + w / 2,
      model.right - w / 2,
      model.center.dx,
    ];
    final ys = [
      anchor.dy,
      model.top + h / 2,
      model.bottom - h / 2,
      model.center.dy,
    ];

    final candidates = <Offset>[];
    for (final x in xs) {
      candidates.add(Offset(x, model.top - gap - h / 2));
      candidates.add(Offset(x, model.bottom + gap + h / 2));
    }
    for (final y in ys) {
      candidates.add(Offset(model.left - gap - w / 2, y));
      candidates.add(Offset(model.right + gap + w / 2, y));
    }

    Rect? best;
    double bestCost = double.infinity;

    for (final c in candidates) {
      final cx = _clampSafe(
        c.dx,
        pad + w / 2,
        view.width - pad - w / 2,
        view.width / 2,
      );
      final cy = _clampSafe(
        c.dy,
        pad + h / 2,
        view.height - pad - h / 2,
        view.height / 2,
      );
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

      var cost = (rect.center - anchor).distance;
      cost += _overlapArea(rect, model) * 0.5;
      for (final p in placed) {
        cost += _overlapArea(rect.inflate(3), p) * 1.0;
      }

      if (cost < bestCost) {
        bestCost = cost;
        best = rect;
      }
    }
    return best!;
  }

  List<Widget> _buildLabels(Wood3DGeometry g, Size size) {
    final rawSpecs = [
      (
        'width',
        g.widthAnchor(size),
        'ກວ້າງ ${_formatDimWithConversions(widget.width, widget.sizeUnit)}',
        Colors.blue,
      ),
      (
        'length',
        g.lengthAnchor(size),
        'ຍາວ ${_formatDimWithConversions(widget.length, widget.sizeUnit)}',
        Colors.green,
      ),
      (
        'thickness',
        g.thicknessAnchor(size),
        'ໜາ ${_formatDimWithConversions(widget.thickness, widget.sizeUnit)}',
        Colors.orange,
      ),
    ];

    final filtered = widget.focusedDimension == null
        ? rawSpecs
        : rawSpecs.where((e) => e.$1 == widget.focusedDimension).toList();

    final modelRect = _modelScreenBounds(g, size);
    final placed = <Rect>[];
    final arrows = <_ArrowSpec>[];
    final texts = <Widget>[];

    for (final spec in filtered) {
      final anchor = _toScreen(spec.$2, size);
      final text = spec.$3;
      final color = spec.$4;

      final rect = _placeLabel(
        _measureLabel(text),
        anchor,
        modelRect,
        size,
        placed,
      );
      placed.add(rect);

      final lineEnd = Offset(
        anchor.dx.clamp(rect.left, rect.right).toDouble(),
        anchor.dy.clamp(rect.top, rect.bottom).toDouble(),
      );
      arrows.add(
        _ArrowSpec(anchor, lineEnd, widget.showColor ? color : Colors.black87),
      );

      texts.add(
        Positioned(
          left: rect.center.dx,
          top: rect.center.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
              decoration: widget.showColor
                  ? BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 2),
                      ],
                    )
                  : null,
              child: Text(text, style: _labelStyle),
            ),
          ),
        ),
      );
    }

    return [CustomPaint(size: size, painter: _ArrowsPainter(arrows)), ...texts];
  }

  Widget _buildQuickViewButtons() {
    return Positioned(
      right: 12,
      bottom: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _showQuickViews ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.fastOutSlowIn,
            child: AnimatedSlide(
              offset: _showQuickViews ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 120),
              curve: Curves.fastOutSlowIn,
              child: IgnorePointer(
                ignoring: !_showQuickViews,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _viewBtn(
                      'ດ້ານເທິງ',
                      Icons.navigation,
                      () => _setView(Rot3.top),
                    ),
                    const SizedBox(height: 6),
                    _viewBtn(
                      'ດ້ານໜ້າ',
                      Icons.crop_square,
                      () => _setView(Rot3.front),
                    ),
                    const SizedBox(height: 6),
                    _viewBtn(
                      'ດ້ານຂ້າງ',
                      Icons.view_column,
                      () => _setView(Rot3.side),
                    ),
                    const SizedBox(height: 6),
                    _viewBtn(
                      'ດ້ານສະຫຼຽງ (ເລີ່ມຕົ້ນ)',
                      Icons.restart_alt,
                      _resetView,
                    ),
                    if (widget.onToggleColor != null) ...[
                      const SizedBox(height: 6),
                      _viewBtn(
                        widget.showColor ? 'ປິດສີ' : 'ສີ',
                        widget.showColor
                            ? Icons.format_color_reset
                            : Icons.palette,
                        widget.onToggleColor!,
                        autoClose: false,
                        active: widget.showColor,
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          FloatingActionButton.small(
            heroTag: 'toggle_3d_quick_views',
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () {
              setState(() {
                _showQuickViews = !_showQuickViews;
              });
            },
            child: AnimatedRotation(
              turns: _showQuickViews ? 0.125 : 0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.fastOutSlowIn,
              child: Icon(
                _showQuickViews ? Icons.close : Icons.explore,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewBtn(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool autoClose = true,
    bool active = false,
  }) {
    final bgColor = active
        ? Colors.brown.shade700
        : Colors.white.withOpacity(0.95);
    final fgColor = active ? Colors.white : Colors.brown.shade700;
    final textColor = active ? Colors.white : Colors.brown.shade900;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? Colors.brown.shade800 : Colors.brown,
          width: active ? 1.4 : 0.8,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            onPressed();
            if (autoClose) {
              setState(() {
                _showQuickViews = false;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: fgColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onDoubleTap: _resetView,
      child: Container(
        width: double.infinity,
        color: Colors.brown[50],
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final frameType = _getFrameType(widget.productName, widget.unit);
              final panelCount = _getPanelCount(frameType, widget.unit);

              final geometry = Wood3DGeometry(
                width: widget.width,
                length: widget.length,
                thickness: widget.thickness,
                orientation: _orientation,
                frameType: frameType,
                panelCount: panelCount,
              );

              return SizedBox(
                width: size.width,
                height: size.height,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: _offset,
                      child: Transform.scale(
                        scale: _zoom,
                        child: CustomPaint(
                          size: size,
                          painter: Wood3DPainter(geometry),
                        ),
                      ),
                    ),
                    if (!_dragging) ..._buildLabels(geometry, size),
                    _buildQuickViewButtons(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}