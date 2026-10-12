import 'package:flutter/material.dart';
import '../constants/global/app_colors.dart';
import '../constants/global/app_fonts.dart';

class AppTheme {
  AppTheme._();

  /// 🎨 Default theme — ใช้จาก main()
  static ThemeData get light => fromSeed(AppColors.primary);

  /// 🎨 สร้าง theme จาก seed color (ใช้ตอนเปลี่ยนสี)
  static ThemeData fromSeed(Color seed) => ThemeData(
        useMaterial3: true,
        fontFamily: AppFonts.family.isEmpty ? null : AppFonts.family,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.family.isEmpty ? null : AppFonts.family,
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