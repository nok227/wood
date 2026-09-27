import 'package:flutter/material.dart';

/// 🦴 Skeleton ສຳລັບໜ້າລາຍການຂາຍ
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
      itemCount: widget.count,
      itemBuilder: (_, i) => _buildCard(),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        // 🌊 Shimmer effect — ສີປ່ຽນ 0.5 → 1.0
        final t = 0.5 + _ctrl.value * 0.5;
        return Opacity(opacity: t, child: child);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 2 ຮູບຈຳລອງ ──
              Column(
                children: [
                  _box(76, 76),
                  const SizedBox(height: 8),
                  _box(76, 76),
                ],
              ),
              const SizedBox(width: 12),

              // ── ຂໍ້ມູນຈຳລອງ ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(double.infinity, 14), // ຊື່ສິນຄ້າ
                    const SizedBox(height: 6),
                    _box(80, 12), // ຈຳນວນ
                    const SizedBox(height: 6),
                    _box(130, 16), // ລາຄາ
                    const SizedBox(height: 6),
                    _box(100, 12), // ວິທີ
                    const SizedBox(height: 4),
                    _box(120, 10), // ວັນທີ
                    const SizedBox(height: 10),
                    _box(140, 22), // badge
                    const SizedBox(height: 8),
                    _box(double.infinity, 32), // status button
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}