import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_host.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView(
        padding: AuthStyle.padPageList,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: AuthStyle.padProfileCard,
            decoration: BoxDecoration(
              color: AuthStyle.brown200,
              borderRadius: AuthStyle.profileRadius,
            ),
            child: Row(
              children: [
                ShimmerBox(
                  width: AuthStyle.skeletonAvatarSize,
                  height: AuthStyle.skeletonAvatarSize,
                  progress: p,
                  shape: BoxShape.circle,
                ),
                AuthStyle.gap14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        width: double.infinity,
                        height: AuthStyle.skeletonTextH,
                        progress: p,
                      ),
                      AuthStyle.gapSm,
                      ShimmerBox(
                        width: AuthStyle.skeletonTextW,
                        height: AuthStyle.skeletonTextHSm,
                        progress: p,
                      ),
                      AuthStyle.gap10,
                      ShimmerBox(
                        width: AuthStyle.skeletonBadgeW,
                        height: AuthStyle.skeletonBadgeH,
                        progress: p,
                        radius: AuthStyle.skeletonBadgeR,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AuthStyle.gap20W,
          ShimmerBox(
            width: AuthStyle.skeletonTitleW,
            height: AuthStyle.skeletonTitleH,
            progress: p,
          ),
          AuthStyle.gap10,
          ...List.generate(
            count,
            (_) => Padding(
              padding: AuthStyle.marginTileBottom,
              child: ShimmerBox(
                width: double.infinity,
                height: AuthStyle.skeletonCardH,
                progress: p,
                radius: AuthStyle.skeletonCardR,
              ),
            ),
          ),
        ],
      ),
    );
  }
}