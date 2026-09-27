import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/auth/register_page.dart';
import 'package:wood/features/wood_products/presentation/controllers/notification_controller.dart';
import 'package:wood/features/wood_products/presentation/pages/notification_page.dart';
import 'package:wood/features/wood_products/presentation/pages/recipe_library_page.dart';
import 'package:wood/features/wood_products/presentation/widgets/skeletons.dart';
import 'package:wood/features/wood_products/presentation/widgets/wave_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;

  const CustomAppBar({super.key, this.title, this.titleWidget})
    : assert(
        title != null || titleWidget != null,
        'ต้องระบุ title หรือ titleWidget อย่างใดอย่างหนึ่ง',
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          titleWidget ??
          WaveText(
            text: title!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            replayOnRouteChange: false, // ✅ ບໍ່ replay ຕາມ route — ກັນກະຕຸກ
          ),
      actions: [
        // 🍜 ຄັງເມນູອາຫານ
        IconButton(
          icon: const Icon(Icons.restaurant_menu, size: 24),
          tooltip: 'ຄັງເມນູອາຫານ',
          onPressed: () => Get.to(
            () => const RecipeLibraryPage(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          ),
        ),
        // 🔔 ແຈ້ງເຕືອນ
        Obx(() {
          if (!Get.isRegistered<NotificationController>()) {
            return const SizedBox.shrink();
          }
          final ctrl = Get.find<NotificationController>();
          final unread = ctrl.unreadCount;
          return IconButton(
            icon: Badge(
              isLabelVisible: unread > 0,
              backgroundColor: Colors.red.shade700,
              label: Text(
                unread > 99 ? '99+' : '$unread',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Icon(Icons.notifications_outlined, size: 26),
            ),
            tooltip: 'ແຈ້ງເຕືອນ',
            onPressed: () => Get.to(
              () => const NotificationPage(),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 300),
            ),
          );
        }),
        // 👤 ໂປຣຟາຍ
        IconButton(
          icon: const Icon(Icons.account_circle, size: 28),
          tooltip: 'ໂປຣຟາຍ',
          onPressed: () => Get.to(
            () => const ProfileViewPage(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 👤 ໜ້າໂປຣຟາຍ + ລາຍຊື່ຜູ້ໃຊ້ (Admin only)
// ══════════════════════════════════════════════
class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  List<_UserInfo> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isAdmin) _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('email')
          .get();
      final me = FirebaseAuth.instance.currentUser?.uid;

      final list =
          snap.docs.map((d) {
            final m = d.data();
            return _UserInfo(
              name: (m['name'] ?? m['displayName'] ?? m['username'] ?? '-')
                  .toString(),
              email: (m['email'] ?? '-').toString(),
              role: (m['role'] ?? 'user').toString(),
              isMe: d.id == me,
            );
          }).toList()..sort((a, b) {
            final aA = a.role.toLowerCase() == 'admin' ? 0 : 1;
            final bA = b.role.toLowerCase() == 'admin' ? 0 : 1;
            return aA != bA ? aA - bA : a.email.compareTo(b.email);
          });

      if (mounted) setState(() => _users = list);
    } catch (e) {
      debugPrint('Load users: $e');
      if (mounted) Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດຜູ້ໃຊ້ໄດ້');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: const Text('ໂປຣຟາຍ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ອອກຈາກລະບົບ',
            onPressed: () => _logout(auth),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _myCard(user, isAdmin),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            _usersHeader(),
            const SizedBox(height: 8),
            // ✅ ໃຊ້ ProfileSkeleton ແທນ CircularProgressIndicator
            if (_loading && _users.isEmpty)
              const SizedBox(height: 400, child: ProfileSkeleton())
            else if (_users.isEmpty)
              _emptyCard()
            else
              ..._users.map(_userTile),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _myCard(User? user, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade800, Colors.brown.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ??
                      user?.email?.split('@').first ??
                      'ຜູ້ໃຊ້',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '-',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _roleBadge(isAdmin ? 'Admin' : 'User', isAdmin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String text, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.amber.shade300 : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified : Icons.person_outline,
            size: 12,
            color: isAdmin ? Colors.brown.shade900 : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAdmin ? Colors.brown.shade900 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _usersHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'ລາຍຊື່ຜູ້ໃຊ້ (${_users.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          color: Colors.brown,
          onPressed: _loading ? null : _loadUsers,
          tooltip: 'ໂຫຼດໃໝ່',
        ),
      ],
    );
  }

  Widget _userTile(_UserInfo u) {
    final isAdmin = u.role.toLowerCase() == 'admin';
    final color = isAdmin ? Colors.amber.shade800 : Colors.brown;
    final bgColor = isAdmin ? Colors.amber.shade50 : Colors.brown.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          u.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (u.isMe) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ຂ້ອຍ',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    u.email,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.amber.shade200 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? 'Admin' : 'User',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? Colors.amber.shade900 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('ບໍ່ມີຜູ້ໃຊ້', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _logout(AuthController auth) {
    Get.defaultDialog(
      title: 'ຍືນຍັນການອອກຈາກລະບົບ',
      middleText: 'ຕ້ອງການອອກຈາກລະບົບແມ່ນບໍ່?',
      textConfirm: 'ອອກຈາກລະບົບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await auth.logout();
          Get.offAll(() => const RegisterPage());
        } catch (e) {
          Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອອກໄດ້: $e');
        }
      },
    );
  }
}

class _UserInfo {
  final String name;
  final String email;
  final String role;
  final bool isMe;

  _UserInfo({
    required this.name,
    required this.email,
    required this.role,
    required this.isMe,
  });
}
