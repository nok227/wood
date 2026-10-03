import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════
  // Background
  // ══════════════════════════════════════════
  static const Color bg = Color(0xFFF5F0EA);
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFEEEEEE);

  // ══════════════════════════════════════════
  // Brand — Brown
  // ══════════════════════════════════════════
  static final Color primary = Colors.brown.shade700;
  static final Color primaryDark = Colors.brown.shade800;
  static final Color primaryLight = Colors.brown.shade50;
  static final Color primaryMid = Colors.brown.shade400;

  // ══════════════════════════════════════════
  // Semantic
  // ══════════════════════════════════════════
  static final Color success = Colors.green.shade700;
  static final Color successLight = Colors.green.shade50;
  static const Color error = Color(0xFFB71C1C);
  static final Color errorLight = Colors.red.shade50;
  static final Color warning = Colors.orange.shade800;
  static final Color warningLight = Colors.orange.shade50;
  static final Color info = Colors.blue.shade700;

  // ══════════════════════════════════════════
  // Status
  // ══════════════════════════════════════════
  static const Color confirmed = Color(0xFF2E7D32);
  static const Color mismatch = Color(0xFFB71C1C);
  static const Color mismatchClear = Color(0xFF00695C);
  static final Color pending = Colors.amber.shade800;
  static const Color saleColor = Color(0xFF5D4037);
  static const Color priceChange = Color(0xFFE65100);
  static const Color infoBlue = Color(0xFF1565C0);
  static const Color accountAdd = Color(0xFF283593);

  // ══════════════════════════════════════════
  // Text
  // ══════════════════════════════════════════
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static final Color textHint = Colors.grey.shade500;

  // ══════════════════════════════════════════
  // Payment methods
  // ══════════════════════════════════════════
  static final Color cash = Colors.amber.shade800;
  static final Color cashGreen = Colors.green.shade700;
  static final Color transfer = Colors.blue.shade700;
  static final Color mixed = Colors.indigo.shade700;
  static final Color debt = Colors.orange.shade800;
}