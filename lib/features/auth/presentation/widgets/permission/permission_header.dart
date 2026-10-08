import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';

class PermissionHeader extends StatelessWidget {
  final String name;
  final String email;

  const PermissionHeader({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AuthStyle.padHeader,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AuthStyle.brown700, AuthStyle.brown500],
        ),
        borderRadius: AuthStyle.r14,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: AuthStyle.avatarMd,
            backgroundColor: AuthStyle.white24,
            child: Icon(
              Icons.person,
              color: AuthStyle.white,
              size: AuthStyle.iconAvatarMd,
            ),
          ),
          AuthStyle.gap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AuthStyle.profileNameSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AuthStyle.gap2,
                Text(
                  email,
                  style: AuthStyle.profileEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}