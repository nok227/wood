import '../../domain/entities/app_user.dart';

/// ══════════════════════════════════════════════
/// 📦 USER MODEL — DTO (Data Transfer Object)
/// หน้าที่: fromMap / toMap / toEntity
/// ══════════════════════════════════════════════
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String role;
  final List<String> allowedMenus;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    this.name,
    this.email,
    this.role = 'user',
    this.allowedMenus = const [],
    this.createdAt,
  });

  // ══════════════════════════════════════════
  // JSON ↔ Model
  // ══════════════════════════════════════════
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: _sOrNull(map['name'] ?? map['displayName'] ?? map['username']),
      email: _sOrNull(map['email']),
      role: _s(map['role'], 'user'),
      allowedMenus: _listString(map['allowedMenus']),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'allowedMenus': allowedMenus,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  // ══════════════════════════════════════════
  // Model ↔ Entity
  // ══════════════════════════════════════════
  AppUser toEntity() => AppUser(
        uid: uid,
        name: name,
        email: email,
        role: role,
        allowedMenus: allowedMenus,
        createdAt: createdAt,
      );

  factory UserModel.fromEntity(AppUser u) => UserModel(
        uid: u.uid,
        name: u.name,
        email: u.email,
        role: u.role,
        allowedMenus: u.allowedMenus,
        createdAt: u.createdAt,
      );

  // ══════════════════════════════════════════
  // Helpers (defensive parsing)
  // ══════════════════════════════════════════
  static String _s(dynamic v, [String def = '']) =>
      v == null ? def : v.toString();

  static String? _sOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static List<String> _listString(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).toList();
  }

  /// รองรับทั้ง Timestamp (Firebase), String, DateTime
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return null;
  }

  // ══════════════════════════════════════════
  // Copy
  // ══════════════════════════════════════════
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    List<String>? allowedMenus,
    DateTime? createdAt,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        allowedMenus: allowedMenus ?? this.allowedMenus,
        createdAt: createdAt ?? this.createdAt,
      );
}