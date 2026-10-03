import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(String title, String message,
      {SnackType type = SnackType.info}) {
    Get.closeAllSnackbars();
    late Color bg;
    late IconData icon;
    switch (type) {
      case SnackType.success:
        bg = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case SnackType.error:
        bg = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      case SnackType.warning:
        bg = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackType.info:
        bg = Colors.brown.shade700;
        icon = Icons.info_outline;
        break;
    }
    Get.snackbar(
      title,
      message,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: type == SnackType.error ? 3 : 2),
      animationDuration: const Duration(milliseconds: 300),
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