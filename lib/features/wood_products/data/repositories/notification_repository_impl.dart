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
  Future<void> markRead(String id) => remote.markRead(id);
  @override
  Future<void> markAllRead(List<String> ids) => remote.markAllRead(ids);
  @override
  Future<void> delete(String id) => remote.delete(id);
  @override
  Future<void> clearAll(List<String> ids) => remote.clearAll(ids);
}