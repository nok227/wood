import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_durations.dart';

enum SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    String title,
    String message, {
    SnackType type = SnackType.info,
  }) {
    Get.closeAllSnackbars();
    late Color bg;
    late IconData icon;
    switch (type) {
      case SnackType.success:
        bg = AppColors.success;
        icon = Icons.check_circle;
        break;
      case SnackType.error:
        bg = AppColors.error700;
        icon = Icons.error_outline;
        break;
      case SnackType.warning:
        bg = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackType.info:
        bg = AppColors.primary;
        icon = Icons.info_outline;
        break;
    }
    Get.snackbar(
      title,
      message,
      backgroundColor: bg,
      colorText: AppColors.white,
      icon: Icon(icon, color: AppColors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: type == SnackType.error
          ? AppDurations.snackbarLong
          : AppDurations.snackbarShort,
      animationDuration: AppDurations.normal,
      boxShadows: [
        BoxShadow(
          color: bg.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void ok(String t, String m) => show(t, m, type: SnackType.success);
  static void err(String t, String m) => show(t, m, type: SnackType.error);
  static void warn(String t, String m) => show(t, m, type: SnackType.warning);
  static void info(String t, String m) => show(t, m, type: SnackType.info);
}