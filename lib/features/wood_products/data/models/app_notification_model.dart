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

    return AppNotificationModel(
      id: docId,
      type: _typeFrom(m['type']?.toString() ?? ''),
      title: m['title']?.toString() ?? '',
      message: m['message']?.toString() ?? '',
      actorEmail: m['actorEmail']?.toString() ?? '',
      actorIsAdmin: m['actorIsAdmin'] == true,
      audience: _audFrom(m['audience']?.toString() ?? 'all'),
      date: parseDate(m['date']),
      isRead: m['isRead'] == true,
      targetId: m['targetId']?.toString(),
      meta: m['meta'] is Map ? Map<String, dynamic>.from(m['meta']) : null,
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
      );
}