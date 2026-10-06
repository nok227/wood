import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_3d_style.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_host.dart';

class Wood3DSkeleton extends StatelessWidget {
  const Wood3DSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => Container(
        color: Wood3DStyle.wood3dBg,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Wood3DStyle.brown50,
                child: Center(
                  child: ShimmerBox(
                    width: Wood3DStyle.skelCardW,
                    height: Wood3DStyle.skelCardH,
                    progress: p,
                    radius: Wood3DStyle.skelCardRadius,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: Wood3DStyle.padSkeleton,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: Wood3DStyle.skelBoxH,
                          progress: p,
                          radius: Wood3DStyle.skelBoxRadius,
                        ),
                      ),
                      Wood3DStyle.gap8,
                      ShimmerBox(
                        width: Wood3DStyle.skelBoxW,
                        height: Wood3DStyle.skelBoxH,
                        progress: p,
                        radius: Wood3DStyle.skelBoxRadius,
                      ),
                    ],
                  ),
                  Wood3DStyle.gap10,
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: Wood3DStyle.skelBoxH,
                          progress: p,
                          radius: Wood3DStyle.skelBoxRadius,
                        ),
                      ),
                      Wood3DStyle.gap8,
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: Wood3DStyle.skelBoxH,
                          progress: p,
                          radius: Wood3DStyle.skelBoxRadius,
                        ),
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