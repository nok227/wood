/// ══════════════════════════════════════════════
/// 🌍 ENVIRONMENT — dev / staging / prod
/// ══════════════════════════════════════════════
enum AppEnv {
  dev,
  staging,
  prod;

  bool get isDev => this == AppEnv.dev;
  bool get isStaging => this == AppEnv.staging;
  bool get isProd => this == AppEnv.prod;
}