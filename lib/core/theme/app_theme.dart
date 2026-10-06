import 'package:flutter/material.dart';
import '../constants/global/app_colors.dart';

/// ══════════════════════════════════════════════
/// 🎨 APP THEME — ThemeData + Font กลางของแอป
///
/// ⭐ ປ່ຽນສີ → ແກ້ທີ່ app_colors.dart
/// ⭐ ປ່ຽນ font → uncomment _fontFamily ລຸ່ມນີ້ + ແກ້ pubspec.yaml
/// ══════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════
  // 🔤 FONT SWITCHER — ເປີດໃຊ້ພາຍຫຼັງ
  //    ຕ້ອງເພີ່ມ fonts: ໃນ pubspec.yaml ກ່ອນ
  // ══════════════════════════════════════════
  // static const String _fontFamily = 'NotoSansLao';
  // static const String _fontFamily = 'Sarabun';
  // static const String _fontFamily = 'Prompt';
  // static const String _fontFamily = 'Kanit';

  // ══════════════════════════════════════════
  // 🎨 LIGHT THEME
  // ══════════════════════════════════════════
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        // fontFamily: _fontFamily,             // ← 🔓 uncomment ເມື່ອໃຊ້ font
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            // fontFamily: _fontFamily,          // ← 🔓 uncomment ຖ້າໃຊ້ font
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(thickness: 1, space: 1),
      );
}