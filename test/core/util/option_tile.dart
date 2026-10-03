// lib/core/util/option_tile.dart

import 'package:flutter/material.dart';

/// 🎯 Option Tile — ຕົວເລືອກແບບ icon + title + subtitle
///
/// ໃຊ້ໃນ dialog / bottom sheet ເພື່ອໃຫ້ຜູ້ໃຊ້ເລືອກຢ່າງຊັດເຈນ
///
/// ຕົວຢ່າງ:
/// ```dart
/// OptionTile(
///   icon: Icons.check_circle_outline,
///   iconColor: Colors.green.shade700,
///   iconBg: Colors.green.shade50,
///   title: 'ຢືນຢັນເງິນເຂົ້າ',
///   subtitle: 'ບັນທຶກວ່າຮັບເງິນຄົບແລ້ວ',
///   onTap: () { ... },
/// )
/// ```
class OptionTile extends StatelessWidget {
  /// Icon ຫຼັກ
  final IconData icon;

  /// ສີຂອງ icon ແລະ title
  final Color iconColor;

  /// ສີພື້ນຫຼັງຂອງ icon (ວົງມົນ)
  final Color iconBg;

  /// ຫົວຂໍ້
  final String title;

  /// ຄຳອະທິບາຍເພີ່ມເຕີມ
  final String subtitle;

  /// callback ເມື່ອແຕະ
  final VoidCallback onTap;

  /// widget ທາງຂວາ (default = chevron_right)
  final Widget? trailing;

  const OptionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon ວົງມົນ ──
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Arrow ──
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}