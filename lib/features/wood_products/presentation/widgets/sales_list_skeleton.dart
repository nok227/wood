import 'package:flutter/material.dart';

/// 🦴 Skeleton ສຳລັບໜ້າລາຍການຂາຍ — ຕົງກັບ SaleCard ຈິງ
class SalesListSkeleton extends StatefulWidget {
  const SalesListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  State<SalesListSkeleton> createState() => _SalesListSkeletonState();
}

class _SalesListSkeletonState extends State<SalesListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.count,
      itemBuilder: (_, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final t = 0.5 + _ctrl.value * 0.5;
          return Opacity(opacity: t, child: child);
        },
        child: const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 3 ຮູບ 76×76 ──
              const Column(
                children: [
                  _Box(w: 76, h: 76),
                  SizedBox(height: 4),
                  _Box(w: 76, h: 76),
                  SizedBox(height: 4),
                  _Box(w: 76, h: 76),
                ],
              ),
              const SizedBox(width: 10),

              // ── ຂໍ້ມູນ ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ຊື່ / summary
                    const _Box(w: double.infinity, h: 14),
                    const SizedBox(height: 4),

                    // ລາຍການຍ່ອຍ (2 ແຖວ)
                    const _Box(w: 160, h: 11),
                    const SizedBox(height: 4),
                    const _Box(w: 140, h: 11),
                    const SizedBox(height: 6),

                    // ຈຳນວນ
                    const _Box(w: 110, h: 11),
                    const SizedBox(height: 6),

                    // ລວມ
                    const _Box(w: 130, h: 15),
                    const SizedBox(height: 4),

                    // ວິທີ
                    const _Box(w: 80, h: 11),
                    const SizedBox(height: 4),

                    // ວັນທີ
                    const _Box(w: 130, h: 10),
                    const SizedBox(height: 6),

                    // payment badge
                    const _Box(w: 120, h: 13),
                    const SizedBox(height: 6),

                    // ✅ Spacer → ດັນປຸ່ມລົງລຸ່ມ
                    const Spacer(),

                    // ປຸ່ມສະຖານະ (border, ບໍ່ shimmer — ສີຄ້າຍຈິງ)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      child: const Center(
                        child: _Box(w: 140, h: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Admin menu (⋮) ──
              const SizedBox(width: 4),
              const _Box(w: 28, h: 28, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ✨ Shimmer Box Helper
// ══════════════════════════════════════════════
class _Box extends StatelessWidget {
  final double w;
  final double h;
  final double radius;
  final Color? color;

  const _Box({
    required this.w,
    required this.h,
    this.radius = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}