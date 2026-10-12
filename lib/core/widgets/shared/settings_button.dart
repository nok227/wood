import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'settings_popup.dart';

/// ══════════════════════════════════════════════
/// ⚙️ ปุ่ม Settings — เปิด popup ลอยติดกับปุ่ม
/// ══════════════════════════════════════════════
class SettingsButton extends StatelessWidget {
  final Color? iconColor;
  final double size;

  const SettingsButton({
    super.key,
    this.iconColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) => IconButton(
        icon: Icon(Icons.settings, size: size, color: iconColor),
        tooltip: 'ຕັ້ງຄ່າ',
        onPressed: () {
          final auth = Get.find<AuthController>();
          final renderBox = btnContext.findRenderObject() as RenderBox;
          final overlay =
              Overlay.of(btnContext).context.findRenderObject() as RenderBox;

          SettingsPopup.show(
            context: btnContext,
            auth: auth,
            buttonPosition: renderBox.localToGlobal(
              Offset.zero,
              ancestor: overlay,
            ),
            buttonSize: renderBox.size,
            overlaySize: overlay.size,
          );
        },
      ),
    );
  }
}