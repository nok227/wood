import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/theme/app_color_service.dart';
import 'package:wood/core/theme/app_theme_registry.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';

class SettingsPopup {
  SettingsPopup._();

  static Future<void> show({
    required BuildContext context,
    required AuthController auth,
    required Offset buttonPosition,
    required Size buttonSize,
    required Size overlaySize,
  }) async {
    const popupWidth = 220.0;
    const gap = 4.0;
    const rightPadding = 8.0;

    double left = overlaySize.width - popupWidth - rightPadding;
    final arrowX = (buttonPosition.dx + buttonSize.width / 2) - left;
    final top = buttonPosition.dy + buttonSize.height + gap;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => _SettingsPopupContent(
        auth: auth,
        top: top,
        left: left,
        width: popupWidth,
        arrowX: arrowX,
      ),
    );
  }
}

class _SettingsPopupContent extends StatefulWidget {
  final AuthController auth;
  final double top, left, width, arrowX;

  const _SettingsPopupContent({
    required this.auth,
    required this.top,
    required this.left,
    required this.width,
    required this.arrowX,
  });

  @override
  State<_SettingsPopupContent> createState() => _SettingsPopupContentState();
}

class _SettingsPopupContentState extends State<_SettingsPopupContent> {
  bool _themeExpanded = false;

  void _toggleTheme() {
    setState(() => _themeExpanded = !_themeExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── พื้นหลังโปร่งใส ──
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Get.back(),
          ),
        ),

        // ── Popup + ลูกศร ──
        Positioned(
          top: widget.top,
          left: widget.left,
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── ลูกศร ──
              Padding(
                padding: EdgeInsets.only(left: widget.arrowX - 7),
                child: CustomPaint(
                  size: const Size(14, 7),
                  painter: _ArrowPainter(),
                ),
              ),
              // ── กล่อง popup ──
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: AppColors.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ຕັ້ງຄ່າ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, color: Colors.grey.shade200),

                      // ── Theme picker (dropdown) ──
                      _ThemeDropdown(
                        expanded: _themeExpanded,
                        onToggle: _toggleTheme,
                      ),

                      Divider(height: 1, color: Colors.grey.shade200),

                      // ── Logout ──
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'ອອກ',
                        color: AppColors.error700,
                        onTap: () async {
                          Get.back();
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          try {
                            await widget.auth.logout();
                          } catch (_) {}
                          Get.offAll(() => const RegisterPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 🎨 THEME DROPDOWN — กดแล้วเลือกสี
// ══════════════════════════════════════════════
class _ThemeDropdown extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _ThemeDropdown({
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<AppColorService>();

    return Obx(() {
      final current = kAppThemes[svc.themeIndex.value];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header — กดเพื่อเปิด/ปิด ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ໂທນສີ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // ── สีปัจจุบัน (วงกลม) ──
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [current.p500, current.p800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // ── ลูกศร ──
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── รายการสี (แสดงเมื่อ expanded) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < kAppThemes.length; i++)
                        _ThemeOption(
                          theme: kAppThemes[i],
                          selected: svc.themeIndex.value == i,
                          onTap: () => svc.change(i),
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════
// 🎨 THEME OPTION — 1 สีในรายการ
// ══════════════════════════════════════════════
class _ThemeOption extends StatelessWidget {
  final AppThemeData theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 7, 12, 7),
          child: Row(
            children: [
              // ── วงกลมสี ──
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.p500, theme.p800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Colors.black87
                        : Colors.black.withValues(alpha: 0.15),
                    width: selected ? 2 : 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ── ชื่อสี ──
              Expanded(
                child: Text(
                  theme.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        selected ? FontWeight.w900 : FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              // ── เครื่องหมายถูก ──
              if (selected)
                Icon(
                  Icons.check,
                  size: 15,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 🎯 MENU ITEM (Logout)
// ══════════════════════════════════════════════
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 🔺 ลูกศรชี้ขึ้น
// ══════════════════════════════════════════════
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}