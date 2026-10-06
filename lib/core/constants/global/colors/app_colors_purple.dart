import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════
/// 🌐 GLOBAL COLORS — ใช้ใน 50+ ไฟล์ทั่วโปรเจกต์
///
/// ⚠️ ເວີຊັນນີ້ = TEST "RED THEME"
///    ປ່ຽນ brown scale → red scale
///    ຖ້າຢາກກັບ ໃຫ້ປ່ຽນ 10 ບັນທັດ ທີ່ ຫົວຂໍ້ "Brand"
/// ══════════════════════════════════════════════
class AppColors {
  AppColors._();

  // ══════════════════════════════════════════
  // 🎨 Basic — ใช้ 50+ ไฟล์
  // ══════════════════════════════════════════
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ══════════════════════════════════════════
  // 🖼️ Background — ใช้ 40+ ไฟล์
  // ══════════════════════════════════════════
  static const Color bg = Color(0xFFF8F4FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  // ══════════════════════════════════════════
  // 🌐 Brand — RED (ทดสอบ) — ใช้ 45+ ไฟล์
  //    ⚠️ ຖ້າຢາກກັບຫາເດີມ → ປ່ຽນ 10 ບັນທັດລຸ່ມນີ້
  // ══════════════════════════════════════════
static const Color brown50 = Color(0xFFF3E5F5);
static const Color brown100 = Color(0xFFE1BEE7);
static const Color brown200 = Color(0xFFCE93D8);
static const Color brown300 = Color(0xFFBA68C8);
static const Color brown400 = Color(0xFFAB47BC);
static const Color brown500 = Color(0xFF9C27B0);
static const Color brown600 = Color(0xFF8E24AA);
static const Color brown700 = Color(0xFF7B1FA2);
static const Color brown800 = Color(0xFF6A1B9A);
static const Color brown900 = Color(0xFF4A148C);

  // ── Aliases ──
  static const Color primary = brown700; // = red700
  static const Color primaryDark = brown800; // = red800
  static const Color primaryLight = brown50; // = red50
  static const Color primaryMid = brown400; // = red400
  static const Color primarySoft = brown200; // = red200

  // ══════════════════════════════════════════
  // ⬜ Grey scale — ใช้ 30+ ไฟล์
  // ══════════════════════════════════════════
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ══════════════════════════════════════════
  // ✅ Success (Green) — ใช้ 30+ ไฟล์
  // ══════════════════════════════════════════
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green300 = Color(0xFF81C784);
  static const Color green400 = Color(0xFF66BB6A);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green800 = Color(0xFF2E7D32);
  static const Color green900 = Color(0xFF1B5E20);

  // ── Aliases ──
  static const Color success = green700;
  static const Color successLight = green50;
  static const Color successMid = green100;
  static const Color success300 = green300;
  static const Color successDark = green800;

  // ══════════════════════════════════════════
  // ❌ Error (Red) — ใช้ 30+ ไฟล์
  // ══════════════════════════════════════════
  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red100 = Color(0xFFFFCDD2);
  static const Color red200 = Color(0xFFEF9A9A);
  static const Color red300 = Color(0xFFE57373);
  static const Color red400 = Color(0xFFEF5350);
  static const Color red500 = Color(0xFFF44336);
  static const Color red600 = Color(0xFFE53935);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color red800 = Color(0xFFC62828);
  static const Color red900 = Color(0xFFB71C1C);

  // ── Aliases ──
  static const Color error = Color(0xFFB71C1C); // = red900
  static const Color errorLight = red50;
  static const Color error300 = red300;
  static const Color error400 = red400;
  static const Color error600 = red600;
  static const Color error700 = red700;
  static const Color errorRed = red500; // = red500

  // ══════════════════════════════════════════
  // ⚠️ Warning (Orange) — ใช้ 25+ ไฟล์
  // ══════════════════════════════════════════
  static const Color orange = Color(0xFFFF9800);
  static const Color orange50 = Color(0xFFFFF3E0);
  static const Color orange100 = Color(0xFFFFE0B2);
  static const Color orange200 = Color(0xFFFFCC80);
  static const Color orange300 = Color(0xFFFFB74D);
  static const Color orange400 = Color(0xFFFFA726);
  static const Color orange500 = Color(0xFFFF9800);
  static const Color orange600 = Color(0xFFFB8C00);
  static const Color orange700 = Color(0xFFF57C00);
  static const Color orange800 = Color(0xFFEF6C00);
  static const Color orange900 = Color(0xFFE65100);

  // ── Aliases ──
  static const Color warning = orange800;
  static const Color warningLight = orange50;
  static const Color warning300 = orange300;
  static const Color warning400 = orange400;
  static const Color warning900 = orange900;

  // ══════════════════════════════════════════
  // 🟡 Amber — ใช้ 20+ ไฟล์
  // ══════════════════════════════════════════
  static const Color amber = Color(0xFFFFC107);
  static const Color amber50 = Color(0xFFFFF8E1);
  static const Color amber100 = Color(0xFFFFECB3);
  static const Color amber200 = Color(0xFFFFE082);
  static const Color amber300 = Color(0xFFFFD54F);
  static const Color amber400 = Color(0xFFFFCA28);
  static const Color amber500 = Color(0xFFFFC107);
  static const Color amber600 = Color(0xFFFFB300);
  static const Color amber700 = Color(0xFFFFA000);
  static const Color amber800 = Color(0xFFFF8F00);
  static const Color amber900 = Color(0xFFFF6F00);

  // ══════════════════════════════════════════
  // 🔵 Info (Blue) — ใช้ 25+ ไฟล์
  // ══════════════════════════════════════════
  static const Color blue = Color(0xFF2196F3);
  static const Color blue50 = Color(0xFFE3F2FD);
  static const Color blue100 = Color(0xFFBBDEFB);
  static const Color blue200 = Color(0xFF90CAF9);
  static const Color blue300 = Color(0xFF64B5F6);
  static const Color blue400 = Color(0xFF42A5F5);
  static const Color blue500 = Color(0xFF2196F3);
  static const Color blue600 = Color(0xFF1E88E5);
  static const Color blue700 = Color(0xFF1976D2);
  static const Color blue800 = Color(0xFF1565C0);
  static const Color blue900 = Color(0xFF0D47A1);

  // ── Aliases ──
  static const Color info = blue700;
  static const Color infoLight = blue50;

  // ══════════════════════════════════════════
  // 🟣 Accent — ใช้ 8 ไฟล์
  // ══════════════════════════════════════════
  static const Color indigo = Color(0xFF3F51B5);
  static const Color indigo700 = Color(0xFF303F9F);
  static const Color blueAccent = Colors.blueAccent;
  static const Color tealAccent = Colors.tealAccent;

  // ══════════════════════════════════════════
  // 🎭 Overlay — ใช้ 25+ ไฟล์
  // ══════════════════════════════════════════
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black12 = Color(0x1F000000);
  static const Color black26 = Color(0x42000000);
  static const Color black45 = Color(0x73000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black87 = Color(0xDD000000);

  // ══════════════════════════════════════════
  // 📝 Text — ใช้ 40+ ไฟล์
  // ══════════════════════════════════════════
  static const Color textPrimary = Color(0xDD000000);
  static const Color textSecondary = Color(0x8A000000);
  static const Color textHint = grey500;

  // ══════════════════════════════════════════
  // 💰 Payment — ใช้ 15+ ไฟล์
  // ══════════════════════════════════════════
  static const Color cash = amber800;
  static const Color transfer = blue700;
  static const Color mixed = indigo700;
  static const Color debt = orange800;

  // ══════════════════════════════════════════
  // 🏷️ Status — ใช้ 10+ ไฟล์
  // ══════════════════════════════════════════
  static const Color confirmed = Color(0xFF2E7D32);
  static const Color mismatch = Color(0xFFB71C1C);
  static const Color mismatchClear = Color(0xFF00695C);
  static const Color pending = amber800;
  static const Color priceChange = Color(0xFFE65100);
  static const Color infoBlue = Color(0xFF1565C0);
  static const Color accountAdd = Color(0xFF283593);

  // ══════════════════════════════════════════
  // 🌲 Wood shared — ⚠️ คงเดิม (สีไม้จริง — ไม่แตะ)
  // ══════════════════════════════════════════
  static const Color woodLight = Color(0xFFE8C99B);
  static const Color woodMid = Color(0xFFCE9C5E);
  static const Color woodDark = Color(0xFF8B5A2B);
  static const Color woodShadow = Color(0xFF3E2723);
  static const Color woodLightGrain = Color(0xFFF5E0B5);
  static const Color woodBg = Color(0xFFEFEBE9);

  // ══════════════════════════════════════════
  // 🎨 Gradient shared — alias brown → auto-red
  // ══════════════════════════════════════════
  static const Color gradStart = brown700;
  static const Color gradEnd = brown500;
  static const Color gradStartDark = brown800;
  static const Color gradEndDark = brown600;
}
