// lib/features/wood_products/presentation/widgets/wood_list_skeleton.dart

import 'package:flutter/material.dart';

class WoodListSkeleton extends StatefulWidget {
  final int itemCount;
  const WoodListSkeleton({super.key, this.itemCount = 6});

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
      duration: const Duration(milliseconds: 1400),
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
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) =>
            _ShimmerCard(progress: _controller.value),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double progress;
  const _ShimmerCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ thumbnail 82×82 ຕົງກັບ _productCard ຈິງ
            _shimmerBox(width: 82, height: 82, radius: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ຂະໜາດ (3 ຕົວເລກ)
                  _shimmerBox(width: 160, height: 13, radius: 4),
                  const SizedBox(height: 4),
                  // ແຖວແປງໜ່ວຍ (ຍາວນ້ອຍກວ່າ)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _shimmerBox(width: 130, height: 10, radius: 4),
                  ),
                  const SizedBox(height: 6),
                  // ຈຳນວນ
                  _shimmerBox(width: 70, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  // ✅ price box ສີຂຽວ (ຄ້າຍ _priceBox)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 13, color: Colors.green.shade200),
                        const SizedBox(width: 5),
                        _shimmerBox(width: 80, height: 14, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    final dx = (progress * 3) - 1.5;
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        colors: const [
          Color(0xFFE0E0E0),
          Color(0xFFF5F5F5),
          Color(0xFFE0E0E0),
        ],
        stops: const [0.35, 0.5, 0.65],
        begin: Alignment(-1 + dx, 0),
        end: Alignment(1 + dx, 0),
      ).createShader(rect),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}