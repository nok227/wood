import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/auth/register_page.dart';
import 'package:wood/features/wood_products/presentation/widgets/wave_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
  }) : assert(
          title != null || titleWidget != null,
          'ต้องระบุ title หรือ titleWidget อย่างใดอย่างหนึ่ง',
        );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppBar(
// 🚀 ถ้าส่ง title เป็น String มา ให้ใช้ WaveText ในการแสดงผลคลื่นเต้น 1 ครั้ง
      title: titleWidget ??
          WaveText(
            text: title!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, size: 28),
          tooltip: 'ໂປຣຟາຍ',
          onPressed: () => _openProfilePage(context, authController),
        ),
      ],
    );
  }

  void _openProfilePage(BuildContext context, AuthController authController) {
    Get.to(
      () => const ProfileViewPage(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class ProfileViewPage extends StatelessWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('ຂໍ້ມູນໂປຣຟາຍ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'ອອກຈາກລະບົບ',
            onPressed: () => _confirmLogout(context, authController),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.brown,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'ຊື່ຜູ້ໃຊ້ (Name)',
              value: user?.displayName ?? 'ບໍ່ມີຂໍ້ມູນ',
            ),
            const Divider(),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'ອີເມວ (Email)',
              value: user?.email ?? 'ບໍ່ມີຂໍ້ມູນ',
            ),
            const Divider(),
            _buildInfoTile(
              icon: Icons.lock_outline,
              label: 'ລະຫັດຜ່ານ (Password)',
              value: '••••••••',
            ),
            const Divider(),
            _buildInfoTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'ສິດທິຜູ້ໃຊ້ (Role)',
              value: authController.isAdmin ? 'Admin' : 'User',
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    Get.defaultDialog(
      title: 'ຍືນຍັນການອອກຈາກລະບົບ',
      middleText: 'ທ່ານຕ້ອງການອອກຈາກລະບົບ ແມ່ນຫຼືບໍ່?',
      textConfirm: 'ອອກຈາກລະບົບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await authController.logout();
          Get.offAll(() => const RegisterPage());
        } catch (e) {
          Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດອອກຈາກລະບົບໄດ້: $e');
        }
      },
    );
  }
}