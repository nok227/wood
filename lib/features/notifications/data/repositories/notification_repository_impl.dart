import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;
  NotificationRepositoryImpl({required this.remote});

  @override
  Future<List<AppNotification>> getNotifications() => remote.getNotifications();

  @override
  Future<void> add(AppNotification n) => remote.add(n);

  @override
  Future<void> markRead(String id, String uid) => remote.markRead(id, uid);

  @override
  Future<void> markAllRead(List<String> ids, String uid) =>
      remote.markAllRead(ids, uid);

  @override
  Future<void> delete(String id, String uid) => remote.delete(id, uid);

  @override
  Future<void> clearAll(List<String> ids, String uid) =>
      remote.clearAll(ids, uid);
}