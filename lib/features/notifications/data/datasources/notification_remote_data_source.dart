import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'notifications';

  Future<List<AppNotification>> getNotifications() async {
    final snap = await _db
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(200)
        .get();
    return snap.docs
        .map((d) => AppNotificationModel.fromMap(d.data(), d.id).toEntity())
        .toList();
  }

  Future<void> add(AppNotification n) async {
    final m = AppNotificationModel(
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
    await _db.collection(_collection).doc(n.id).set(m.toMap());
  }

  Future<void> markRead(String id, String uid) async {
    if (uid.isEmpty) return;
    await _db.collection(_collection).doc(id).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> markAllRead(List<String> ids, String uid) async {
    if (ids.isEmpty || uid.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_db.collection(_collection).doc(id), {
        'readBy': FieldValue.arrayUnion([uid]),
      });
    }
    await batch.commit();
  }

  Future<void> delete(String id, String uid) async {
    if (uid.isEmpty) return;
    await _db.collection(_collection).doc(id).update({
      'deletedBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> clearAll(List<String> ids, String uid) async {
    if (ids.isEmpty || uid.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_db.collection(_collection).doc(id), {
        'deletedBy': FieldValue.arrayUnion([uid]),
      });
    }
    await batch.commit();
  }
}