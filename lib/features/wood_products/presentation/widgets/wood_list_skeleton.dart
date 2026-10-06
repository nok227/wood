import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

class WoodListSkeleton extends StatefulWidget {
  final int groupCount;
  const WoodListSkeleton({super.key, this.groupCount = 3});

  @override
  State<WoodListSkeleton> createState() => _WoodListSkeletonState();
}

class _WoodListSkeletonState extends State<WoodListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: WoodStyle.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ListView.builder(
        padding: WoodStyle.padPage,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.groupCount,
        itemBuilder: (context, index) => _ShimmerGroup(
          progress: _controller.value,
          itemCounts: index == 0
              ? [2, 2]
              : index == 1
                  ? [3]
                  : [1, 2],
        ),
      ),
    );
  }
}

class _ShimmerGroup extends StatelessWidget {
  final double progress;
  final List<int> itemCounts;

  const _ShimmerGroup({
    required this.progress,
    required this.itemCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: WoodStyle.white,
        borderRadius: WoodStyle.cardRadius,
        border: Border.all(color: WoodStyle.brown300, width: 1.2),
        boxShadow: WoodStyle.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [WoodStyle.brown300, WoodStyle.brown200],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: WoodStyle.r11,
            ),
            child: Row(
              children: [
                _box(w: 16, h: 16, r: 4, color: WoodStyle.brown200),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(
                          w: 100,
                          h: 13,
                          r: 4,
                          color: WoodStyle.brown200),
                      const SizedBox(height: 3),
                      _box(
                          w: 130,
                          h: 10,
                          r: 4,
                          color: WoodStyle.brown200),
                    ],
                  ),
                ),
                _box(w: 28, h: 18, r: 10, color: WoodStyle.brown200),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < itemCounts.length; i++) ...[
                  _shimmerSubHeader(),
                  const SizedBox(height: 4),
                  for (int j = 0; j < itemCounts[i]; j++) ...[
                    const _ShimmerProductCard(),
                    if (j < itemCounts[i] - 1) _shimmerDivider(),
                  ],
                  if (i < itemCounts.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: WoodStyle.brown50,
        borderRadius: WoodStyle.r8,
        border: Border.all(
          color: WoodStyle.brown200.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _box(w: 13, h: 13, r: 3, color: WoodStyle.brown100),
          const SizedBox(width: 6),
          Expanded(
            child:
                _box(w: 100, h: 11, r: 4, color: WoodStyle.brown100),
          ),
          _box(w: 50, h: 14, r: 6, color: WoodStyle.brown100),
        ],
      ),
    );
  }

  Widget _shimmerDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashSpace = 4.0;
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: WoodStyle.grey200,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(w: 72, h: 130, r: 8),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _box(w: 40, h: 9, r: 3),
                      const SizedBox(height: 3),
                      _box(w: 160, h: 13, r: 4),
                      const SizedBox(height: 4),
                      _box(w: 140, h: 10, r: 4),
                      const SizedBox(height: 3),
                      _box(w: 110, h: 10, r: 4),
                      const SizedBox(height: 6),
                      _box(w: 36, h: 9, r: 3),
                      const SizedBox(height: 3),
                      _box(w: 60, h: 11, r: 4),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _box(w: 40, h: 11, r: 3),
                        const SizedBox(width: 6),
                        _box(w: 90, h: 15, r: 4),
                        const SizedBox(width: 5),
                        _box(w: 34, h: 14, r: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          _box(w: 28, h: 28, r: 4),
        ],
      ),
    );
  }
}

Widget _box({
  required double w,
  required double h,
  required double r,
  Color? color,
}) {
  if (color != null) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
  return _ShimmerBox(width: w, height: h, radius: r);
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WoodStyle.grey300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}