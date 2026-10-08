import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';

class PermissionPresets extends StatelessWidget {
  final VoidCallback onViewOnly;
  final VoidCallback onAll;
  final VoidCallback onNone;

  const PermissionPresets({
    super.key,
    required this.onViewOnly,
    required this.onAll,
    required this.onNone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewOnly,
            icon: const Icon(
              Icons.visibility_outlined,
              size: AuthStyle.iconPreset,
            ),
            label: const Text(AuthStyle.viewOnly),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.primary,
              side: const BorderSide(color: AuthStyle.brown300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
        AuthStyle.gapSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAll,
            icon: const Icon(Icons.done_all, size: AuthStyle.iconPreset),
            label: const Text(AuthStyle.allMenus),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.successDark,
              side: const BorderSide(color: AuthStyle.success300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
        AuthStyle.gapSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNone,
            icon: const Icon(Icons.block, size: AuthStyle.iconPreset),
            label: const Text(AuthStyle.noAccess),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.error700,
              side: const BorderSide(color: AuthStyle.error300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
      ],
    );
  }
}