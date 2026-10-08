import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/notification_style.dart';

import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isRead,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final c = n.color;

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
      onDismissed: (_) => onDelete(),
      child: InkWell(
        borderRadius: NotificationStyle.r10,
        onTap: isRead ? null : onTap,
        child: Container(
          margin: NotificationStyle.padTileMargin,
          padding: NotificationStyle.padCard,
          decoration: BoxDecoration(
            color: isRead
                ? NotificationStyle.white
                : c.withValues(alpha: NotificationStyle.tileBgOpacity),
            borderRadius: NotificationStyle.r10,
            border: Border.all(
              color: isRead
                  ? NotificationStyle.grey200
                  : c.withValues(
                      alpha: NotificationStyle.tileBorderOpacity,
                    ),
              width: isRead
                  ? NotificationStyle.borderWidthRead
                  : NotificationStyle.borderWidthUnread,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBadge(c, n.icon),
              NotificationStyle.gap10,
              Expanded(child: _content(n, c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBadge(Color c, IconData icon) {
    return Container(
      width: NotificationStyle.iconBadge,
      height: NotificationStyle.iconBadge,
      decoration: BoxDecoration(
        color: c.withValues(alpha: NotificationStyle.iconBadgeBgOpacity),
        shape: BoxShape.circle,
        border: Border.all(
          color:
              c.withValues(alpha: NotificationStyle.iconBadgeBorderOpacity),
        ),
      ),
      child: Icon(icon, color: c, size: NotificationStyle.iconMd),
    );
  }

  Widget _content(AppNotification n, Color c) {
    return Column(
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
                decoration:
                    BoxDecoration(color: c, shape: BoxShape.circle),
              ),
          ],
        ),
        NotificationStyle.gap3,
        Text(n.message, style: NotificationStyle.notiMessage),
        NotificationStyle.gap6,
        _meta(n),
      ],
    );
  }

  Widget _meta(AppNotification n) {
    return Row(
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
          DateFormat(NotificationStyle.timeFormat).format(n.date),
          style: NotificationStyle.timeText,
        ),
      ],
    );
  }
}