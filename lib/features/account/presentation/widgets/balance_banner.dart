import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

import '../controllers/account_controller.dart';

class BalanceBanner extends StatelessWidget {
  final AccountController controller;
  const BalanceBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bal = controller.balance;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: AccountStyle.padBanner,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AccountStyle.bannerGradStart,
              AccountStyle.bannerGradEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AccountStyle.r14,
          boxShadow: [
            BoxShadow(
              color: AccountStyle.brown700.withOpacity(
                  AccountStyle.bannerShadowOpacity),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: AccountStyle.white70, size: 12),
                SizedBox(width: 4),
                Text(AccountStyle.balanceLabel,
                    style: TextStyle(
                        color: AccountStyle.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
              ],
            ),
            AccountStyle.gap2,
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedNumber(
                value: bal,
                suffix: ' ${AccountStyle.currency}',
                duration: AccountStyle.animNormal.inMilliseconds,
                style: TextStyle(
                  color: bal < 0
                      ? AccountStyle.bannerNegative
                      : AccountStyle.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            AccountStyle.gapSm,
            Row(
              children: [
                Expanded(
                  child: _tile(Icons.payments_outlined,
                      AccountStyle.cashLabel, controller.cashBalance),
                ),
                Container(
                    width: 1,
                    height: AccountStyle.bannerDividerH,
                    color: AccountStyle.white24),
                Expanded(
                  child: _tile(Icons.account_balance,
                      AccountStyle.transferLabel, controller.transferBalance),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _tile(IconData i, String l, double v) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: AccountStyle.white70, size: 11),
              AccountStyle.gap3,
              Text(l, style: AccountStyle.bannerStatLabel.copyWith(
                  color: AccountStyle.white70)),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedNumber(
              value: v,
              suffix: ' ${AccountStyle.currency}',
              duration: AccountStyle.animFast.inMilliseconds,
              style: AccountStyle.bannerStatValue.copyWith(
                  color: AccountStyle.white),
            ),
          ),
        ],
      );
}