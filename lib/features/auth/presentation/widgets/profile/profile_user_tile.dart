import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/features/auth/domain/entities/app_user.dart';
import 'package:wood/features/auth/presentation/pages/user_permission_page.dart';

class ProfileUserTile extends StatelessWidget {
  final AppUser user;
  final String? currentUid;
  final VoidCallback? onPermissionSaved;

  const ProfileUserTile({
    super.key,
    required this.user,
    required this.currentUid,
    this.onPermissionSaved,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    final color = isAdmin ? AuthStyle.amber800 : AuthStyle.primary;
    final bgColor = isAdmin ? AuthStyle.amber50 : AuthStyle.brown50;
    final isMe = user.uid == currentUid;

    return Container(
      margin: AuthStyle.marginTileBottom,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(
          color: color.withValues(alpha: AuthStyle.borderOpacity),
          width: AuthStyle.borderWidth,
        ),
        boxShadow: AuthStyle.cardLocal,
      ),
      child: Padding(
        padding: AuthStyle.padChipBadge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AuthStyle.userAvatarSize,
              height: AuthStyle.userAvatarSize,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: AuthStyle.circleBorderOpacity),
                ),
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: color,
                size: AuthStyle.iconTile,
              ),
            ),
            AuthStyle.gap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: AuthStyle.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        AuthStyle.gap5,
                        Container(
                          padding: AuthStyle.padBadgeTiny,
                          decoration: BoxDecoration(
                            color: AuthStyle.successMid,
                            borderRadius: AuthStyle.badgeRadius,
                          ),
                          child: Text(
                            AuthStyle.youBadge,
                            style: AuthStyle.youBadgeStyle.copyWith(
                              color: AuthStyle.successDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AuthStyle.gap2,
                  Text(
                    user.email ?? AuthStyle.dash,
                    style: AuthStyle.userEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AuthStyle.gapSm,
            Container(
              padding: AuthStyle.padChipBadge,
              decoration: BoxDecoration(
                color: isAdmin ? AuthStyle.amber200 : AuthStyle.grey200,
                borderRadius: AuthStyle.chipRadius,
              ),
              child: Text(
                isAdmin ? AuthStyle.adminLabel : AuthStyle.userLabel,
                style: AuthStyle.roleChip.copyWith(
                  color: isAdmin ? AuthStyle.amber900 : AuthStyle.grey700,
                ),
              ),
            ),
            if (!isAdmin && !isMe) ...[
              AuthStyle.gap4,
              IconButton(
                icon: const Icon(
                  Icons.tune,
                  size: AuthStyle.iconTile,
                  color: AuthStyle.primary,
                ),
                tooltip: AuthStyle.permissionTooltip,
                padding: EdgeInsets.zero,
                constraints: AuthStyle.iconBtnConstraints,
                onPressed: () async {
                  await Get.to(
                    () => UserPermissionPage(
                      uid: user.uid,
                      name: user.displayName,
                      email: user.email ?? AuthStyle.dash,
                      initialAllowed: user.allowedMenus,
                    ),
                  );
                  onPermissionSaved?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}