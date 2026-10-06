import '../entities/app_user.dart';

/// ══════════════════════════════════════════════
/// 📜 AUTH REPOSITORY — สัญญา (pure Dart)
/// ไม่ import Firebase — คืน AppUser
/// ══════════════════════════════════════════════
abstract class AuthRepository {
  // ── State ──
  AppUser? get currentUser;

  /// Stream ผู้ใช้ปัจจุบัน (login/logout)
  Stream<AppUser?> authStateStream();

  /// Stream user doc (realtime update — permissions)
  Stream<AppUser?> userStream(String uid);

  // ── Auth ──
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> signInWithGoogle();

  Future<void> signOut();

  // ── Admin ──
  Future<List<AppUser>> getUsers();
  Future<void> updateAllowedMenus(String uid, List<String> menus);
}