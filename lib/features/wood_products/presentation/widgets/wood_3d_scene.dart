import 'dart:async';
import 'package:flutter/material.dart';
import 'wood_3d_geometry.dart';
import 'wood_3d_painter.dart';

class _ArrowSpec {
  final Offset from, to;
  final Color color;
  const _ArrowSpec(this.from, this.to, this.color);
}

class _LabelItem {
  final String id;
  final Offset anchor;
  Offset pos;
  final String text;
  final Color color;

  _LabelItem(this.id, this.anchor, this.pos, this.text, this.color);
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

  const Wood3DScene({
    super.key,
    this.productName,
    required this.width,
    required this.length,
    required this.thickness,
    required this.sizeUnit,
    this.unit,
    this.focusedDimension,
  });

  @override
  State<Wood3DScene> createState() => _Wood3DSceneState();
}

class _Wood3DSceneState extends State<Wood3DScene> {
  static const double _defaultRotationX = -0.5;
  static const double _defaultRotationY = 2.4;

  double rotationX = _defaultRotationX;
  double rotationY = _defaultRotationY;
  double _zoom = 1.0;
  double _zoomStart = 1.0;
  double _lastRotation = 0.0;
  bool _dragging = false;
  Timer? _stopTimer;

  @override
  void didUpdateWidget(covariant Wood3DScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ เช็คเฉพาะเมื่อ "ชื่อสินค้าเปลี่ยน" ไปเป็นอย่างอื่นเท่านั้น ถึงจะรีเซ็ตมุมมองกลับท่าแรก
    // ถ้าชื่อเดิม แต่ขนาด (width, length, thickness) เปลี่ยน จะไม่รีเซ็ตมุมมอง
    final isDifferentProduct = oldWidget.productName != widget.productName;

    if (isDifferentProduct) {
      setState(() {
        rotationX = _defaultRotationX;
        rotationY = _defaultRotationY;
        _zoom = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails d) {
    _stopTimer?.cancel();
    _zoomStart = _zoom;
    _lastRotation = 0.0;
    setState(() => _dragging = true);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _zoom = (_zoomStart * d.scale).clamp(0.5, 3.5);
      rotationY += d.focalPointDelta.dx * 0.01;
      rotationX -= d.focalPointDelta.dy * 0.01;

      if (d.pointerCount >= 2) {
        final deltaRotation = d.rotation - _lastRotation;
        rotationY += deltaRotation;
        _lastRotation = d.rotation;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails _) {
    _stopTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _dragging = false);
    });
  }

  // ✅ ตรวจสอบประเภทโมเดล
  FrameType _getFrameType(String? name, String? unit) {
    final n = name?.trim().toLowerCase() ?? '';
    final u = unit?.trim().toLowerCase() ?? '';

    // เช็คกรณีวงกบช่องลม / หน้าต่าง (สี่เหลี่ยมปิด 4 ด้าน)
    final isVentOrWindow = n.contains('ປ່ອງລົມ') ||
        n.contains('ช่องลม') ||
        n.contains('ໜ້າຕ່າງ') ||
        n.contains('หน้าต่าง') ||
        u.contains('ປ່ອງລົມ') ||
        u.contains('ช่องลม');

    if (isVentOrWindow) {
      return FrameType.window;
    }

    // เช็คกรณีวงกบประตูทั่วไป (3 ด้าน)
    final isDoor = n.contains('ວົງ') ||
        n.contains('วง') ||
        n.contains('ປະຕູ') ||
        n.contains('ประตู') ||
        u.contains('ວົງ') ||
        u.contains('วง');

    if (isDoor) {
      return FrameType.door;
    }

    return FrameType.none;
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

  List<Widget> _buildLabels(Wood3DGeometry g, Size size) {
    final center = g.center(size);

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

    final items = <_LabelItem>[];

    for (final spec in filtered) {
      final id = spec.$1;
      final anchor = spec.$2;
      final text = spec.$3;
      final color = spec.$4;

      final dir = anchor - center;
      final dist = dir.distance == 0 ? 1.0 : dir.distance;
      var normalized = Offset(dir.dx / dist, dir.dy / dist);

      if (id == 'width') {
        normalized += const Offset(-0.35, -0.25);
      } else if (id == 'thickness') {
        normalized += const Offset(0.35, 0.25);
      }

      final normLen = normalized.distance == 0 ? 1.0 : normalized.distance;
      normalized = Offset(normalized.dx / normLen, normalized.dy / normLen);

      var labelPos = anchor + normalized * 52;
      labelPos = Offset(
        labelPos.dx.clamp(70.0, size.width - 70),
        labelPos.dy.clamp(20.0, size.height - 20),
      );

      items.add(_LabelItem(id, anchor, labelPos, text, color));
    }

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        final itemA = items[i];
        final itemB = items[j];

        final rectA = Rect.fromCenter(
          center: itemA.pos,
          width: 140,
          height: 28,
        );
        final rectB = Rect.fromCenter(
          center: itemB.pos,
          width: 140,
          height: 28,
        );

        if (rectA.overlaps(rectB)) {
          final shiftX = (itemB.pos.dx >= itemA.pos.dx) ? 50.0 : -50.0;
          final shiftY = (itemB.pos.dy >= itemA.pos.dy) ? 25.0 : -25.0;

          itemB.pos = Offset(
            (itemB.pos.dx + shiftX).clamp(70.0, size.width - 70),
            (itemB.pos.dy + shiftY).clamp(20.0, size.height - 20),
          );
        }
      }
    }

    final arrows = <_ArrowSpec>[];
    final texts = <Widget>[];

    for (final item in items) {
      arrows.add(_ArrowSpec(item.anchor, item.pos, item.color));
      texts.add(
        Positioned(
          left: item.pos.dx,
          top: item.pos.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2),
                ],
              ),
              child: Text(
                item.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [CustomPaint(size: size, painter: _ArrowsPainter(arrows)), ...texts];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Container(
        width: double.infinity,
        color: Colors.brown[50],
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final frameType = _getFrameType(widget.productName, widget.unit);

            final geometry = Wood3DGeometry(
              width: widget.width,
              length: widget.length,
              thickness: widget.thickness,
              rotationX: rotationX,
              rotationY: rotationY,
              frameType: frameType,
            );

            final children = <Widget>[
              CustomPaint(size: size, painter: Wood3DPainter(geometry)),
              if (!_dragging) ..._buildLabels(geometry, size),
            ];

            return Transform.scale(
              scale: _zoom,
              child: Stack(children: children),
            );
          },
        ),
      ),
    );
  }
}