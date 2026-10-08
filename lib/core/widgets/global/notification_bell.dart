import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/features/notifications/domain/entities/app_notification.dart';
import 'package:wood/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:wood/features/notifications/presentation/pages/notification_page.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  Worker? _worker;
  int? _lastUnread;
  bool _isFirstChange = true;

  // ── พารามิเตอร์ปรับแต่ง ──
  static const double _maxAngle = 0.32;      // ~18° แรงสุด
  static const double _frequency = 22.0;     // ~7.3 Hz (22 รอบใน 3s)
  static const double _decay = 1.4;          // ยิ่งมาก ยิ่งเบาเร็ว

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (Get.isRegistered<NotificationController>()) {
      final c = Get.find<NotificationController>();
      _lastUnread = c.unreadCount;

      _worker = ever<List<AppNotification>>(c.allNotifications, (_) {
        final current = c.unreadCount;

        if (_isFirstChange) {
          _isFirstChange = false;
          _lastUnread = current;
          return;
        }

        if (_lastUnread != null && current > _lastUnread!) {
          _triggerShake();
        }
        _lastUnread = current;
      });
    }
  }

  void _triggerShake() {
    if (!mounted) return;
    _ctrl.forward(from: 0);
  }

  /// 🎯 คำนวณมุมจาก t (0→1) แบบสมูท
  double _computeAngle(double t) {
    if (t <= 0 || t >= 1) return 0;

    // ① Envelope: decay แบบ smooth — ไม่ถึง 0 (ยังสั่นท้าย ๆ)
    //    t=0 → 1.0 / t=0.5 → ~0.55 / t=1 → ~0.28
    final envelope = math.pow(1 - t * 0.72, _decay).toDouble();

    // ② Oscillation: sine wave ต่อเนื่อง
    final oscillation = math.sin(t * 2 * math.pi * _frequency);

    return oscillation * envelope * _maxAngle;
  }

  @override
  void dispose() {
    _worker?.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      return const SizedBox.shrink();
    }
    final c = Get.find<NotificationController>();

    return Obx(() {
      final unread = c.unreadCount;

      return IconButton(
        tooltip: 'ແຈ້ງເຕືອນ',
        onPressed: () {
          _ctrl.stop();
          _ctrl.value = 0;
          Get.to(
            () => const NotificationPage(),
            transition: Transition.downToUp,
            duration: AppDurations.normal,
          );
        },
        icon: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final angle = _computeAngle(_ctrl.value);
            return Transform.rotate(
              angle: angle,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: Badge(
            isLabelVisible: unread > 0,
            backgroundColor: AppColors.error700,
            label: Text(
              unread > 99 ? '99+' : '$unread',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Icon(Icons.notifications_outlined, size: 26),
          ),
        ),
      );
    });
  }
}