import 'env.dart';

/// ══════════════════════════════════════════════
/// ⚙️ APP CONFIG — baseUrl / flags ตาม environment
///
/// วิธีเปลี่ยน env ตอน build:
///   flutter run --dart-define=APP_ENV=prod
/// ══════════════════════════════════════════════
class AppConfig {
  AppConfig._();

  // ══════════════════════════════════════════
  // 🌍 ENV — อ่านจาก --dart-define ตอน build
  // ══════════════════════════════════════════
  static const String _envRaw =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static final AppEnv env = switch (_envRaw) {
    'prod' => AppEnv.prod,
    'staging' => AppEnv.staging,
    _ => AppEnv.dev,
  };

  // ══════════════════════════════════════════
  // 🌐 API BASE URL
  // ══════════════════════════════════════════
  static String get apiBaseUrl => switch (env) {
        AppEnv.dev => 'https://dev-api.wood-app.com',
        AppEnv.staging => 'https://staging-api.wood-app.com',
        AppEnv.prod => 'https://api.wood-app.com',
      };

  // ══════════════════════════════════════════
  // 🚩 FLAGS
  // ══════════════════════════════════════════
  static bool get enableLogging => !env.isProd;
  static bool get enableAnalytics => env.isProd;

  // ══════════════════════════════════════════
  // ⏱️ TIMEOUT
  // ══════════════════════════════════════════
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}