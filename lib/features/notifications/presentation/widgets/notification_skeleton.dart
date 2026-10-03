import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                  width: 38,
                  height: 38,
                  progress: p,
                  shape: BoxShape.circle),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 13, progress: p),
                    const SizedBox(height: 8),
                    ShimmerBox(
                        width: double.infinity, height: 11, progress: p),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 10, progress: p),
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