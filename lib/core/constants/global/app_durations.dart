/// ══════════════════════════════════════════════
/// 🌐 GLOBAL DURATIONS — ใช้ใน 25+ ไฟล์
///
/// วิธีใช้:
///   AnimatedContainer(duration: AppDurations.normal)
///   Get.to(..., duration: AppDurations.normal)
/// ══════════════════════════════════════════════
class AppDurations {
  AppDurations._();

  // ══════════════════════════════════════════
  // 🎬 UI Transition — ใช้ 20+ ไฟล์
  //    Container animation, FadeTransition, Get.to
  // ══════════════════════════════════════════
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // ══════════════════════════════════════════
  // 🔢 AnimatedNumber — ใช้ 12 ไฟล์
  // ══════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 800);
  static const Duration animNormal = Duration(milliseconds: 1200);
  static const Duration animSlow = Duration(milliseconds: 1600);

  // ══════════════════════════════════════════
  // 💬 Snackbar — ใช้ 15+ ไฟล์ (AppSnackbar)
  // ══════════════════════════════════════════
  static const Duration snackbarShort = Duration(seconds: 2);
  static const Duration snackbarLong = Duration(seconds: 3);
}