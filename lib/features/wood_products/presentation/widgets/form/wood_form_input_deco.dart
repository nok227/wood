import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

/// Helper สร้าง InputDecoration ใช้ร่วมกันทั้งฟอร์ม
class WoodFormInputDeco {
  WoodFormInputDeco._();

  static InputDecoration build(String label) => InputDecoration(
        labelText: label,
        labelStyle: WoodStyle.formLabel,
        filled: true,
        fillColor: WoodStyle.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: const OutlineInputBorder(
          borderRadius: WoodStyle.r12,
          borderSide: BorderSide(color: WoodStyle.grey300, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: WoodStyle.r12,
          borderSide: BorderSide(color: WoodStyle.black87, width: 1.5),
        ),
      );
}