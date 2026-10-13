import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/shared/settings_button.dart';

import '../controllers/admin_users_controller.dart';
import '../controllers/auth_controller.dart';
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
    if (_auth.isAdmin) _admin.startListening();  // ⭐ เปลี่ยนจาก loadUsers()
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
          actions: const [
            SettingsButton(iconColor: AuthStyle.white),
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
                onRefresh: loading ? null : _admin.refreshUsers,  // ⭐ เปลี่ยน
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
                    onPermissionSaved: _admin.refreshUsers,  // ⭐ เปลี่ยน
                  ),
                ),
            ],
            AuthStyle.gap24W,
          ],
        ),
      );
    });
  }
}