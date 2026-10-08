import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

class AccountBalanceBanner extends StatelessWidget {
  final double balance;
  final double cashBalance;
  final double transferBalance;

  const AccountBalanceBanner({
    super.key,
    required this.balance,
    required this.cashBalance,
    required this.transferBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: AccountStyle.padBanner,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AccountStyle.bannerGradStart, AccountStyle.bannerGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AccountStyle.r14,
        boxShadow: [
          BoxShadow(
            color: AccountStyle.brown700
                .withValues(alpha: AccountStyle.bannerShadowOpacity),
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
              value: balance,
              suffix: ' ${AccountStyle.currency}',
              duration: AccountStyle.animNormal.inMilliseconds,
              style: TextStyle(
                color: balance < 0
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
                child: _Tile(
                  icon: Icons.payments_outlined,
                  label: AccountStyle.cashLabel,
                  value: cashBalance,
                ),
              ),
              Container(
                width: 1,
                height: AccountStyle.bannerDividerH,
                color: AccountStyle.white24,
              ),
              Expanded(
                child: _Tile(
                  icon: Icons.account_balance,
                  label: AccountStyle.transferLabel,
                  value: transferBalance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  const _Tile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AccountStyle.white70, size: 11),
            AccountStyle.gap3,
            Text(label,
                style: AccountStyle.bannerStatLabel
                    .copyWith(color: AccountStyle.white70)),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: value,
            suffix: ' ${AccountStyle.currency}',
            duration: AccountStyle.animFast.inMilliseconds,
            style: AccountStyle.bannerStatValue
                .copyWith(color: AccountStyle.white),
          ),
        ),
      ],
    );
  }
}