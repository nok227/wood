import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════
/// 🔄 GLOBAL DIRECTION — LTR / RTL
///
/// ใช้เมื่อต้องการรองรับภาษาอาหรับ/ฮีบรู
/// ปัจจุบันแอปเป็น ลາວ/อังกฤษ → LTR อยู่แล้ว
/// แต่ถ้าอนาคตเพิ่ม RTL ที่นี่ที่เดียว
/// ══════════════════════════════════════════════
class AppDirection {
  AppDirection._();

  /// ภาษาที่เป็น RTL (เพิ่มได้ตามต้องการ)
  static const Set<String> _rtlCodes = {'ar', 'he', 'fa', 'ur', 'yi'};

  /// ค่า default
  static const TextDirection defaultDirection = TextDirection.ltr;

  /// เช็คจาก locale
  static TextDirection forLocale(Locale locale) {
    return _rtlCodes.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// helper
  static bool isRtl(Locale locale) => forLocale(locale) == TextDirection.rtl;
}