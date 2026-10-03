import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

class Wood3DSkeleton extends StatelessWidget {
  const Wood3DSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => Container(
        color: const Color(0xFFEFEBE9),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.brown[50],
                child: Center(
                  child: ShimmerBox(
                    width: 200,
                    height: 160,
                    progress: p,
                    radius: 14,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                            width: double.infinity,
                            height: 46,
                            progress: p,
                            radius: 6),
                      ),
                      const SizedBox(width: 8),
                      ShimmerBox(
                          width: 90, height: 46, progress: p, radius: 6),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                            width: double.infinity,
                            height: 46,
                            progress: p,
                            radius: 6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ShimmerBox(
                            width: double.infinity,
                            height: 46,
                            progress: p,
                            radius: 6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}