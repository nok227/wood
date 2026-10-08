import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_host.dart';

class AccountPageSkeleton extends StatelessWidget {
  const AccountPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Balance banner ──
          Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: AccountStyle.padBanner,
            decoration: BoxDecoration(
              color: AccountStyle.brown200,
              borderRadius: AccountStyle.r12,
            ),
            child: Column(
              children: [
                ShimmerBox(width: 90, height: 12, progress: p),
                AccountStyle.gap10,
                ShimmerBox(width: 180, height: 26, progress: p),
                AccountStyle.gapMd,
                Row(
                  children: [
                    Expanded(
                        child: ShimmerBox(
                            width: double.infinity,
                            height: 14,
                            progress: p)),
                    AccountStyle.gapSm,
                    Expanded(
                        child: ShimmerBox(
                            width: double.infinity,
                            height: 14,
                            progress: p)),
                  ],
                ),
              ],
            ),
          ),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            child: Row(
              children: [
                Expanded(
                    child: ShimmerBox(
                        width: double.infinity,
                        height: 54,
                        progress: p,
                        radius: 10)),
                AccountStyle.gapSm,
                Expanded(
                    child: ShimmerBox(
                        width: double.infinity,
                        height: 54,
                        progress: p,
                        radius: 10)),
              ],
            ),
          ),
          AccountStyle.gap6,

          // ── Session cards ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, _) => _sessionCard(p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(double p) => Card(
        color: AccountStyle.brown50,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9)),
        child: Padding(
          padding: AccountStyle.padCard,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AccountStyle.brown800,
                      borderRadius: AccountStyle.r6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShimmerBox(
                            width: 50, height: 10, progress: p, radius: 3),
                        AccountStyle.gap3,
                        ShimmerBox(
                            width: 40, height: 8, progress: p, radius: 3),
                      ],
                    ),
                  ),
                  AccountStyle.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 60, height: 12, progress: p),
                        AccountStyle.gap6,
                        ShimmerBox(width: 90, height: 10, progress: p),
                      ],
                    ),
                  ),
                  ShimmerBox(
                      width: 26, height: 16, progress: p, radius: 8),
                ],
              ),
              AccountStyle.gap10,
              Row(
                children: [
                  Expanded(
                      child: ShimmerBox(
                          width: double.infinity,
                          height: 24,
                          progress: p)),
                  AccountStyle.gap6,
                  Expanded(
                      child: ShimmerBox(
                          width: double.infinity,
                          height: 24,
                          progress: p)),
                  AccountStyle.gap6,
                  Expanded(
                      child: ShimmerBox(
                          width: double.infinity,
                          height: 24,
                          progress: p)),
                ],
              ),
            ],
          ),
        ),
      );
}