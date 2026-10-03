import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:wood/features/notifications/presentation/pages/notification_page.dart';
import 'package:wood/features/recipe/presentation/pages/library/recipe_library_page.dart';
import 'package:wood/features/auth/presentation/pages/profile_view_page.dart';
import 'wave_text.dart';

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
      title: titleWidget ??
          WaveText(
            text: title!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            replayOnRouteChange: false,
          ),
      actions: [
        IconButton(
          icon: const Icon(Icons.restaurant_menu, size: 24),
          tooltip: 'ຄັງເມນູອາຫານ',
          onPressed: () => Get.to(
            () => const RecipeLibraryPage(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          ),
        ),
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