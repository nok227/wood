import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/widgets/global/bounce_wrapper.dart';
import 'package:wood/core/widgets/global/notification_bell.dart';
import 'package:wood/core/widgets/global/wave_text.dart';
import 'package:wood/features/recipe/presentation/pages/library/recipe_library_page.dart';
import 'package:wood/features/auth/presentation/pages/profile_view_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;

  const CustomAppBar({super.key, this.title, this.titleWidget})
      : assert(
          title != null || titleWidget != null,
          'ຕ້ອງລະບຸ title ຫຼື titleWidget ຢ່າງໃດຢ່າງໜຶ່ງ',
        );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          WaveText(
            text: title!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            replayOnRouteChange: true,
          ),
      actions: [
        // 🍴 Recipe — เด้งตัวแรก (delay 0)
        BounceWrapper(
          delay: Duration.zero,
          child: IconButton(
            icon: const Icon(Icons.restaurant_menu, size: 24),
            tooltip: 'ຄັງເມນູອາຫານ',
            onPressed: () => Get.to(
              () => const RecipeLibraryPage(),
              transition: Transition.downToUp,
              duration: AppDurations.normal,
            ),
          ),
        ),

        // 🔔 Bell — เด้งตัวที่ 2 (delay 80ms)
        const BounceWrapper(
          delay: Duration(milliseconds: 80),
          child: NotificationBell(),
        ),

        // 👤 Profile — เด้งตัวที่ 3 (delay 160ms)
        BounceWrapper(
          delay: const Duration(milliseconds: 160),
          child: IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            tooltip: 'ໂປຣຟາຍ',
            onPressed: () => Get.to(
              () => const ProfileViewPage(),
              transition: Transition.downToUp,
              duration: AppDurations.normal,
            ),
          ),
        ),
      ],
    );
  }
}