import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/notification_style.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_host.dart';

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView.builder(
        padding: NotificationStyle.padList,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, _) => Container(
          margin: NotificationStyle.padTileMargin,
          padding: NotificationStyle.padCard,
          decoration: BoxDecoration(
            color: NotificationStyle.white,
            borderRadius: NotificationStyle.r10,
            border: Border.all(color: NotificationStyle.grey200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                width: NotificationStyle.iconBadge,
                height: NotificationStyle.iconBadge,
                progress: p,
                shape: BoxShape.circle,
              ),
              NotificationStyle.gap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: NotificationStyle.skeletonTitleW,
                      height: NotificationStyle.skeletonTitleH,
                      progress: p,
                    ),
                    NotificationStyle.gapSm,
                    ShimmerBox(
                      width: double.infinity,
                      height: NotificationStyle.skeletonMsgH,
                      progress: p,
                    ),
                    NotificationStyle.gap6,
                    ShimmerBox(
                      width: NotificationStyle.skeletonMetaW,
                      height: NotificationStyle.skeletonMetaH,
                      progress: p,
                    ),
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