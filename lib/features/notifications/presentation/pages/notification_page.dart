import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/notification_style.dart';
import 'package:wood/features/notifications/presentation/widgets/notification_skeleton.dart';

import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ctrl = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationStyle.brown50,
      appBar: AppBar(
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
              onPressed: has ? _confirmClear : null,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.allNotifications.isEmpty) {
          return const NotificationSkeleton();
        }
        final list = ctrl.visibleNotifications;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: NotificationStyle.emptyIconSize,
                  color: NotificationStyle.brown200,
                ),
                NotificationStyle.gapMd,
                const Text(
                  NotificationStyle.empty,
                  style: NotificationStyle.emptyText,
                ),
              ],
            ),
          );
        }

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
                  ...g.items.map(_tile),
                ],
              );
            },
          ),
        );
      }),
    );
  }

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

  // ══════════════════════════════════════════════
  // 📬 Tile
  // ══════════════════════════════════════════════
  Widget _tile(AppNotification n) {
    final c = n.color;
    final isRead = ctrl.isReadByMe(n);

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: NotificationStyle.padDismiss,
        margin: NotificationStyle.padTileMargin,
        decoration: BoxDecoration(
          color: NotificationStyle.error700,
          borderRadius: NotificationStyle.r10,
        ),
        child: const Icon(Icons.delete, color: NotificationStyle.white),
      ),
      onDismissed: (_) => ctrl.deleteOne(n.id),
      child: InkWell(
        borderRadius: NotificationStyle.r10,
        onTap: () {
          if (!isRead) ctrl.markRead(n.id);
        },
        child: Container(
          margin: NotificationStyle.padTileMargin,
          padding: NotificationStyle.padCard,
          decoration: BoxDecoration(
            color: isRead
                ? NotificationStyle.white
                : c.withOpacity(NotificationStyle.tileBgOpacity),
            borderRadius: NotificationStyle.r10,
            border: Border.all(
              color: isRead
                  ? NotificationStyle.grey200
                  : c.withOpacity(NotificationStyle.tileBorderOpacity),
              width: isRead
                  ? NotificationStyle.borderWidthRead
                  : NotificationStyle.borderWidthUnread,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon badge ──
              Container(
                width: NotificationStyle.iconBadge,
                height: NotificationStyle.iconBadge,
                decoration: BoxDecoration(
                  color: c.withOpacity(NotificationStyle.iconBadgeBgOpacity),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.withOpacity(
                        NotificationStyle.iconBadgeBorderOpacity),
                  ),
                ),
                child: Icon(
                  n.icon,
                  color: c,
                  size: NotificationStyle.iconMd,
                ),
              ),
              NotificationStyle.gap10,

              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: isRead
                                ? NotificationStyle.notiTitle
                                : NotificationStyle.notiTitleUnread,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: NotificationStyle.dotSize,
                            height: NotificationStyle.dotSize,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    NotificationStyle.gap3,
                    Text(
                      n.message,
                      style: NotificationStyle.notiMessage,
                    ),
                    NotificationStyle.gap6,
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: NotificationStyle.iconActorSize,
                          color: NotificationStyle.grey600,
                        ),
                        NotificationStyle.gap3,
                        Flexible(
                          child: Text(
                            n.actorEmail,
                            style: NotificationStyle.actorEmail,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (n.actorIsAdmin) ...[
                          NotificationStyle.gapXs,
                          Container(
                            padding: NotificationStyle.padAdminBadge,
                            decoration: BoxDecoration(
                              color: NotificationStyle.amber200,
                              borderRadius: NotificationStyle.r4,
                            ),
                            child: const Text(
                              NotificationStyle.adminLabel,
                              style: NotificationStyle.adminBadge,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          size: NotificationStyle.iconTimeSize,
                          color: NotificationStyle.grey500,
                        ),
                        NotificationStyle.gap3,
                        Text(
                          DateFormat(NotificationStyle.timeFormat)
                              .format(n.date),
                          style: NotificationStyle.timeText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🗑 Confirm clear
  // ══════════════════════════════════════════════
  void _confirmClear() {
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