import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/auth_style.dart';

class ProfileUsersHeader extends StatelessWidget {
  final int count;
  final VoidCallback? onRefresh;

  const ProfileUsersHeader({
    super.key,
    required this.count,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: AuthStyle.padHeaderIcon,
          decoration: const BoxDecoration(
            color: AuthStyle.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.people,
            color: AuthStyle.white,
            size: AuthStyle.iconBadgeSize,
          ),
        ),
        AuthStyle.gapSm,
        Expanded(
          child: Text(
            '${AuthStyle.usersTitle} ($count)',
            style: AuthStyle.usersHeader.copyWith(color: AuthStyle.primary),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: AuthStyle.iconTile),
          color: AuthStyle.primary,
          onPressed: onRefresh,
          tooltip: AuthStyle.refreshTooltip,
        ),
      ],
    );
  }
}