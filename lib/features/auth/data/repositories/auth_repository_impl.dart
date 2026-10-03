import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return remoteDataSource.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential?> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) =>
      remoteDataSource.userDocStream(uid);

  @override
  Future<void> updateAllowedMenus(String uid, List<String> menus) =>
      remoteDataSource.updateAllowedMenus(uid, menus);
}