import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/notification_style.dart';

class NotificationEmpty extends StatelessWidget {
  const NotificationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
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
}