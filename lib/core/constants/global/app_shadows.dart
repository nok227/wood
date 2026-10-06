import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════
/// 🌐 GLOBAL SHADOWS — ใช้ใน 30+ ไฟล์
///
/// วิธีใช้:
///   Container(decoration: BoxDecoration(boxShadow: AppShadows.card))
/// ══════════════════════════════════════════════
class AppShadows {
  AppShadows._();

  // ══════════════════════════════════════════
  // 🎴 Card มาตรฐาน — ใช้ 20+ ไฟล์
  //    widgets: sale_card, wood_list_group, session_section,
  //             recipe_card, notification_page, ...
  // ══════════════════════════════════════════
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ══════════════════════════════════════════
  // 🎴 Card กลาง — ใช้ 8 ไฟล์
  //    pages: account_page (session), sale_detail, sale_summary
  // ══════════════════════════════════════════
  static List<BoxShadow> get cardMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  // ══════════════════════════════════════════
  // 🎴 Card ใหญ่ — ใช้ 4 ไฟล์
  //    pages: sale_detail (combined), sale_summary (total)
  // ══════════════════════════════════════════
  static List<BoxShadow> get cardLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ══════════════════════════════════════════
  // 🎨 Shadow สี — ใช้ 10+ ไฟล์
  //    สำหรับปุ่ม gradient ที่มีสี
  //    pages: action_buttons, sale_list (FAB), summary cards
  // ══════════════════════════════════════════
  static List<BoxShadow> colored(Color c) => [
        BoxShadow(
          color: c.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ];
}