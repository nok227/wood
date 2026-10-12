import 'package:get_storage/get_storage.dart';

/// ══════════════════════════════════════════════
/// 💾 LOCAL STORAGE — wrapper รอบ GetStorage
///
/// วิธีใช้:
///   await LocalStorage.init();     // ใน main()
///   LocalStorage.set('token', 'xxx');
///   final t = LocalStorage.get<String>('token');
///   LocalStorage.remove('token');
/// ══════════════════════════════════════════════
class LocalStorage {
  LocalStorage._();

  static final GetStorage _box = GetStorage();

  // ── Keys ──
  static const String kToken = 'auth_token';
  static const String kUserId = 'user_id';
  static const String kLocale = 'app_locale';
  static const String kThemeMode = 'theme_mode';

  // ══════════════════════════════════════════
  // 🚀 INIT — เรียกก่อน runApp()
  // ══════════════════════════════════════════
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ── CRUD ──
  static T? get<T>(String key) => _box.read<T>(key);
  static Future<void> set(String key, dynamic value) =>
      _box.write(key, value);
  static Future<void> remove(String key) => _box.remove(key);
  static Future<void> clear() => _box.erase();

  static bool has(String key) => _box.hasData(key);
}