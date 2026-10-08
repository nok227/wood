import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/features/auth/domain/entities/menu_permission.dart';

class PermissionMenuTile extends StatelessWidget {
  final MenuKey menuKey;
  final bool isSelected;
  final VoidCallback onToggle;

  const PermissionMenuTile({
    super.key,
    required this.menuKey,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AuthStyle.marginTileBottom,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(
          color: isSelected ? AuthStyle.brown400 : AuthStyle.grey300,
          width: isSelected
              ? AuthStyle.borderWidthSelected
              : AuthStyle.borderWidthNormal,
        ),
        boxShadow: AuthStyle.cardLocal,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => onToggle(),
        activeColor: AuthStyle.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: AuthStyle.cardRadius,
        ),
        title: Row(
          children: [
            Icon(
              menuKey.icon,
              size: AuthStyle.iconMenuTile,
              color: AuthStyle.primary,
            ),
            AuthStyle.gapSm,
            Text(menuKey.label, style: AuthStyle.menuTileTitle),
          ],
        ),
        subtitle: Text(
          '${AuthStyle.keyPrefix}${menuKey.key}',
          style: AuthStyle.menuTileKey,
        ),
      ),
    );
  }
}