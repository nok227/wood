// lib/features/wood_products/presentation/widgets/wood_list_skeleton.dart
//
// Skeleton loading (shimmer) สำหรับหน้า WoodProductListPage
// เลียนแบบโครงของการ์ดจริง (รูป + 3 บรรทัด) แทนการใช้ CircularProgressIndicator
// เขียนเองด้วย AnimationController + ShaderMask ไม่ต้องพึ่ง package เพิ่ม

import 'package:flutter/material.dart';

/// แสดงรายการ skeleton card หลายๆ อัน พร้อม shimmer effect วิ่งผ่าน
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
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) => _ShimmerCard(progress: _controller.value),
        );
      },
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
            _shimmerBox(width: 65, height: 65, radius: 6),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 120, height: 12, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 90, height: 14, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, required double radius}) {
    // สีไล่เฉด เลื่อนตำแหน่งตาม progress (0 -> 1) เพื่อให้ดูเหมือนแสงวิ่งผ่าน
    final dx = (progress * 3) - 1.5; // วิ่งจาก -1.5 ถึง 1.5 ของความกว้าง gradient
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