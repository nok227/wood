import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/skeletons.dart';

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
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        title: const Text('ແຈ້ງເຕືອນ'),
        actions: [
          Obx(() {
            final hasUnread = ctrl.unreadCount > 0;
            return IconButton(
              tooltip: 'ອ່ານທັງໝົດ',
              icon: const Icon(Icons.done_all),
              onPressed: hasUnread ? () => ctrl.markAllRead() : null,
            );
          }),
          Obx(() {
            final has = ctrl.visibleNotifications.isNotEmpty;
            return IconButton(
              tooltip: 'ລ້າງທັງໝົດ',
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
                Icon(Icons.notifications_none,
                    size: 64, color: Colors.brown.shade200),
                const SizedBox(height: 12),
                Text('ຍັງບໍ່ມີແຈ້ງເຕືອນ',
                    style: TextStyle(
                        color: Colors.brown.shade400,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        final groups = _groupByDate(list);

        return RefreshIndicator(
          color: Colors.brown,
          onRefresh: ctrl.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final g = groups[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 6, left: 4),
                    child: Text(
                      g.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.brown.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  ...g.items.map((n) => _tile(n)),
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
    final yest = today.subtract(const Duration(days: 1));

    final map = <String, List<AppNotification>>{};
    for (final n in list) {
      final d = DateTime(n.date.year, n.date.month, n.date.day);
      String key;
      if (d == today) {
        key = 'ມື້ນີ້';
      } else if (d == yest) {
        key = 'ມື້ວານນີ້';
      } else {
        key = DateFormat('dd/MM/yyyy').format(d);
      }
      map.putIfAbsent(key, () => []).add(n);
    }
    return map.entries.map((e) => _Group(e.key, e.value)).toList();
  }

  // ══════════════════════════════════════════════
  // ✅ ແກ້: ຮັບ 1 ຕົວ — ອ່ານ isRead ຈາກ ctrl ພາຍໃນ
  // ══════════════════════════════════════════════
  Widget _tile(AppNotification n) {
    final c = n.color;
    final isRead = ctrl.isReadByMe(n); // ✅ ກວດ per-user

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ctrl.deleteOne(n.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (!isRead) ctrl.markRead(n.id); // ✅ ໃຊ້ isRead
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : c.withOpacity(0.06), // ✅
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isRead ? Colors.grey.shade200 : c.withOpacity(0.35), // ✅
              width: isRead ? 1 : 1.4,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: c.withOpacity(0.35)),
                ),
                child: Icon(n.icon, color: c, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isRead // ✅
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                        if (!isRead) // ✅
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 11, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            n.actorEmail,
                            style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (n.actorIsAdmin) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Admin',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900)),
                          ),
                        ],
                        const Spacer(),
                        Icon(Icons.access_time,
                            size: 10, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('HH:mm').format(n.date),
                          style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600),
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

  void _confirmClear() {
    Get.defaultDialog(
      title: 'ລ້າງແຈ້ງເຕືອນ',
      middleText: 'ຕ້ອງການລ້າງແຈ້ງເຕືອນທັງໝົດທີ່ສະແດງຢູ່ບໍ?\n'
          '(ຈະລ້າງສະເພາະບັນຊີຂອງທ່ານເທົ່ານັ້ນ)',
      textConfirm: 'ລ້າງ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
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