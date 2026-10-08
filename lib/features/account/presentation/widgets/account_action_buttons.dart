import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/account_style.dart';

class AccountActionButtons extends StatelessWidget {
  final void Function(String type) onTap;
  const AccountActionButtons({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AccountStyle.padActionRow,
      child: Row(
        children: [
          Expanded(
            child: _Btn(
              icon: Icons.arrow_downward_rounded,
              title: AccountStyle.receiveBtn,
              subtitle: AccountStyle.receiveSub,
              start: AccountStyle.incomeBtnStart,
              end: AccountStyle.incomeBtnEnd,
              onTap: () => onTap('in'),
            ),
          ),
          AccountStyle.gap10,
          Expanded(
            child: _Btn(
              icon: Icons.arrow_upward_rounded,
              title: AccountStyle.payBtn,
              subtitle: AccountStyle.paySub,
              start: AccountStyle.expenseBtnStart,
              end: AccountStyle.expenseBtnEnd,
              onTap: () => onTap('out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color start, end;
  final VoidCallback onTap;

  const _Btn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.end,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AccountStyle.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AccountStyle.r14,
        child: Container(
          padding: AccountStyle.padActionBtn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [start, end],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AccountStyle.r14,
            boxShadow: AccountStyle.colored(end),
          ),
          child: Row(
            children: [
              Container(
                width: AccountStyle.iconCircleSize,
                height: AccountStyle.iconCircleSize,
                decoration: BoxDecoration(
                  color: AccountStyle.white
                      .withValues(alpha: AccountStyle.iconCircleOpacity),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AccountStyle.white, size: 20),
              ),
              AccountStyle.gap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AccountStyle.actionTitleText
                            .copyWith(color: AccountStyle.white)),
                    const SizedBox(height: 1),
                    Text(subtitle,
                        style: AccountStyle.actionSubText.copyWith(
                            color: AccountStyle.white
                                .withValues(alpha: AccountStyle.subTextOpacity))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}