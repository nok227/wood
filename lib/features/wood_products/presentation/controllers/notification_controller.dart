import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/auth_controller.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;
  NotificationController({required this.repository});

  final allNotifications = <AppNotification>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final list = await repository.getNotifications();
      allNotifications.assignAll(list);
    } catch (_) {
      // silent
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
    return allNotifications.where((n) {
      if (isAdmin) {
        return n.audience == NotificationAudience.admin ||
            n.audience == NotificationAudience.all;
      }
      return n.audience == NotificationAudience.user ||
          n.audience == NotificationAudience.all;
    }).toList();
  }

  List<AppNotification> get visibleNotifications => _visible;

  int get unreadCount => _visible.where((n) => !n.isRead).length;

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

      final n = AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        title: title,
        message: message,
        actorEmail: user?.email ?? 'unknown',
        actorIsAdmin: isAdmin,
        audience: audience,
        date: DateTime.now(),
        targetId: targetId,
        meta: meta,
      );

      allNotifications.insert(0, n);

      await repository.add(n);
    } catch (_) {
      // silent
    }
  }

  Future<void> markRead(String id) async {
    final i = allNotifications.indexWhere((n) => n.id == id);
    if (i == -1 || allNotifications[i].isRead) return;
    allNotifications[i] = allNotifications[i].copyWith(isRead: true);
    try {
      await repository.markRead(id);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final ids = _visible.where((n) => !n.isRead).map((n) => n.id).toList();
    if (ids.isEmpty) return;
    for (var i = 0; i < allNotifications.length; i++) {
      if (ids.contains(allNotifications[i].id)) {
        allNotifications[i] = allNotifications[i].copyWith(isRead: true);
      }
    }
    try {
      await repository.markAllRead(ids);
    } catch (_) {}
  }

  Future<void> deleteOne(String id) async {
    allNotifications.removeWhere((n) => n.id == id);
    try {
      await repository.delete(id);
    } catch (_) {}
  }

  Future<void> clearVisible() async {
    final ids = _visible.map((n) => n.id).toList();
    allNotifications.removeWhere((n) => ids.contains(n.id));
    try {
      await repository.clearAll(ids);
    } catch (_) {}
  }
}