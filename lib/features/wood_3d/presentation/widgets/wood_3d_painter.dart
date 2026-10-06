import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_3d_style.dart';
import 'wood_3d_geometry.dart';

class _FaceDef {
  final List<int> indices;
  final Color color;
  final String grainDir;
  const _FaceDef(this.indices, this.color, this.grainDir);
}

class _DrawFace {
  final List<Offset> points;
  final List<V3> worldPoints;
  final double avgZ;
  final Color color;
  final double brightness;
  final V3 normal;
  final String grainDir;
  const _DrawFace(
    this.points,
    this.worldPoints,
    this.avgZ,
    this.color,
    this.brightness,
    this.normal,
    this.grainDir,
  );
}

class Wood3DPainter extends CustomPainter {
  final Wood3DGeometry geometry;

  Wood3DPainter(this.geometry);

  static const Color _woodLight = Wood3DStyle.woodLight;
  static const Color _woodMid = Wood3DStyle.woodMid;
  static const Color _woodDark = Wood3DStyle.woodDark;

  static const _faces = [
    _FaceDef([0, 1, 2, 3], _woodMid, 'horizontal'),
    _FaceDef([5, 4, 7, 6], _woodDark, 'horizontal'),
    _FaceDef([4, 0, 3, 7], _woodMid, 'vertical'),
    _FaceDef([1, 5, 6, 2], _woodMid, 'vertical'),
    _FaceDef([4, 5, 1, 0], _woodDark, 'vertical'),
    _FaceDef([3, 2, 6, 7], _woodLight, 'horizontal'),
  ];

  static const _lightDir = V3(0.4, 0.7, -0.6);

  V3 _faceNormal(List<V3> quad) {
    final a = quad[1].sub(quad[0]);
    final b = quad[2].sub(quad[0]);
    final n = b.cross(a);
    final len = n.length;
    if (len < 1e-9) return const V3(0, 0, -1);
    return V3(n.x / len, n.y / len, n.z / len);
  }

  void _paintWoodGrain(
    Canvas canvas,
    Path path,
    Rect bounds,
    Color baseColor,
    double brightness,
    String grainDir,
  ) {
    canvas.save();
    canvas.clipPath(path);

    final isHorizontal = grainDir == 'horizontal';
    final length = isHorizontal ? bounds.width : bounds.height;

    final lineCount = (length / 3).clamp(8, 60).toInt();

    final darkGrain = Color.lerp(
      baseColor,
      Wood3DStyle.woodShadow,
      0.35 * brightness,
    )!;
    final lightGrain = Color.lerp(
      baseColor,
      Wood3DStyle.woodLightGrain,
      0.35,
    )!;

    for (int i = 0; i < lineCount; i++) {
      final t = i / lineCount;
      final phase = i * 1.37;
      final wiggle = math.sin(phase) * 0.4 + math.cos(phase * 0.7) * 0.3;

      final thickness = 0.3 + (math.sin(phase * 1.7).abs() * 0.9);

      final isDark = (i % 3) != 0;
      final lineColor = isDark ? darkGrain : lightGrain;

      final paint = Paint()
        ..color = lineColor.withOpacity(isDark ? 0.22 : 0.12)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke;

      if (isHorizontal) {
        final y = bounds.top + bounds.height * t + wiggle * 2;
        final path2 = Path()
          ..moveTo(bounds.left, y)
          ..quadraticBezierTo(
            bounds.center.dx,
            y + wiggle * 3,
            bounds.right,
            y + wiggle * 1.5,
          );
        canvas.drawPath(path2, paint);
      } else {
        final x = bounds.left + bounds.width * t + wiggle * 2;
        final path2 = Path()
          ..moveTo(x, bounds.top)
          ..quadraticBezierTo(
            x + wiggle * 3,
            bounds.center.dy,
            x + wiggle * 1.5,
            bounds.bottom,
          );
        canvas.drawPath(path2, paint);
      }
    }

    canvas.restore();
  }

  void _paintAmbientOcclusion(
    Canvas canvas,
    Path path,
    Rect bounds,
    double strength,
  ) {
    if (strength <= 0.01) return;

    canvas.save();
    canvas.clipPath(path);

    final occl = ui.Gradient.radial(
      bounds.center,
      bounds.longestSide * 0.55,
      [
        Wood3DStyle.transparent,
        Wood3DStyle.transparent,
        Wood3DStyle.black.withOpacity(0.28 * strength),
      ],
      const [0.0, 0.65, 1.0],
    );
    canvas.drawRect(bounds, Paint()..shader = occl);

    canvas.restore();
  }

