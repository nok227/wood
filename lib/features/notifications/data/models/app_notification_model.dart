import '../../domain/entities/app_notification.dart';

class AppNotificationModel {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final String actorEmail;
  final bool actorIsAdmin;
  final NotificationAudience audience;
  final DateTime date;
  final bool isRead;
  final String? targetId;
  final Map<String, dynamic>? meta;
  final List<String> readBy;
  final List<String> deletedBy;
  final DateTime expireAt;

  AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.actorEmail,
    required this.actorIsAdmin,
    required this.audience,
    required this.date,
    this.isRead = false,
    this.targetId,
    this.meta,
    this.readBy = const [],
    this.deletedBy = const [],
    required this.expireAt,
  });

  static AppNotificationType _typeFrom(String s) =>
      AppNotificationType.values.firstWhere(
        (e) => e.name == s,
        orElse: () => AppNotificationType.productEdit,
      );

  static NotificationAudience _audFrom(String s) =>
      NotificationAudience.values.firstWhere(
        (e) => e.name == s,
        orElse: () => NotificationAudience.all,
      );

  static List<String> _strList(dynamic v) {
    if (v == null || v is! List) return const [];
    return v
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> m, String docId) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      try {
        final d = (v as dynamic).toDate();
        if (d is DateTime) return d;
      } catch (_) {}
      return DateTime.now();
    }

    final date = parseDate(m['date']);

    final expireAt = m['expireAt'] != null
        ? parseDate(m['expireAt'])
        : date.add(const Duration(days: 7));

    return AppNotificationModel(
      id: docId,
      type: _typeFrom(m['type']?.toString() ?? ''),
      title: m['title']?.toString() ?? '',
      message: m['message']?.toString() ?? '',
      actorEmail: m['actorEmail']?.toString() ?? '',
      actorIsAdmin: m['actorIsAdmin'] == true,
      audience: _audFrom(m['audience']?.toString() ?? 'all'),
      date: date,
      isRead: m['isRead'] == true,
      targetId: m['targetId']?.toString(),
      meta: m['meta'] is Map ? Map<String, dynamic>.from(m['meta']) : null,
      readBy: _strList(m['readBy']),
      deletedBy: _strList(m['deletedBy']),
      expireAt: expireAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'title': title,
        'message': message,
        'actorEmail': actorEmail,
        'actorIsAdmin': actorIsAdmin,
        'audience': audience.name,
        'date': date.toIso8601String(),
        'isRead': isRead,
        'targetId': targetId,
        'meta': meta,
        'readBy': readBy,
        'deletedBy': deletedBy,
        'expireAt': expireAt.toIso8601String(),
      };

  AppNotification toEntity() => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        actorEmail: actorEmail,
        actorIsAdmin: actorIsAdmin,
        audience: audience,
        date: date,
        isRead: isRead,
        targetId: targetId,
        meta: meta,
        readBy: readBy,
        deletedBy: deletedBy,
        expireAt: expireAt,
      );
}