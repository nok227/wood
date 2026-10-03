import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

class SalesSummarySkeleton extends StatelessWidget {
  const SalesSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ShimmerBox(
              width: double.infinity, height: 110, progress: p, radius: 12),
          const SizedBox(height: 10),
          for (int i = 0; i < 4; i++) ...[
            Row(
              children: [
                Expanded(child: _tile(p)),
                const SizedBox(width: 8),
                Expanded(child: _tile(p)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          ShimmerBox(width: 180, height: 16, progress: p),
          const SizedBox(height: 10),
          ShimmerBox(
              width: double.infinity, height: 130, progress: p, radius: 10),
          const SizedBox(height: 16),
          ShimmerBox(width: 220, height: 16, progress: p),
          const SizedBox(height: 10),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ShimmerBox(
                  width: double.infinity, height: 56, progress: p, radius: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(double p) => ShimmerBox(
        width: double.infinity,
        height: 76,
        progress: p,
        radius: 10,
      );
}