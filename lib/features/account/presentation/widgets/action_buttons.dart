import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/account_style.dart';

class ActionButtons extends StatelessWidget {
  final void Function(String type) onTap;
  const ActionButtons({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AccountStyle.padActionRow,
      child: Row(
        children: [
          Expanded(
            child: _btn(
              Icons.arrow_downward_rounded,
              AccountStyle.receiveBtn,
              AccountStyle.receiveSub,
              AccountStyle.incomeBtnStart,
              AccountStyle.incomeBtnEnd,
              () => onTap('in'),
            ),
          ),
          AccountStyle.gap10,
          Expanded(
            child: _btn(
              Icons.arrow_upward_rounded,
              AccountStyle.payBtn,
              AccountStyle.paySub,
              AccountStyle.expenseBtnStart,
              AccountStyle.expenseBtnEnd,
              () => onTap('out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(
      IconData i, String t, String s, Color c1, Color c2, VoidCallback tap) {
    return Material(
      color: AccountStyle.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: AccountStyle.r14,
        child: Container(
          padding: AccountStyle.padActionBtn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c1, c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AccountStyle.r14,
            boxShadow: AccountStyle.colored(c2),
          ),
          child: Row(
            children: [
              Container(
                width: AccountStyle.iconCircleSize,
                height: AccountStyle.iconCircleSize,
                decoration: BoxDecoration(
                  color: AccountStyle.white
                      .withOpacity(AccountStyle.iconCircleOpacity),
                  shape: BoxShape.circle,
                ),
                child: Icon(i, color: AccountStyle.white, size: 20),
              ),
              AccountStyle.gap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: AccountStyle.actionTitleText.copyWith(
                        color: AccountStyle.white)),
                    const SizedBox(height: 1),
                    Text(s, style: AccountStyle.actionSubText.copyWith(
                        color: AccountStyle.white.withOpacity(
                            AccountStyle.subTextOpacity))),
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