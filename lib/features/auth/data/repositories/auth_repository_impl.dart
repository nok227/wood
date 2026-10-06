import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// ══════════════════════════════════════════════
/// 📦 AUTH REPOSITORY IMPL
/// หน้าที่: แปลง Model ↔ Entity + caching
/// ══════════════════════════════════════════════
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  AppUser? _cachedUser;

  // ══════════════════════════════════════════
  // State
  // ══════════════════════════════════════════
  @override
  AppUser? get currentUser => _cachedUser;

  @override
  Stream<AppUser?> authStateStream() {
    return remoteDataSource.authStateStream().map((m) {
      _cachedUser = m?.toEntity();
      return _cachedUser;
    });
  }

  @override
  Stream<AppUser?> userStream(String uid) {
    return remoteDataSource.userStream(uid).map((m) => m?.toEntity());
  }

  // ══════════════════════════════════════════
  // Auth
  // ══════════════════════════════════════════
  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final model = await remoteDataSource.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
    return model.toEntity();
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final model = await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    return model.toEntity();
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final model = await remoteDataSource.signInWithGoogle();
    return model?.toEntity();
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
    await remoteDataSource.signOut();
  }

  // ══════════════════════════════════════════
  // Admin
  // ══════════════════════════════════════════
  @override
  Future<List<AppUser>> getUsers() async {
    final models = await remoteDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateAllowedMenus(String uid, List<String> menus) {
    return remoteDataSource.updateAllowedMenus(uid, menus);
  }
}