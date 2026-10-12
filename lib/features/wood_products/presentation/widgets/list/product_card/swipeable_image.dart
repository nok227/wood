import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class SwipeableImage extends StatefulWidget {
  final List<String> imageUrls;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const SwipeableImage({
    super.key,
    required this.imageUrls,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<SwipeableImage> createState() => _SwipeableImageState();
}

class _SwipeableImageState extends State<SwipeableImage> {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  static const Duration _interval = Duration(seconds: 3);
  static const Duration _animDuration = Duration(milliseconds: 700);
  static const Curve _curve = Curves.fastOutSlowIn;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (widget.imageUrls.length <= 1) return;

    _autoTimer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      if (!TickerMode.of(context)) return;
      if (!_pageCtrl.hasClients) return;

      final next = (_current + 1) % widget.imageUrls.length;
      _pageCtrl.animateToPage(
        next,
        duration: _animDuration,
        curve: _curve,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _emptyBox();
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            PageView.builder(
              key: ValueKey('pv-${widget.imageUrls.first}'),
              controller: _pageCtrl,
              physics: const PageScrollPhysics(),
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) {
                setState(() => _current = i);
                _startAutoPlay();
              },
              itemBuilder: (_, i) {
                // ⭐ เช็ค positions.length == 1 ก่อนอ่าน .position
                //    กัน "ScrollController attached to multiple scroll views"
                final hasSingleClient = _pageCtrl.positions.length == 1;
                final page = (hasSingleClient &&
                        _pageCtrl.position.haveDimensions)
                    ? _pageCtrl.page ?? _current.toDouble()
                    : _current.toDouble();
                final distance = (i - page).abs().clamp(0.0, 1.0);

                return Opacity(
                  opacity: 1 - (distance * 0.15),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrls[i],
                      fit: BoxFit.contain,
                      memCacheWidth: 216,
                      fadeInDuration: const Duration(milliseconds: 400),
                      fadeOutDuration: const Duration(milliseconds: 400),
                      placeholder: (c, u) => Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (c, u, e) => const Icon(
                        Icons.broken_image,
                        color: AppColors.grey400,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (hasMultiple) _dots(),
            if (hasMultiple) _badge(),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox() {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.grey100,
          child: const Icon(
            Icons.image_not_supported,
            color: AppColors.grey400,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 4,
      child: IgnorePointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageUrls.length, (i) {
            final active = _current == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.fastOutSlowIn,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: active ? 6 : 4,
              height: active ? 6 : 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppColors.primary
                    : AppColors.white.withValues(alpha: 0.85),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.25),
                    blurRadius: 2,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _badge() {
    return Positioned(
      top: 4,
      right: 4,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_current + 1}/${widget.imageUrls.length}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}