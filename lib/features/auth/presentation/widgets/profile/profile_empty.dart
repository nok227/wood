import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/auth_style.dart';

class ProfileEmpty extends StatelessWidget {
  const ProfileEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AuthStyle.padEmptyCard,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(color: AuthStyle.grey300),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: AuthStyle.emptyIconSize,
            color: AuthStyle.grey400,
          ),
          AuthStyle.gapSm,
          const Text(AuthStyle.noUsers, style: AuthStyle.emptyText),
        ],
      ),
    );
  }
}