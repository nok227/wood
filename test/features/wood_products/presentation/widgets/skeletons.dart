// lib/features/wood_products/presentation/widgets/skeletons.dart
//
// 🦴 Skeleton loading ລວມ — 1 AnimationController ຕໍ່ 1 list (performance)
// ຫຸ້ມດ້ວຍ RepaintBoundary ໝົດ ເພື່ອບໍ່ໃຫ້ repaint ທັງໜ້າ

import 'package:flutter/material.dart';

// ══════════════════════════════════════════════
// 🦴 Shimmer Box (reusable)
// ══════════════════════════════════════════════
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double progress;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
    required this.progress,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
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
          shape: shape,
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 🎬 Shimmer Host — 1 controller ຕໍ່ 1 skeleton list
// ══════════════════════════════════════════════
class ShimmerHost extends StatefulWidget {
  final Widget Function(BuildContext context, double progress) builder;
  const ShimmerHost({super.key, required this.builder});

  @override
  State<ShimmerHost> createState() => _ShimmerHostState();
}

class _ShimmerHostState extends State<ShimmerHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => widget.builder(context, _ctrl.value),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 💰 AccountPageSkeleton
// ══════════════════════════════════════════════
class AccountPageSkeleton extends StatelessWidget {
  const AccountPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ShimmerBox(width: 90, height: 12, progress: p),
                const SizedBox(height: 10),
                ShimmerBox(width: 180, height: 26, progress: p),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(
                          width: double.infinity, height: 14, progress: p),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(
                          width: double.infinity, height: 14, progress: p),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                      width: double.infinity,
                      height: 54,
                      progress: p,
                      radius: 10),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShimmerBox(
                      width: double.infinity,
                      height: 54,
                      progress: p,
                      radius: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, __) => _sessionCard(p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(double p) {
    return Card(
      color: Colors.brown.shade50,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                // ✅ badge ວັນທີ ສີນ້ຳຕານ ຄ້າຍຂອງຈິງ
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerBox(width: 50, height: 10, progress: p, radius: 3),
                      const SizedBox(height: 3),
                      ShimmerBox(width: 40, height: 8, progress: p, radius: 3),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 60, height: 12, progress: p),
                      const SizedBox(height: 6),
                      ShimmerBox(width: 90, height: 10, progress: p),
                    ],
                  ),
                ),
                ShimmerBox(width: 26, height: 16, progress: p, radius: 8),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 24, progress: p),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 24, progress: p),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 24, progress: p),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 📊 SalesSummarySkeleton
// ══════════════════════════════════════════════
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
          Row(
            children: [
              Expanded(child: _tile(p)),
              const SizedBox(width: 8),
              Expanded(child: _tile(p)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _tile(p)),
              const SizedBox(width: 8),
              Expanded(child: _tile(p)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _tile(p)),
              const SizedBox(width: 8),
              Expanded(child: _tile(p)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _tile(p)),
              const SizedBox(width: 8),
              Expanded(child: _tile(p)),
            ],
          ),
          const SizedBox(height: 16),
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

// ══════════════════════════════════════════════
// 🔔 NotificationSkeleton
// ══════════════════════════════════════════════
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

// ══════════════════════════════════════════════
// 👤 ProfileSkeleton
// ══════════════════════════════════════════════
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
                      ShimmerBox(width: 70, height: 18, progress: p, radius: 20),
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

// ══════════════════════════════════════════════
// 🍜 RecipeListSkeleton — ຕົງກັບ RecipeCard
// ══════════════════════════════════════════════
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
                // ✅ thumb 84×84 ຕົງກັບ RecipeCard._thumb
                ShimmerBox(width: 84, height: 84, progress: p, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ຊື່ + ⋮
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
                      // badges (category + status + rating)
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
                      // ສ່ວນປະກອບ
                      ShimmerBox(
                          width: double.infinity, height: 11, progress: p),
                      const SizedBox(height: 4),
                      ShimmerBox(width: 140, height: 11, progress: p),
                      const SizedBox(height: 8),
                      // ແຖວລຸ່ມ: ເວລາ + ປຸ່ມກິນແລ້ວ
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

// ══════════════════════════════════════════════
// 🎯 Wood3DSkeleton — ຕົງກັບ Wood3DPage
// ══════════════════════════════════════════════
class Wood3DSkeleton extends StatelessWidget {
  const Wood3DSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => Container(
        color: const Color(0xFFEFEBE9),
        child: Column(
          children: [
            // ພື້ນທີ່ 3D
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
            // ພາກສ່ວນ dropdown 3 ອັນ
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