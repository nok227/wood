import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification_model.dart';

/// ══════════════════════════════════════════════
/// 📡 NOTIFICATION REMOTE DATA SOURCE
/// หน้าที่: คุยกับ Firestore เท่านั้น
/// คืน Model — ไม่แปลงเป็น Entity
/// ══════════════════════════════════════════════
class NotificationRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'notifications';

  // ── อ่าน (คืน Model) ──
  Future<List<AppNotificationModel>> getNotifications() async {
    final snap = await _db
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(200)
        .get();

    return snap.docs
        .map((d) => AppNotificationModel.fromMap(d.data(), d.id))
        .toList();
  }

  // ── เพิ่ม (รับ Model) ──
  Future<void> add(AppNotificationModel m) async {
    await _db.collection(_collection).doc(m.id).set(m.toMap());
  }

  // ── อ่านแล้ว ──
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

  // ── ลบ ──
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