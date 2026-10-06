import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/sale_style.dart';

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
    duration: SaleStyle.skelPulse,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: SaleStyle.padListFAB,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.count,
      itemBuilder: (_, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final t = SaleStyle.skelPulseMin +
              _ctrl.value * (SaleStyle.skelPulseMax - SaleStyle.skelPulseMin);
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
        color: SaleStyle.white,
        borderRadius: BorderRadius.circular(SaleStyle.skelCardRadius),
        boxShadow: [
          BoxShadow(
            color: SaleStyle.black.withOpacity(SaleStyle.skelShadowOpacity),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SaleStyle.skelCardPad),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Column(
                children: [
                  _Box(w: SaleStyle.thumbMiniW, h: SaleStyle.thumbMiniH),
                  SizedBox(height: SaleStyle.skelGap4),
                  _Box(w: SaleStyle.thumbMiniW, h: SaleStyle.thumbMiniH),
                  SizedBox(height: SaleStyle.skelGap4),
                  _Box(w: SaleStyle.thumbMiniW, h: SaleStyle.thumbMiniH),
                ],
              ),
              SaleStyle.gap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Box(w: double.infinity, h: SaleStyle.skelBarH14),
                    SaleStyle.gap4,
                    const _Box(w: SaleStyle.skelBarW160, h: SaleStyle.skelBarH11),
                    SaleStyle.gap4,
                    const _Box(w: SaleStyle.skelBarW140, h: SaleStyle.skelBarH11),
                    SaleStyle.gap6,
                    const _Box(w: SaleStyle.skelBarW110, h: SaleStyle.skelBarH11),
                    SaleStyle.gap6,
                    const _Box(w: SaleStyle.skelBarW130, h: SaleStyle.skelBarH15),
                    SaleStyle.gap4,
                    const _Box(w: SaleStyle.skelBarW80, h: SaleStyle.skelBarH11),
                    SaleStyle.gap4,
                    const _Box(w: SaleStyle.skelBarW130, h: SaleStyle.skelBarH10),
                    SaleStyle.gap6,
                    const _Box(w: SaleStyle.skelBarW120, h: SaleStyle.skelBarH13),
                    SaleStyle.gap6,
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: SaleStyle.grey50,
                        borderRadius: BorderRadius.circular(SaleStyle.skelBtnRadius),
                        border: Border.all(
                          color: SaleStyle.grey300,
                          width: SaleStyle.borderW1_0,
                        ),
                      ),
                      child: const Center(
                        child: _Box(w: SaleStyle.skelBarW140, h: SaleStyle.skelBarH13),
                      ),
                    ),
                  ],
                ),
              ),
              SaleStyle.gap4,
              const _Box(w: 28, h: 28, radius: SaleStyle.skelBoxRadius),
            ],
          ),
        ),
      ),
    );
  }
}

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
        color: color ?? SaleStyle.grey200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}