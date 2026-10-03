import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

class RecipeListSkeleton extends StatelessWidget {
  const RecipeListSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 84, height: 84, progress: p, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShimmerBox(
                                width: double.infinity,
                                height: 15,
                                progress: p),
                          ),
                          const SizedBox(width: 8),
                          ShimmerBox(
                              width: 20,
                              height: 20,
                              progress: p,
                              shape: BoxShape.circle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          ShimmerBox(
                              width: 60, height: 14, progress: p, radius: 5),
                          ShimmerBox(
                              width: 50, height: 14, progress: p, radius: 5),
                          ShimmerBox(
                              width: 55, height: 14, progress: p, radius: 5),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ShimmerBox(
                          width: double.infinity, height: 11, progress: p),
                      const SizedBox(height: 4),
                      ShimmerBox(width: 140, height: 11, progress: p),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ShimmerBox(width: 100, height: 11, progress: p),
                          const Spacer(),
                          ShimmerBox(
                              width: 60, height: 20, progress: p, radius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}