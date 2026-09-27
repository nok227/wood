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
    );
    
    // บันทึกลง Firestore ตามปกติ
    // เมื่อบันทึกแล้ว แอปฝั่งผู้รับที่เปิดแอปอยู่หรือกดรับจาก Topic 'all_users' จะได้รับข้อมูลอัตโนมัติ
    await _db.collection(_collection).doc(n.id).set(m.toMap());
  }

  Future<void> markRead(String id) async {
    await _db.collection(_collection).doc(id).update({'isRead': true});
  }

  Future<void> markAllRead(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_db.collection(_collection).doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> clearAll(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_db.collection(_collection).doc(id));
    }
    await batch.commit();
  }
}