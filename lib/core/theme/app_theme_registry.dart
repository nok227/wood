import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════
/// 🎨 THEME REGISTRY — 6 ธีมสี
/// แต่ละธีม = brown scale + bg + primary aliases
/// ══════════════════════════════════════════════
class AppThemeData {
  final String id;
  final String label;
  final Color bg;
  final Color p50, p100, p200, p300, p400, p500, p600, p700, p800, p900;

  const AppThemeData({
    required this.id,
    required this.label,
    required this.bg,
    required this.p50,
    required this.p100,
    required this.p200,
    required this.p300,
    required this.p400,
    required this.p500,
    required this.p600,
    required this.p700,
    required this.p800,
    required this.p900,
  });

  // Aliases
  Color get primary => p700;
  Color get primaryDark => p800;
  Color get primaryLight => p50;
  Color get primaryMid => p400;
  Color get primarySoft => p200;
  Color get gradStart => p700;
  Color get gradEnd => p500;
  Color get gradStartDark => p800;
  Color get gradEndDark => p600;
}

const List<AppThemeData> kAppThemes = [
  // ── 0. น้ำตาล (default) ──
  AppThemeData(
    id: 'brown',
    label: 'ນ້ຳຕານ',
    bg: Color(0xFFF5F0EA),
    p50: Color(0xFFEFEBE9),
    p100: Color(0xFFD7CCC8),
    p200: Color(0xFFBCAAA4),
    p300: Color(0xFFA1887F),
    p400: Color(0xFF8D6E63),
    p500: Color(0xFF795548),
    p600: Color(0xFF6D4C41),
    p700: Color(0xFF5D4037),
    p800: Color(0xFF4E342E),
    p900: Color(0xFF3E2723),
  ),
  // ── 1. คราม ──
  AppThemeData(
    id: 'indigo',
    label: 'ຄາມ',
    bg: Color(0xFFF5F4FA),
    p50: Color(0xFFE8EAF6),
    p100: Color(0xFFC5CAE9),
    p200: Color(0xFF9FA8DA),
    p300: Color(0xFF7986CB),
    p400: Color(0xFF5C6BC0),
    p500: Color(0xFF3F51B5),
    p600: Color(0xFF3949AB),
    p700: Color(0xFF303F9F),
    p800: Color(0xFF283593),
    p900: Color(0xFF1A237E),
  ),
  // ── 2. ม่วงเข้ม ──
  AppThemeData(
    id: 'deepPurple',
    label: 'ມ່ວງເຂັ້ມ',
    bg: Color(0xFFF4F5FB),
    p50: Color(0xFFEDE7F6),
    p100: Color(0xFFD1C4E9),
    p200: Color(0xFFB39DDB),
    p300: Color(0xFF9575CD),
    p400: Color(0xFF7E57C2),
    p500: Color(0xFF673AB7),
    p600: Color(0xFF5E35B1),
    p700: Color(0xFF512DA8),
    p800: Color(0xFF4527A0),
    p900: Color(0xFF311B92),
  ),
  // ── 3. บัว ──
  AppThemeData(
    id: 'pink',
    label: 'ບົວ',
    bg: Color(0xFFFDF2F5),
    p50: Color(0xFFFCE4EC),
    p100: Color(0xFFF8BBD0),
    p200: Color(0xFFF48FB1),
    p300: Color(0xFFF06292),
    p400: Color(0xFFEC407A),
    p500: Color(0xFFE91E63),
    p600: Color(0xFFD81B60),
    p700: Color(0xFFC2185B),
    p800: Color(0xFFAD1457),
    p900: Color(0xFF880E4F),
  ),
  // ── 4. ม่วง ──
  AppThemeData(
    id: 'purple',
    label: 'ມ່ວງ',
    bg: Color(0xFFF8F4FB),
    p50: Color(0xFFF3E5F5),
    p100: Color(0xFFE1BEE7),
    p200: Color(0xFFCE93D8),
    p300: Color(0xFFBA68C8),
    p400: Color(0xFFAB47BC),
    p500: Color(0xFF9C27B0),
    p600: Color(0xFF8E24AA),
    p700: Color(0xFF7B1FA2),
    p800: Color(0xFF6A1B9A),
    p900: Color(0xFF4A148C),
  ),
  // ── 5. เขียวมรกต ──
  AppThemeData(
    id: 'teal',
    label: 'ຂຽວມ່ວງ',
    bg: Color(0xFFF2F9F9),
    p50: Color(0xFFE0F2F1),
    p100: Color(0xFFB2DFDB),
    p200: Color(0xFF80CBC4),
    p300: Color(0xFF4DB6AC),
    p400: Color(0xFF26A69A),
    p500: Color(0xFF009688),
    p600: Color(0xFF00897B),
    p700: Color(0xFF00796B),
    p800: Color(0xFF00695C),
    p900: Color(0xFF004D40),
  ),
];