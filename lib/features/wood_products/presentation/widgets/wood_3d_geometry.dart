import 'dart:math';
import 'package:flutter/material.dart';

// ✅ ประเภทโครงสร้างโมเดล 3D
enum FrameType {
  none, // ไม้แผ่น / ไม้กล่องปกติ
  door, // วงกบประตู (3 ด้าน: เสาซ้าย, เสาขวา, ทับหลัง)
  window, // วงกบช่องลม/หน้าต่าง (4 ด้าน: สี่เหลี่ยมปิดสมบูรณ์)
}

class V3 {
  final double x, y, z;
  const V3(this.x, this.y, this.z);

  V3 rotateX(double angle) {
    final c = cos(angle), s = sin(angle);
    return V3(x, y * c - z * s, y * s + z * c);
  }

  V3 rotateY(double angle) {
    final c = cos(angle), s = sin(angle);
    return V3(x * c + z * s, y, -x * s + z * c);
  }

  V3 rotate(double rx, double ry) => rotateY(ry).rotateX(rx);

  double dot(V3 o) => x * o.x + y * o.y + z * o.z;

  V3 sub(V3 o) => V3(x - o.x, y - o.y, z - o.z);

  V3 cross(V3 o) => V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => sqrt(x * x + y * y + z * z);

  Offset operator -(V3 o) => Offset(x - o.x, y - o.y);
}

/// เมทริกซ์หมุน 3x3 เก็บ "ท่าทางปัจจุบัน" ของโมเดล
/// หมุนอิสระทุกทิศตามแกนของ "หน้าจอ" ไม่ผูกกับแกนบน/ล่างของโมเดล
/// ทำให้ลากซ้าย/ขวา/ขึ้น/ลง ได้ผลเหมือนกันทุกมุมมอง (หน้า หลัง บน ล่าง)
class Rot3 {
  final List<double> m; // 9 ค่า เรียงทีละแถว: m[แถว * 3 + คอลัมน์]
  const Rot3._(this.m);

  static const Rot3 identity = Rot3._([
    1.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    1.0,
  ]);

  static Rot3 get front => Rot3.fromYawPitch(0, 0);
  static Rot3 get top => Rot3.fromYawPitch(0, pi / 2);
  static Rot3 get side => Rot3.fromYawPitch(pi / 2, 0);

  factory Rot3.rotX(double a) {
    final c = cos(a), s = sin(a);
    return Rot3._([1.0, 0.0, 0.0, 0.0, c, -s, 0.0, s, c]);
  }

  factory Rot3.rotY(double a) {
    final c = cos(a), s = sin(a);
    return Rot3._([c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c]);
  }

  /// ท่าเริ่มต้น: หมุนรอบแกนตั้ง (yaw) ก่อน แล้วก้ม (pitch) ตามหน้าจอ
  factory Rot3.fromYawPitch(double yaw, double pitch) =>
      Rot3.rotX(pitch).mul(Rot3.rotY(yaw));

  /// this * o
  Rot3 mul(Rot3 o) {
    final r = List<double>.filled(9, 0.0);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        r[i * 3 + j] =
            m[i * 3] * o.m[j] +
            m[i * 3 + 1] * o.m[3 + j] +
            m[i * 3 + 2] * o.m[6 + j];
      }
    }
    return Rot3._(r);
  }

  V3 apply(V3 v) => V3(
    m[0] * v.x + m[1] * v.y + m[2] * v.z,
    m[3] * v.x + m[4] * v.y + m[5] * v.z,
    m[6] * v.x + m[7] * v.y + m[8] * v.z,
  );

  /// หมุนเพิ่มตามการลากบนหน้าจอ
  /// dx > 0 (ลากขวา) = หมุนรอบแกนตั้งของหน้าจอ, dy > 0 (ลากลง) = หมุนรอบแกนนอนของหน้าจอ
  Rot3 rotatedByScreenDrag(double dx, double dy) {
    final delta = Rot3.rotX(dy).mul(Rot3.rotY(dx));
    return delta.mul(this).orthonormalized();
  }

  /// กันค่าคลาดเคลื่อนสะสมจากการคูณเมทริกซ์ซ้ำๆ (Gram-Schmidt)
  Rot3 orthonormalized() {
    final r0 = _unit(V3(m[0], m[1], m[2]));
    var r1 = V3(m[3], m[4], m[5]);
    final d = r1.dot(r0);
    r1 = _unit(V3(r1.x - d * r0.x, r1.y - d * r0.y, r1.z - d * r0.z));
    final r2 = r0.cross(r1);
    return Rot3._([r0.x, r0.y, r0.z, r1.x, r1.y, r1.z, r2.x, r2.y, r2.z]);
  }

  static V3 _unit(V3 v) {
    final l = v.length;
    return l < 1e-12 ? v : V3(v.x / l, v.y / l, v.z / l);
  }
}

class Wood3DGeometry {
  final double width;
  final double length;
  final double thickness;

  /// ท่าทางของโมเดล (หมุนอิสระทุกทิศ)
  final Rot3 orientation;
  final FrameType frameType; // ✅ เปลี่ยนใช้ FrameType
  static const cameraDistance = 4.0;

  Wood3DGeometry({
    required this.width,
    required this.length,
    required this.thickness,
    required this.orientation,
    this.frameType = FrameType.none,
  });

  double get _maxDim =>
      [width, length, thickness].reduce((a, b) => a > b ? a : b);

  late final double hx = width / _maxDim;
  late final double hy = thickness / _maxDim;
  late final double hz = length / _maxDim;

