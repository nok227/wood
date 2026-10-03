import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;
  NotificationController({required this.repository});

  final allNotifications = <AppNotification>[].obs;
  final isLoading = false.obs;

  static const int ttlDays = 7;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _bindBadgeToUnreadCount();
  }

  void _bindBadgeToUnreadCount() {
    _updateBadge(unreadCount);
    ever(allNotifications, (_) => _updateBadge(unreadCount));
  }

  Future<void> _updateBadge(int count) async {
    try {
      final supported = await AppBadgePlus.isSupported();
      if (!supported) return;
      await AppBadgePlus.updateBadge(count);
    } catch (e) {
      debugPrint('Badge update error: $e');
    }
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final list = await repository.getNotifications();
      final now = DateTime.now();
      final fresh = list.where((n) => n.expireAt.isAfter(now)).toList();
      allNotifications.assignAll(fresh);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  List<AppNotification> get _visible {
    bool isAdmin = false;
    if (Get.isRegistered<AuthController>()) {
      try {
        isAdmin = Get.find<AuthController>().isAdmin;
      } catch (_) {
        isAdmin = false;
      }
    }

    final uid = _uid;

    return allNotifications.where((n) {
      if (n.isDeletedBy(uid)) return false;

      if (isAdmin) {
        return n.audience == NotificationAudience.admin ||
            n.audience == NotificationAudience.all;
      }
      return n.audience == NotificationAudience.user ||
          n.audience == NotificationAudience.all;
    }).toList();
  }

  List<AppNotification> get visibleNotifications => _visible;

  int get unreadCount {
    final uid = _uid;
    return _visible.where((n) => !n.isReadBy(uid)).length;
  }

  bool isReadByMe(AppNotification n) => n.isReadBy(_uid);

  Future<void> push({
    required AppNotificationType type,
    required String title,
    required String message,
    NotificationAudience audience = NotificationAudience.all,
    String? targetId,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      bool isAdmin = false;
      if (Get.isRegistered<AuthController>()) {
        try {
          isAdmin = Get.find<AuthController>().isAdmin;
        } catch (_) {}
      }

      final now = DateTime.now();
      final expireAt = now.add(Duration(days: ttlDays));

      final n = AppNotification(
        id: now.microsecondsSinceEpoch.toString(),
        type: type,
        title: title,
        message: message,
        actorEmail: user?.email ?? 'unknown',
        actorIsAdmin: isAdmin,
        audience: audience,
        date: now,
        targetId: targetId,
        meta: meta,
        expireAt: expireAt,
      );

      allNotifications.insert(0, n);
      await repository.add(n);
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    final uid = _uid;
    if (uid == null) return;

    final i = allNotifications.indexWhere((n) => n.id == id);
    if (i == -1) return;
    if (allNotifications[i].readBy.contains(uid)) return;

    allNotifications[i] = allNotifications[i].copyWith(
      readBy: [...allNotifications[i].readBy, uid],
    );
    try {
      await repository.markRead(id, uid);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final uid = _uid;
    if (uid == null) return;

    final ids = _visible
        .where((n) => !n.readBy.contains(uid))
        .map((n) => n.id)
        .toList();
    if (ids.isEmpty) return;

    for (var i = 0; i < allNotifications.length; i++) {
      final n = allNotifications[i];
      if (ids.contains(n.id) && !n.readBy.contains(uid)) {
        allNotifications[i] = n.copyWith(readBy: [...n.readBy, uid]);
      }
    }

    try {
      await repository.markAllRead(ids, uid);
    } catch (_) {}
  }

  Future<void> deleteOne(String id) async {
    final uid = _uid;
    if (uid == null) return;

    allNotifications.removeWhere((n) => n.id == id);

    try {
      await repository.delete(id, uid);
    } catch (_) {
      fetchNotifications();
    }
  }

  Future<void> clearVisible() async {
    final uid = _uid;
    if (uid == null) return;

    final ids = _visible.map((n) => n.id).toList();
    if (ids.isEmpty) return;

    allNotifications.removeWhere((n) => ids.contains(n.id));

    try {
      await repository.clearAll(ids, uid);
    } catch (_) {
      fetchNotifications();
    }
  }
}