import 'package:flutter/material.dart';
import 'package:wood/core/widgets/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/skeletons/shimmer_host.dart';

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
            child: Column(children: [
              ShimmerBox(width: 90, height: 12, progress: p),
              const SizedBox(height: 10),
              ShimmerBox(width: 180, height: 26, progress: p),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 14, progress: p)),
                const SizedBox(width: 8),
                Expanded(child: ShimmerBox(width: double.infinity, height: 14, progress: p)),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            child: Row(children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 54, progress: p, radius: 10)),
              const SizedBox(width: 8),
              Expanded(child: ShimmerBox(width: double.infinity, height: 54, progress: p, radius: 10)),
            ]),
          ),
          const SizedBox(height: 6),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (_, __) => _sessionCard(p),
          )),
        ],
      ),
    );
  }

  Widget _sessionCard(double p) => Card(
    color: Colors.brown.shade50,
    margin: const EdgeInsets.only(top: 8, bottom: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ShimmerBox(width: 50, height: 10, progress: p, radius: 3),
              const SizedBox(height: 3),
              ShimmerBox(width: 40, height: 8, progress: p, radius: 3),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 60, height: 12, progress: p),
              const SizedBox(height: 6),
              ShimmerBox(width: 90, height: 10, progress: p),
            ],
          )),
          ShimmerBox(width: 26, height: 16, progress: p, radius: 8),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ShimmerBox(width: double.infinity, height: 24, progress: p)),
          const SizedBox(width: 6),
          Expanded(child: ShimmerBox(width: double.infinity, height: 24, progress: p)),
          const SizedBox(width: 6),
          Expanded(child: ShimmerBox(width: double.infinity, height: 24, progress: p)),
        ]),
      ]),
    ),
  );
}