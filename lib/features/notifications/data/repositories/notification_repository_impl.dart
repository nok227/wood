import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/app_notification_model.dart';

/// ══════════════════════════════════════════════
/// 📦 NOTIFICATION REPOSITORY IMPL
/// แปลง Model ↔ Entity
/// ══════════════════════════════════════════════
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;
  NotificationRepositoryImpl({required this.remote});

  // ── Model → Entity ──
  @override
  Future<List<AppNotification>> getNotifications() async {
    final models = await remote.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  // ── Entity → Model ──
  @override
  Future<void> add(AppNotification n) async {
    final model = AppNotificationModel(
      id: n.id,
      type: n.type,
      title: n.title,
      message: n.message,
      actorEmail: n.actorEmail,
      actorIsAdmin: n.actorIsAdmin,
      audience: n.audience,
      date: n.date,
      isRead: n.isRead,
      targetId: n.targetId,
      meta: n.meta,
      readBy: n.readBy,
      deletedBy: n.deletedBy,
      expireAt: n.expireAt,
    );
    await remote.add(model);
  }

  // ── pass-through (เป็น String operation) ──
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