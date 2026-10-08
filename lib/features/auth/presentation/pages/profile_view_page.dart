import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';

import '../controllers/admin_users_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/profile/logout_dialog.dart';
import '../widgets/profile/profile_empty.dart';
import '../widgets/profile/profile_my_card.dart';
import '../widgets/profile/profile_skeleton.dart';
import '../widgets/profile/profile_user_tile.dart';
import '../widgets/profile/profile_users_header.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  late final AuthController _auth;
  late final AdminUsersController _admin;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    _admin = Get.find<AdminUsersController>();
    if (_auth.isAdmin) _admin.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = _auth.currentUser.value;
      final isAdmin = _auth.isAdmin;
      final users = _admin.usersList;
      final loading = _admin.usersLoading.value;

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
              icon: const Icon(Icons.logout, size: AuthStyle.iconToolbar),
              tooltip: AuthStyle.logoutTooltip,
              onPressed: () => _logout(_auth),
            ),
          ],
        ),
        body: ListView(
          padding: AuthStyle.padPageList,
          children: [
            ProfileMyCard(user: user, isAdmin: isAdmin),
            if (isAdmin) ...[
              AuthStyle.gap20W,
              ProfileUsersHeader(
                count: users.length,
                onRefresh: _admin.usersLoading.value ? null : _admin.loadUsers,
              ),
              AuthStyle.gapSm,
              if (loading && users.isEmpty)
                const SizedBox(
                  height: AuthStyle.skeletonMinHeight,
                  child: ProfileSkeleton(),
                )
              else if (users.isEmpty)
                const ProfileEmpty()
              else
                ...users.map(
                  (u) => ProfileUserTile(
                    user: u,
                    currentUid: _auth.currentUser.value?.uid,
                    onPermissionSaved: _admin.loadUsers,
                  ),
                ),
            ],
            AuthStyle.gap24W,
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════
  // 🚪 Logout
  // ══════════════════════════════════════════
  void _logout(AuthController auth) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogCtx) => LogoutDialog(
        onCancel: () => Navigator.of(dialogCtx).pop(),
        onConfirm: () async {
          Navigator.of(dialogCtx).pop();
          try {
            await auth.logout();
            Get.offAll(() => const RegisterPage());
          } catch (e) {
            AppSnackbar.err(
              AuthStyle.errorMsg,
              '${AuthStyle.logoutError}: $e',
            );
          }
        },
      ),
    );
  }
}