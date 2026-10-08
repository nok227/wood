import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/features/auth/domain/entities/app_user.dart';

class ProfileMyCard extends StatelessWidget {
  final AppUser? user;
  final bool isAdmin;

  const ProfileMyCard({super.key, required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AuthStyle.padProfileCard,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AuthStyle.profileGradStart, AuthStyle.profileGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AuthStyle.profileRadius,
        boxShadow: AuthStyle.profile,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AuthStyle.avatarLg,
            backgroundColor: AuthStyle.avatarBg,
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: AuthStyle.iconAvatarBig,
              color: AuthStyle.white,
            ),
          ),
          AuthStyle.gap14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? AuthStyle.defaultUserName,
                  style: AuthStyle.profileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AuthStyle.gap3,
                Text(
                  user?.email ?? AuthStyle.dash,
                  style: AuthStyle.profileEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AuthStyle.gapSm,
                _RoleBadge(
                  text: isAdmin ? AuthStyle.adminLabel : AuthStyle.userLabel,
                  isAdmin: isAdmin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String text;
  final bool isAdmin;
  const _RoleBadge({required this.text, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AuthStyle.padChipBadge,
      decoration: BoxDecoration(
        color: isAdmin ? AuthStyle.amber300 : AuthStyle.white24,
        borderRadius: AuthStyle.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified : Icons.person_outline,
            size: AuthStyle.iconBadgeSmall,
            color: isAdmin ? AuthStyle.brown900 : AuthStyle.white,
          ),
          AuthStyle.gap4,
          Text(
            text,
            style: AuthStyle.roleBadge.copyWith(
              color: isAdmin ? AuthStyle.brown900 : AuthStyle.white,
            ),
          ),
        ],
      ),
    );
  }
}