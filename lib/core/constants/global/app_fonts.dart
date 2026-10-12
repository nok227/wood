/// ══════════════════════════════════════════════
/// 🔤 GLOBAL FONTS — สลับฟอนต์ทั้งแอปที่ไฟล์เดียว
///
/// วิธีใช้:
///   1. เลือก family ที่ต้องการ (uncomment)
///   2. ตรวจว่า declare ใน pubspec.yaml แล้ว
///   3. rebuild — ทั้งแอปเปลี่ยนทันที
///
/// ⚠️ อย่าลืม:
///   fonts:
///     - family: NotoSansLao
///       fonts:
///         - asset: assets/fonts/NotoSansLao-Regular.ttf
///         - asset: assets/fonts/NotoSansLao-Bold.ttf
///           weight: 700
/// ══════════════════════════════════════════════
class AppFonts {
  AppFonts._();

  // ══════════════════════════════════════════
  // 🔤 SWITCH FONT ที่นี่ที่เดียว
  //    ค่า "" = ใช้ default ของ OS (ไม่ต้องมีไฟล์ font)
  // ══════════════════════════════════════════
  // static const String family = 'NotoSansLao';
  // static const String family = 'Sarabun';
  // static const String family = 'Prompt';
  // static const String family = 'Kanit';
  static const String family = '';
}