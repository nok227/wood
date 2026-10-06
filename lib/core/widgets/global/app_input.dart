import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_layout.dart';

class AppInput {
  AppInput._();

  static InputDecoration deco(
    String label, {
    Widget? prefix,
    Widget? suffix,
    String? suffixText,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey600, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      suffixText: suffixText,
      helperText: helper,
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppLayout.r12,
        borderSide: BorderSide(color: AppColors.grey300, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppLayout.r12,
        borderSide: BorderSide(color: AppColors.black87, width: 1.5),
      ),
    );
  }

  static InputDecoration decoCompact(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}