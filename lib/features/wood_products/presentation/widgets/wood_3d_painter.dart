// lib/features/wood_products/presentation/widgets/wood_3d_painter.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'wood_3d_geometry.dart';

class _FaceDef {
  final List<int> indices;
  final Color color;
  const _FaceDef(this.indices, this.color);
}

class _DrawFace {
  final List<Offset> points;
  final double avgZ;
  final Color color;
  const _DrawFace(this.points, this.avgZ, this.color);
}

class Wood3DPainter extends CustomPainter {
  final Wood3DGeometry geometry;

  Wood3DPainter(this.geometry);

  static const _faces = [
    _FaceDef([0, 1, 2, 3], Color(0xFFE3C9A0)), // หน้า
    _FaceDef([5, 4, 7, 6], Color(0xFFD3B58C)), // หลัง
    _FaceDef([4, 0, 3, 7], Color(0xFFDCC7A4)), // ซ้าย
    _FaceDef([1, 5, 6, 2], Color(0xFFE3C9A0)), // ขวา
    _FaceDef([4, 5, 1, 0], Color(0xFFC7AE86)), // ล่าง
    _FaceDef([3, 2, 6, 7], Color(0xFFF0E0C0)), // บน
  ];

  static const _lightDir = V3(0.4, 0.7, -0.6);

  /// คำนวณ normal จริงจากพิกัดที่หมุนแล้ว แทนการใช้ normal ตายตัวตามแกน
  /// จำเป็นสำหรับชิ้นวงกบที่มีหน้าตัดเฉียง 45° ซึ่งไม่ได้ตั้งฉากกับแกนอีกต่อไป
  V3 _faceNormal(List<V3> quad) {
    final a = quad[1].sub(quad[0]);
    final b = quad[2].sub(quad[0]);
    final n = b.cross(a);
    final len = n.length;
    if (len < 1e-9) return const V3(0, 0, -1);
    return V3(n.x / len, n.y / len, n.z / len);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final allDrawFaces = <_DrawFace>[];

    // วนลูปวาดกล่องทุกชิ้น (กรณีเป็นวงกบจะมี 3 ชิ้น: เสาซ้าย เสาขวา ทับหลัง)
    for (final baseBox in geometry.allBoxesVertices) {
      final rotated = baseBox.map((v) => v.rotate(geometry.rotationX, geometry.rotationY)).toList();

      for (final f in _faces) {
        final quad = f.indices.map((i) => rotated[i]).toList();
        final n = _faceNormal(quad);
        final avgZ = quad.map((v) => v.z).reduce((a, b) => a + b) / quad.length;
        final brightness = 0.55 + 0.45 * n.dot(_lightDir).clamp(0.0, 1.0);
        final shaded = Color.lerp(Colors.black, f.color, brightness)!;

        final points = quad.map((v) => geometry.project(v, size)).toList();
        allDrawFaces.add(_DrawFace(points, avgZ, shaded));
      }
    }

    // เรียงลำดับจากไกลไปใกล้ (Z-sorting)
    allDrawFaces.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    for (final face in allDrawFaces) {
      final path = Path()..addPolygon(face.points, true);
      final bounds = path.getBounds();

      // ✅ ไล่เฉดสีอ่อน->เข้มในแต่ละหน้า แทนสีตันสีเดียว ให้ดูมีมิติ/เป็นเนื้อไม้จริง
      // ไม่ให้แบนเหมือนกระดาษ (ซึ่งทำให้ตรงกลางดูโบ๋ ๆ ขณะที่ขอบเด่นเพราะเส้นขอบหนา)
      final gradient = ui.Gradient.linear(
        bounds.topLeft,
        bounds.bottomRight,
        [
          Color.lerp(face.color, Colors.white, 0.16)!,
          face.color,
          Color.lerp(face.color, Colors.black, 0.14)!,
        ],
        const [0.0, 0.55, 1.0],
      );
      canvas.drawPath(path, Paint()..shader = gradient);

      // เส้นขอบบางลง สีกลืนไปกับเนื้อไม้แทนที่จะเป็นเส้นดำหนาล้อมกรอบ
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(face.color, const Color(0xFF3E2723), 0.6)!
              .withOpacity(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Wood3DPainter oldDelegate) => true;
}