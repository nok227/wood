import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';

/// ══════════════════════════════════════════════
/// 🌐 GLOBAL TEXT STYLES — ใช้ใน 50+ ไฟล์
///
/// วิธีใช้:
///   Text('ຫົວຂໍ້', style: AppTextStyles.heading2)
/// ══════════════════════════════════════════════
class AppTextStyles {
  AppTextStyles._();

  // ══════════════════════════════════════════
  // 📰 Headers — ใช้ 30+ ไฟล์
  // ══════════════════════════════════════════
  static const heading1 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87);
  static const heading2 = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87);
  static const heading3 = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87);
  static const title = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87);

  // ══════════════════════════════════════════
  // 📝 Body — ใช้ 40+ ไฟล์
  // ══════════════════════════════════════════
  static const body = TextStyle(fontSize: 13, color: Colors.black87);
  static const bodyBold =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87);
  static const bodySmall = TextStyle(fontSize: 12, color: Colors.black54);
  static const caption = TextStyle(fontSize: 11, color: Colors.black54);

  // ══════════════════════════════════════════
  // 🏷️ Labels — ใช้ 20+ ไฟล์
  // ══════════════════════════════════════════
  static const label = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      color: Colors.black54);
  static const labelTiny = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      color: Colors.black54);

  // ══════════════════════════════════════════
  // 💰 Money — ใช้ 25+ ไฟล์
  // ══════════════════════════════════════════
  static const money = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87);
  static const moneyBig =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w900);
  static const moneyHuge =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w900);

  // ══════════════════════════════════════════
  // 📋 Item / Data
  // ══════════════════════════════════════════
  static const itemName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  );

  static const itemNameBold = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const itemMeta = TextStyle(
    fontSize: 10.5,
    color: Colors.black54,
  );

  // ══════════════════════════════════════════
  // 📅 Date header
  // ══════════════════════════════════════════
  static const dateHeader = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w900,
    color: AppColors.brown800,     // ← แก้แล้ว
    letterSpacing: 0.2,
  );

  static const dateHeaderSub = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Colors.black54,
  );

  // ══════════════════════════════════════════
  // 🏷️ Section
  // ══════════════════════════════════════════
  static const sectionLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w900,
    color: AppColors.brown700,     // ← แก้แล้ว
    letterSpacing: 1.2,
  );

  static const sectionTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
    color: AppColors.brown700,     // ← แก้แล้ว
    letterSpacing: 0.2,
  );

  static const sectionLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Colors.black54,
    letterSpacing: 0.5,
  );

  // ══════════════════════════════════════════
  // 🎴 Group header
  // ══════════════════════════════════════════
  static const groupHeader = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static const subHeaderTitle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );

  // ══════════════════════════════════════════
  // 💳 Preview title
  // ══════════════════════════════════════════
  static const previewTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  // ══════════════════════════════════════════
  // 🔖 Filter chip
  // ══════════════════════════════════════════
  static const filterChip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const filterTitle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
    color: AppColors.brown700,     // ← แก้แล้ว
  );

  // ══════════════════════════════════════════
  // 🏷️ Card row
  // ══════════════════════════════════════════
  static const cardLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    letterSpacing: 0.5,
  );

  static const cardValue = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  static const priceLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    letterSpacing: 0.3,
  );

  static const zoneChipText = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.bold,
    color: AppColors.brown800,     // ← แก้แล้ว
  );
}