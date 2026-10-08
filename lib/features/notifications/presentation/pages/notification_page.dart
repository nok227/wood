import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/notification_style.dart';

import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_empty.dart';
import '../widgets/notification_skeleton.dart';
import '../widgets/notification_tile.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: NotificationStyle.brown50,
      appBar: _appBar(ctrl),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.allNotifications.isEmpty) {
          return const NotificationSkeleton();
        }
        final list = ctrl.visibleNotifications;
        if (list.isEmpty) return const NotificationEmpty();

        final groups = _groupByDate(list);

        return RefreshIndicator(
          color: NotificationStyle.primary,
          onRefresh: ctrl.fetchNotifications,
          child: ListView.builder(
            padding: NotificationStyle.padList,
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final g = groups[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: NotificationStyle.padGroupHeader,
                    child: Text(
                      g.label,
                      style: NotificationStyle.dateGroup,
                    ),
                  ),
                  ...g.items.map(
                    (n) => NotificationTile(
                      notification: n,
                      isRead: ctrl.isReadByMe(n),
                      onTap: () => ctrl.markRead(n.id),
                      onDelete: () => ctrl.deleteOne(n.id),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  AppBar _appBar(NotificationController ctrl) {
    return AppBar(
      backgroundColor: NotificationStyle.primary,
      foregroundColor: NotificationStyle.white,
      title: const Text(NotificationStyle.pageTitle),
      actions: [
        Obx(() {
          final hasUnread = ctrl.unreadCount > 0;
          return IconButton(
            tooltip: NotificationStyle.markAllRead,
            icon: const Icon(Icons.done_all),
            onPressed: hasUnread ? () => ctrl.markAllRead() : null,
          );
        }),
        Obx(() {
          final has = ctrl.visibleNotifications.isNotEmpty;
          return IconButton(
            tooltip: NotificationStyle.clearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: has ? () => _confirmClear(ctrl) : null,
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════════
  // Group by date
  // ══════════════════════════════════════════
  List<_Group> _groupByDate(List<AppNotification> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(NotificationStyle.daysOne);

    final map = <String, List<AppNotification>>{};
    for (final n in list) {
      final d = DateTime(n.date.year, n.date.month, n.date.day);
      String key;
      if (d == today) {
        key = NotificationStyle.today;
      } else if (d == yest) {
        key = NotificationStyle.yesterday;
      } else {
        key = DateFormat(NotificationStyle.dateFormat).format(d);
      }
      map.putIfAbsent(key, () => []).add(n);
    }
    return map.entries.map((e) => _Group(e.key, e.value)).toList();
  }

  // ══════════════════════════════════════════
  // Confirm clear
  // ══════════════════════════════════════════
  void _confirmClear(NotificationController ctrl) {
    Get.defaultDialog(
      title: NotificationStyle.clearConfirm,
      middleText: NotificationStyle.clearConfirmMsg,
      textConfirm: NotificationStyle.clearBtn,
      textCancel: NotificationStyle.cancel,
      confirmTextColor: NotificationStyle.white,
      buttonColor: NotificationStyle.error700,
      onConfirm: () {
        Get.back();
        ctrl.clearVisible();
      },
    );
  }
}

class _Group {
  final String label;
  final List<AppNotification> items;
  _Group(this.label, this.items);
}