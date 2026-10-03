import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> add(AppNotification n);

  Future<void> markRead(String id, String uid);
  Future<void> markAllRead(List<String> ids, String uid);
  Future<void> delete(String id, String uid);
  Future<void> clearAll(List<String> ids, String uid);
}