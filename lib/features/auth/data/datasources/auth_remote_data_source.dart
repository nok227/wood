import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wood/features/auth/domain/models/user_model.dart';

/// ══════════════════════════════════════════════
/// 📡 AUTH REMOTE DATA SOURCE
/// หน้าที่: คุยกับ Firebase เท่านั้น
/// คืน UserModel (DTO) — ไม่ใช่ Firebase User
/// ══════════════════════════════════════════════
class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _col = 'users';

  // ══════════════════════════════════════════
  // 🔐 REGISTER
  // ══════════════════════════════════════════
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) throw Exception('ສ້າງບັນຊີບໍ່ສຳເລັດ');

    await user.updateDisplayName(name);

    final model = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      role: 'user',
      allowedMenus: const [],
      createdAt: DateTime.now(),
    );

    await _db.collection(_col).doc(user.uid).set(model.toMap());
    return model;
  }

  // ══════════════════════════════════════════
  // 🔑 SIGN IN
  // ══════════════════════════════════════════
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) throw Exception('ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ');
    return _buildUserModel(user);
  }

  // ══════════════════════════════════════════
  // 🔍 GOOGLE SIGN IN
  // ══════════════════════════════════════════
  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return null;

    // ── สร้าง doc ถ้ายังไม่มี ──
    final ref = _db.collection(_col).doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final model = UserModel(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        role: 'user',
        allowedMenus: const [],
        createdAt: DateTime.now(),
      );
      await ref.set(model.toMap());
      return model;
    }

    return UserModel.fromMap(doc.data()!, user.uid);
  }

  // ══════════════════════════════════════════
  // 🚪 SIGN OUT
  // ══════════════════════════════════════════
  Future<void> signOut() async {
    try {
      await _google.signOut().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    } catch (_) {}
    await _auth.signOut();
  }

  // ══════════════════════════════════════════
  // 📡 STREAMS
  // ══════════════════════════════════════════
  Stream<UserModel?> authStateStream() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _buildUserModel(user);
    });
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection(_col).doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return UserModel.fromMap(data, uid);
    });
  }

  // ══════════════════════════════════════════
  // 👥 ADMIN — Users list
  // ══════════════════════════════════════════
  Future<List<UserModel>> getUsers() async {
    final snap = await _db.collection(_col).orderBy('email').get();
    return snap.docs
        .map((d) => UserModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateAllowedMenus(String uid, List<String> menus) async {
    await _db.collection(_col).doc(uid).set(
      {
        'allowedMenus': menus,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ══════════════════════════════════════════
  // 🔧 Helper — สร้าง UserModel จาก Firebase User
  // ══════════════════════════════════════════
  Future<UserModel> _buildUserModel(User user) async {
    final doc = await _db.collection(_col).doc(user.uid).get();
    final data = doc.data();

    if (doc.exists && data != null) {
      return UserModel.fromMap(data, user.uid);
    }

    // fallback: สร้างจาก Firebase User
    return UserModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      role: 'user',
      allowedMenus: const [],
    );
  }
}