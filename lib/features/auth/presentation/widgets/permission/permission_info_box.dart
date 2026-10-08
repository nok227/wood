import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';

class PermissionInfoBox extends StatelessWidget {
  const PermissionInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AuthStyle.padInfo,
      decoration: BoxDecoration(
        color: AuthStyle.amber50,
        borderRadius: AuthStyle.r10,
        border: Border.all(color: AuthStyle.amber300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: AuthStyle.iconPreset,
            color: AuthStyle.amber900,
          ),
          AuthStyle.gapSm,
          const Expanded(
            child: Text(
              AuthStyle.permissionInfo,
              style: AuthStyle.infoText,
            ),
          ),
        ],
      ),
    );
  }
}