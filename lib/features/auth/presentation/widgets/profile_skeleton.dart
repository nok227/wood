import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ShimmerBox(
                    width: 64,
                    height: 64,
                    progress: p,
                    shape: BoxShape.circle),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                          width: double.infinity, height: 16, progress: p),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 140, height: 12, progress: p),
                      const SizedBox(height: 10),
                      ShimmerBox(
                          width: 70, height: 18, progress: p, radius: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ShimmerBox(width: 160, height: 15, progress: p),
          const SizedBox(height: 10),
          ...List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShimmerBox(
                  width: double.infinity, height: 64, progress: p, radius: 12),
            ),
          ),
        ],
      ),
    );
  }
}