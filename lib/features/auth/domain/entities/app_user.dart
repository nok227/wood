/// ══════════════════════════════════════════════
/// 👤 APP USER — Entity (pure Dart)
/// ไม่ import อะไรเลย — pure business model
/// ══════════════════════════════════════════════
class AppUser {
  // ── Admin Email (business rule) ──
  static const String adminEmail = 'wood1002@gmail.com';

  // ── Fields ──
  final String uid;
  final String? name;
  final String? email;
  final String role;           // 'user' | 'admin'
  final List<String> allowedMenus;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.role = 'user',
    this.allowedMenus = const [],
    this.createdAt,
  });

  // ── Business logic ──
  bool get isAdmin =>
      email?.toLowerCase().trim() == adminEmail;

  bool get hasAnyPermission => isAdmin || allowedMenus.isNotEmpty;

  bool canAccess(String menuKey) {
    if (isAdmin) return true;
    return allowedMenus.contains(menuKey);
  }

  String get displayName =>
      name ??
      email?.split('@').first ??
      'ຜູ້ໃຊ້';

  // ── Copy ──
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    List<String>? allowedMenus,
    DateTime? createdAt,
  }) =>
      AppUser(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        allowedMenus: allowedMenus ?? this.allowedMenus,
        createdAt: createdAt ?? this.createdAt,
      );
}