  void _paintSpecular(
    Canvas canvas,
    Path path,
    Rect bounds,
    double strength,
  ) {
    if (strength <= 0.01) return;

    canvas.save();
    canvas.clipPath(path);

    final center = Offset(
      bounds.left + bounds.width * 0.28,
      bounds.top + bounds.height * 0.22,
    );
    final rad = bounds.longestSide * 0.5;

    final hi = ui.Gradient.radial(
      center,
      rad,
      [
        Wood3DStyle.white.withOpacity(0.28 * strength),
        Wood3DStyle.white.withOpacity(0.08 * strength),
        Wood3DStyle.transparent,
      ],
      const [0.0, 0.4, 1.0],
    );
    canvas.drawRect(bounds, Paint()..shader = hi);

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final allDrawFaces = <_DrawFace>[];

    for (final baseBox in geometry.allBoxesVertices) {
      final rotated = baseBox.map(geometry.transform).toList();

      for (final f in _faces) {
        final quad = f.indices.map((i) => rotated[i]).toList();
        final n = _faceNormal(quad);
        final avgZ =
            quad.map((v) => v.z).reduce((a, b) => a + b) / quad.length;

        final lambert = n.dot(_lightDir).clamp(0.0, 1.0);
        final brightness = 0.42 + 0.58 * lambert;

        Color shaded = Color.lerp(
          Color.lerp(Wood3DStyle.black, f.color, brightness)!,
          Wood3DStyle.white,
          lambert * 0.10,
        )!;

        final points = quad.map((v) => geometry.project(v, size)).toList();
        allDrawFaces.add(
          _DrawFace(
            points,
            quad,
            avgZ,
            shaded,
            brightness,
            n,
            f.grainDir,
          ),
        );
      }
    }

    allDrawFaces.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    for (final face in allDrawFaces) {
      final path = Path()..addPolygon(face.points, true);
      final bounds = path.getBounds();

      final baseGrad = ui.Gradient.linear(
        bounds.topLeft,
        bounds.bottomRight,
        [
          Color.lerp(face.color, Wood3DStyle.white, 0.10)!,
          face.color,
          Color.lerp(face.color, Wood3DStyle.black, 0.12)!,
        ],
        const [0.0, 0.5, 1.0],
      );
      canvas.drawPath(path, Paint()..shader = baseGrad);

      _paintWoodGrain(
        canvas,
        path,
        bounds,
        face.color,
        face.brightness,
        face.grainDir,
      );

      _paintAmbientOcclusion(
        canvas,
        path,
        bounds,
        1.0 - face.brightness * 0.6,
      );

      final spec = math.pow(face.normal.dot(_lightDir).clamp(0.0, 1.0), 3)
          .toDouble();
      _paintSpecular(canvas, path, bounds, spec);

      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            face.color,
            Wood3DStyle.woodShadow,
            0.65,
          )!
              .withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Wood3DStyle.white.withOpacity(0.10 * face.brightness)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    _paintGroundShadow(canvas, size);
  }

  void _paintGroundShadow(Canvas canvas, Size size) {
    double maxY = -double.infinity;
    double minX = double.infinity, maxX = -double.infinity;
    double sumZ = 0;
    int count = 0;

    for (final box in geometry.allBoxesVertices) {
      for (final v in box) {
        final p = geometry.project(geometry.transform(v), size);
        if (p.dy > maxY) maxY = p.dy;
        if (p.dx < minX) minX = p.dx;
        if (p.dx > maxX) maxX = p.dx;
        sumZ += v.z;
        count++;
      }
    }
    if (count == 0) return;

    final shadowCenter = Offset((minX + maxX) / 2, maxY + 2);
    final shadowWidth = (maxX - minX) * 0.85;
    final shadowHeight = shadowWidth * 0.18;

    final rect = Rect.fromCenter(
      center: shadowCenter,
      width: shadowWidth,
      height: shadowHeight,
    );

    final shadow = ui.Gradient.radial(
      shadowCenter,
      shadowWidth * 0.5,
      [
        Wood3DStyle.black.withOpacity(0.22),
        Wood3DStyle.black.withOpacity(0.08),
        Wood3DStyle.transparent,
      ],
      const [0.0, 0.5, 1.0],
    );

    canvas.drawOval(rect, Paint()..shader = shadow);
  }

  @override
  bool shouldRepaint(covariant Wood3DPainter oldDelegate) => true;
}