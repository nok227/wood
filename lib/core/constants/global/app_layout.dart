import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════
/// 🌐 GLOBAL LAYOUT — ใช้ใน 40+ ไฟล์ทั่วโปรเจกต์
///
/// หมวดหมู่:
///   • spacing    → SizedBox + EdgeInsets (ใช้ 40+ ไฟล์)
///   • radius     → BorderRadius (ใช้ 35+ ไฟล์)
///   • icon       → ขนาด icon (ใช้ 25+ ไฟล์)
///   • button     → ความสูงปุ่ม (ใช้ 15+ ไฟล์)
///   • thumb      → ขนาด thumbnail (ใช้ 5 ไฟล์)
/// ══════════════════════════════════════════════
class AppLayout {
  AppLayout._();

  // ══════════════════════════════════════════
  // 📏 Spacing — ใช้ 40+ ไฟล์
  //    pages: home_shell, sales_list, account_page, ...
  //    widgets: sale_card, balance_banner, wood_list_product_card, ...
  // ══════════════════════════════════════════
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // ─── SizedBox presets (สั้นกว่า SizedBox(height: 12)) ───
  static const Widget gapXs = SizedBox(height: 4, width: 4);
  static const Widget gapSm = SizedBox(height: 8, width: 8);
  static const Widget gapMd = SizedBox(height: 12, width: 12);
  static const Widget gapLg = SizedBox(height: 16, width: 16);
  static const Widget gapXl = SizedBox(height: 20, width: 20);

  // ─── EdgeInsets presets ───
  static const EdgeInsets padAll4 = EdgeInsets.all(4);
  static const EdgeInsets padAll8 = EdgeInsets.all(8);
  static const EdgeInsets padAll10 = EdgeInsets.all(10);
  static const EdgeInsets padAll12 = EdgeInsets.all(12);
  static const EdgeInsets padAll14 = EdgeInsets.all(14);
  static const EdgeInsets padAll16 = EdgeInsets.all(16);
  static const EdgeInsets padAll20 = EdgeInsets.all(20);

  static const EdgeInsets padH12V8 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets padH14V10 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const EdgeInsets padH14V12 = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const EdgeInsets padH12V10 = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets padH10V6 = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );

  // ══════════════════════════════════════════
  // 🔁 Gap micro — ใช้ 6+ ไฟล์
  //    ย้ายมาจาก account/auth/home/notif/recipe/sale/wood
  // ══════════════════════════════════════════
  static const Widget gap2 = SizedBox(height: 2, width: 2);
  static const Widget gap3 = SizedBox(height: 3, width: 3);
  static const Widget gap5 = SizedBox(height: 5, width: 5);
  static const Widget gap6 = SizedBox(height: 6, width: 6);
  static const Widget gap10 = SizedBox(height: 10, width: 10);
  static const Widget gap14 = SizedBox(height: 14, width: 14);
  static const Widget gap24 = SizedBox(height: 24, width: 24);
  static const Widget gap32 = SizedBox(height: 32, width: 32);
  static const Widget gap80 = SizedBox(height: 80);
  static const Widget gap90 = SizedBox(height: 90);
  static const Widget gap120 = SizedBox(height: 120);

  // ── Alias (ชื่อเดิม — อ้าง gapXs/Sm/Md/Lg/Xl) ──
  static const Widget gap4 = gapXs; // = 4
  static const Widget gap8 = gapSm; // = 8
  static const Widget gap12 = gapMd; // = 12
  static const Widget gap16 = gapLg; // = 16
  static const Widget gap20 = gapXl; // = 20

  // ══════════════════════════════════════════
  // 📏 Padding micro — ใช้ 5+ ไฟล์
  // ══════════════════════════════════════════
  static const EdgeInsets padH4 = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets padH6 = EdgeInsets.symmetric(horizontal: 6);
  static const EdgeInsets padH8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets padH10 = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets padH12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets padH14 = EdgeInsets.symmetric(horizontal: 14);

  static const EdgeInsets padV4 = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets padV6 = EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets padV8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets padV10 = EdgeInsets.symmetric(vertical: 10);
  static const EdgeInsets padV12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets padV14 = EdgeInsets.symmetric(vertical: 14);
  static const EdgeInsets padV16 = EdgeInsets.symmetric(vertical: 16);

  // ══════════════════════════════════════════
  // 🎯 Icon micro — ใช้ 5+ ไฟล์
  // ══════════════════════════════════════════
  static const double icon2 = 2;
  static const double icon3 = 3;
  static const double icon5 = 5;
  static const double icon6 = 6;
  static const double icon8 = 8;
  static const double icon10 = 10;
  static const double icon11 = 11;
  static const double icon12 = 12;
  static const double icon13 = 13;
  static const double icon14 = 14;
  static const double icon15 = 15;
  static const double icon17 = 17;
  static const double icon18 = 18;
  static const double icon22 = 22;
  static const double icon26 = 26;
  static const double icon28 = 28;
  static const double icon36 = 36;
  static const double icon40 = 40;

  // ══════════════════════════════════════════
  // 🔲 Border width — ใช้ 5+ ไฟล์
  // ══════════════════════════════════════════
  static const double borderW1 = 1.0;
  static const double borderW1_2 = 1.2;
  static const double borderW1_5 = 1.5;
  static const double borderW1_8 = 1.8;
  static const double borderW2 = 2.0;
  static const double borderW2_5 = 2.5; 

  // ══════════════════════════════════════════
  // 🔲 Radius — ใช้ 35+ ไฟล์
  //    ใช้: Container, Card, Dialog, BottomSheet
  // ══════════════════════════════════════════
  static const BorderRadius r4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius r6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius r10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius r14 = BorderRadius.all(Radius.circular(14));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius r20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius r24 = BorderRadius.all(Radius.circular(24));

  // ─── Top-only (BottomSheet / Form) ───
  static const BorderRadius topR12 = BorderRadius.vertical(
    top: Radius.circular(12),
  );
  static const BorderRadius topR14 = BorderRadius.vertical(
    top: Radius.circular(14),
  );
  static const BorderRadius topR24 = BorderRadius.vertical(
    top: Radius.circular(24),
  );

  // ══════════════════════════════════════════
  // 🎯 Icon — ใช้ 25+ ไฟล์
  // ══════════════════════════════════════════
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ══════════════════════════════════════════
  // 🔘 Button — ใช้ 15+ ไฟล์
  // ══════════════════════════════════════════
  static const double buttonHeight = 48;
  static const double inputHeight = 48;

  // ══════════════════════════════════════════
  // 🖼️ Thumbnail — ใช้ 5 ไฟล์
  //    sale_card, wood_list_product_card, recipe_card,
  //    wood_product_preview_card, profile_view_page
  // ══════════════════════════════════════════
  static const double thumbSm = 60;
  static const double thumbMd = 76;
  static const double thumbLg = 84;
}
