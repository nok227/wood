import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> add(AppNotification n);
  Future<void> markRead(String id);
  Future<void> markAllRead(List<String> ids);
  Future<void> delete(String id);
  Future<void> clearAll(List<String> ids);
}