  List<V3> _createBoxVertices(
    double minX,
    double maxX,
    double minY,
    double maxY,
    double minZ,
    double maxZ,
  ) {
    return [
      V3(minX, minY, minZ),
      V3(maxX, minY, minZ),
      V3(maxX, maxY, minZ),
      V3(minX, maxY, minZ),
      V3(minX, minY, maxZ),
      V3(maxX, minY, maxZ),
      V3(maxX, maxY, maxZ),
      V3(minX, maxY, maxZ),
    ];
  }

  // เสาแนวตั้ง (ตัดเฉียงบน และตัดเฉียงล่างกรณีเป็นวงกบช่องลม)
  List<V3> _createMiteredSideVertices({
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
    required double outerBottomZ,
    required double innerBottomZ,
    required double outerTopZ,
    required double innerTopZ,
    required bool innerIsMaxX,
  }) {
    final bottomZAtMinX = innerIsMaxX ? outerBottomZ : innerBottomZ;
    final bottomZAtMaxX = innerIsMaxX ? innerBottomZ : outerBottomZ;
    final topZAtMinX = innerIsMaxX ? outerTopZ : innerTopZ;
    final topZAtMaxX = innerIsMaxX ? innerTopZ : outerTopZ;
    return [
      V3(minX, minY, bottomZAtMinX),
      V3(maxX, minY, bottomZAtMaxX),
      V3(maxX, maxY, bottomZAtMaxX),
      V3(minX, maxY, bottomZAtMinX),
      V3(minX, minY, topZAtMinX),
      V3(maxX, minY, topZAtMaxX),
      V3(maxX, maxY, topZAtMaxX),
      V3(minX, maxY, topZAtMinX),
    ];
  }

  // คานแนวนอน (ทับหลัง / คานล่าง)
  List<V3> _createMiteredHorizontalVertices({
    required double outerLeftX,
    required double innerLeftX,
    required double outerRightX,
    required double innerRightX,
    required double minY,
    required double maxY,
    required double innerZ,
    required double outerZ,
  }) {
    return [
      V3(innerLeftX, minY, innerZ),
      V3(innerRightX, minY, innerZ),
      V3(innerRightX, maxY, innerZ),
      V3(innerLeftX, maxY, innerZ),
      V3(outerLeftX, minY, outerZ),
      V3(outerRightX, minY, outerZ),
      V3(outerRightX, maxY, outerZ),
      V3(outerLeftX, maxY, outerZ),
    ];
  }

  List<List<V3>> get allBoxesVertices {
    if (frameType == FrameType.none) {
      return [_createBoxVertices(-hx, hx, -hy, hy, -hz, hz)];
    }

    final border = (2 * hy).clamp(0.0, min(hx, hz) * 0.9);
    final isWindow = frameType == FrameType.window;

    final leftJamb = _createMiteredSideVertices(
      minX: -hx,
      maxX: -hx + border,
      minY: -hy,
      maxY: hy,
      outerBottomZ: -hz,
      innerBottomZ: isWindow ? -hz + border : -hz,
      outerTopZ: hz,
      innerTopZ: hz - border,
      innerIsMaxX: true,
    );

    final rightJamb = _createMiteredSideVertices(
      minX: hx - border,
      maxX: hx,
      minY: -hy,
      maxY: hy,
      outerBottomZ: -hz,
      innerBottomZ: isWindow ? -hz + border : -hz,
      outerTopZ: hz,
      innerTopZ: hz - border,
      innerIsMaxX: false,
    );

    final head = _createMiteredHorizontalVertices(
      outerLeftX: -hx,
      innerLeftX: -hx + border,
      outerRightX: hx,
      innerRightX: hx - border,
      minY: -hy,
      maxY: hy,
      innerZ: hz - border,
      outerZ: hz,
    );

    // ✅ กรณีเป็นวงกบช่องลม/หน้าต่าง ให้เพิ่มคานล่างกลายเป็นสี่เหลี่ยมปิด 4 ด้าน
    if (isWindow) {
      final sill = _createMiteredHorizontalVertices(
        outerLeftX: -hx,
        innerLeftX: -hx + border,
        outerRightX: hx,
        innerRightX: hx - border,
        minY: -hy,
        maxY: hy,
        innerZ: -hz + border,
        outerZ: -hz,
      );
      return [leftJamb, rightJamb, head, sill];
    }

    return [leftJamb, rightJamb, head];
  }

  /// หมุนจุดตามท่าทางปัจจุบันของโมเดล
  V3 transform(V3 v) => orientation.apply(v);

  Offset project(V3 p, Size size) {
    final perspective = cameraDistance / (cameraDistance - p.z);
    final baseScale = size.shortestSide / 2 * 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    return Offset(
      center.dx + p.x * baseScale * perspective,
      center.dy - p.y * baseScale * perspective,
    );
  }

  Offset center(Size size) => project(const V3(0, 0, 0), size);

  V3 _mid(V3 a, V3 b) => V3((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2);

  Offset widthAnchor(Size size) {
    V3 target;
    if (frameType == FrameType.door) {
      target = V3(0, -hy, hz);
    } else {
      final outer = _createBoxVertices(-hx, hx, -hy, hy, -hz, hz);
      target = _mid(outer[1], outer[0]);
    }
    return project(transform(target), size);
  }

  Offset lengthAnchor(Size size) {
    final outer = _createBoxVertices(
      -hx,
      hx,
      -hy,
      hy,
      -hz,
      hz,
    ).map(transform).toList();
    return project(_mid(outer[4], outer[0]), size);
  }

  Offset thicknessAnchor(Size size) {
    final outer = _createBoxVertices(
      -hx,
      hx,
      -hy,
      hy,
      -hz,
      hz,
    ).map(transform).toList();
    return project(_mid(outer[3], outer[0]), size);
  }
}
