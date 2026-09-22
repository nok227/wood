import 'dart:math';
import 'package:flutter/material.dart';

// ✅ ประเภทโครงสร้างโมเดล 3D
enum FrameType {
  none,   // ไม้แผ่น / ไม้กล่องปกติ
  door,   // วงกบประตู (3 ด้าน: เสาซ้าย, เสาขวา, ทับหลัง)
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

  V3 rotate(double rx, double ry) => rotateX(rx).rotateY(ry);

  double dot(V3 o) => x * o.x + y * o.y + z * o.z;

  V3 sub(V3 o) => V3(x - o.x, y - o.y, z - o.z);

  V3 cross(V3 o) => V3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => sqrt(x * x + y * y + z * z);

  Offset operator -(V3 o) => Offset(x - o.x, y - o.y);
}

class Wood3DGeometry {
  final double width;
  final double length;
  final double thickness;
  final double rotationX;
  final double rotationY;
  final FrameType frameType; // ✅ เปลี่ยนใช้ FrameType
  static const cameraDistance = 4.0;

  Wood3DGeometry({
    required this.width,
    required this.length,
    required this.thickness,
    required this.rotationX,
    required this.rotationY,
    this.frameType = FrameType.none,
  });

  double get _maxDim => [width, length, thickness].reduce((a, b) => a > b ? a : b);

  late final double hx = width / _maxDim;
  late final double hy = thickness / _maxDim;
  late final double hz = length / _maxDim;

  List<V3> _createBoxVertices(double minX, double maxX, double minY, double maxY, double minZ, double maxZ) {
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
      // ✅ ชี้ไปที่ฐานขอบล่างซ้ายของเสาประตู ไม่ให้ชี้กลางช่องว่าง
      target = V3(-hx, -hy, -hz);
    } else {
      // ไม้แผ่น หรือ วงกบช่องลม (ที่มีคานล่าง)
      final outer = _createBoxVertices(-hx, hx, -hy, hy, -hz, hz);
      target = _mid(outer[1], outer[0]);
    }
    return project(target.rotate(rotationX, rotationY), size);
  }

  Offset lengthAnchor(Size size) {
    final outer = _createBoxVertices(-hx, hx, -hy, hy, -hz, hz)
        .map((v) => v.rotate(rotationX, rotationY))
        .toList();
    return project(_mid(outer[4], outer[0]), size);
  }

  Offset thicknessAnchor(Size size) {
    final outer = _createBoxVertices(-hx, hx, -hy, hy, -hz, hz)
        .map((v) => v.rotate(rotationX, rotationY))
        .toList();
    return project(_mid(outer[3], outer[0]), size);
  }
}