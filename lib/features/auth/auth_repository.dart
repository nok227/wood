import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential?> signInWithGoogle();

  Future<void> signOut();

  // 🆕
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid);
  Future<void> updateAllowedMenus(String uid, List<String> menus);
}