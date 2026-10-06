import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/auth/domain/entities/app_user.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';
import 'package:wood/features/auth/presentation/pages/user_permission_page.dart';
import 'package:wood/features/auth/presentation/widgets/profile_skeleton.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    if (_auth.isAdmin) {
      _auth.loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = _auth.currentUser.value;
      final isAdmin = _auth.isAdmin;
      final users = _auth.usersList;
      final loading = _auth.usersLoading.value;

      return Scaffold(
        backgroundColor: AuthStyle.bg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: Get.back,
          ),
          title: const Text(AuthStyle.profileTitle),
          backgroundColor: AuthStyle.primary,
          foregroundColor: AuthStyle.white,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: AuthStyle.iconToolbar,
              ),
              tooltip: AuthStyle.logoutTooltip,
              onPressed: () => _logout(_auth),
            ),
          ],
        ),
        body: ListView(
          padding: AuthStyle.padPageList,
          children: [
            _myCard(user, isAdmin),
            if (isAdmin) ...[
              AuthStyle.gap20W,
              _usersHeader(users.length),
              AuthStyle.gapSm,
              if (loading && users.isEmpty)
                const SizedBox(
                  height: AuthStyle.skeletonMinHeight,
                  child: ProfileSkeleton(),
                )
              else if (users.isEmpty)
                _emptyCard()
              else
                ...users.map(_userTile),
            ],
            AuthStyle.gap24W,
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════
  // My card
  // ══════════════════════════════════════════
  Widget _myCard(AppUser? user, bool isAdmin) {
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
                _roleBadge(
                  isAdmin ? AuthStyle.adminLabel : AuthStyle.userLabel,
                  isAdmin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String text, bool isAdmin) {
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

  // ══════════════════════════════════════════
  // Users header
  // ══════════════════════════════════════════
  Widget _usersHeader(int count) {
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
          onPressed: _auth.usersLoading.value ? null : _auth.loadUsers,
          tooltip: AuthStyle.refreshTooltip,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // User tile
  // ══════════════════════════════════════════
  Widget _userTile(AppUser u) {
    final isAdmin = u.isAdmin;
    final color = isAdmin ? AuthStyle.amber800 : AuthStyle.primary;
    final bgColor = isAdmin ? AuthStyle.amber50 : AuthStyle.brown50;
    final isMe = u.uid == _auth.currentUser.value?.uid;

    return Container(
      margin: AuthStyle.marginTileBottom,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(
          color: color.withOpacity(AuthStyle.borderOpacity),
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
                  color: color.withOpacity(AuthStyle.circleBorderOpacity),
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
                          u.displayName,
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
                    u.email ?? AuthStyle.dash,
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
                      uid: u.uid,
                      name: u.displayName,
                      email: u.email ?? AuthStyle.dash,
                      initialAllowed: u.allowedMenus,
                    ),
                  );
                  if (mounted) _auth.loadUsers();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // Empty
  // ══════════════════════════════════════════
  Widget _emptyCard() {
    return Container(
      padding: AuthStyle.padEmptyCard,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(color: AuthStyle.grey300),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: AuthStyle.emptyIconSize,
            color: AuthStyle.grey400,
          ),
          AuthStyle.gapSm,
          const Text(AuthStyle.noUsers, style: AuthStyle.emptyText),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // Logout
  // ══════════════════════════════════════════
  void _logout(AuthController auth) {
    Get.defaultDialog(
      title: AuthStyle.logoutTitle,
      middleText: AuthStyle.logoutConfirm,
      textConfirm: AuthStyle.logoutBtn,
      textCancel: AuthStyle.cancel,
      confirmTextColor: AuthStyle.white,
      buttonColor: AuthStyle.errorRed,
      onConfirm: () async {
        Get.back();
        try {
          await auth.logout();
          Get.offAll(() => const RegisterPage());
        } catch (e) {
          AppSnackbar.err(AuthStyle.errorMsg, '${AuthStyle.logoutError}: $e');
        }
      },
    );
  }
}