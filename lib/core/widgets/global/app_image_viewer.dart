import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AppImageItem {
  final String url;
  final String? label;
  const AppImageItem(this.url, {this.label});
}

class AppImageViewer extends StatefulWidget {
  final List<AppImageItem> images;
  final int initialIndex;
  final bool closeOnSwipe;

  const AppImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.closeOnSwipe = true,
  });

  factory AppImageViewer.urls({
    Key? key,
    required List<String> urls,
    List<String>? labels,
    int initialIndex = 0,
  }) {
    return AppImageViewer(
      key: key,
      initialIndex: initialIndex,
      images: [
        for (int i = 0; i < urls.length; i++)
          AppImageItem(
            urls[i],
            label: (labels != null && i < labels.length) ? labels[i] : null,
          ),
      ],
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  late final PageController _pageController;
  late int _index;
  final TransformationController _transform = TransformationController();
  bool _isZoomed = false;

  // ⭐ ສຳລັບ double-tap zoom ຕາມຈຸດທີ່ແຕະ
  TapDownDetails? _doubleTapDetails;

  // ⭐ ສຳລັບ swipe-to-close
  double? _downY;
  double? _downX;
  static const double _minSwipe = 80;
  static const double _hRatio = 1.3;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transform.addListener(_onTransform);
  }

  void _onTransform() {
    final z = _transform.value.getMaxScaleOnAxis() > 1.05;
    if (z != _isZoomed && mounted) {
      setState(() => _isZoomed = z);
    }
  }

  void _reset() {
    _transform.value = Matrix4.identity();
    _isZoomed = false;
  }

  /// ⭐ Double-tap → zoom 2.5x ຕາມຈຸດທີ່ແຕະ ຫຼື reset
  void _handleDoubleTap() {
    final details = _doubleTapDetails;
    if (details == null) {
      _reset();
      return;
    }

    if (_isZoomed) {
      _reset();
    } else {
      final pos = details.localPosition;
      const scale = 2.5;
      final x = -pos.dx * (scale - 1);
      final y = -pos.dy * (scale - 1);
      _transform.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }
  }

  /// ⭐ ຈັບ swipe ດ້ວຍ Listener (ບໍ່ແຍ່ງ gesture ກັບ InteractiveViewer)
  void _onPointerDown(PointerDownEvent e) {
    _downX = e.position.dx;
    _downY = e.position.dy;
  }

  void _onPointerUp(PointerUpEvent e) {
    final dx0 = _downX;
    final dy0 = _downY;
    _downX = null;
    _downY = null;

    if (!widget.closeOnSwipe || _isZoomed) return;
    if (dx0 == null || dy0 == null) return;

    final dx = e.position.dx - dx0;
    final dy = e.position.dy - dy0;

    if (dy.abs() < _minSwipe) return;
    if (dy.abs() < dx.abs() * _hRatio) return;

    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;
    final current = widget.images[_index];

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: Text(current.label ?? ''),
        actions: [
          if (total > 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_index + 1}/$total',
                  style: const TextStyle(color: AppColors.white70),
                ),
              ),
            ),
        ],
      ),
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        child: PageView.builder(
          controller: _pageController,
          // ⭐ ຢຸດປັດໜ້າ ເມື່ອ zoom ຢູ່
          physics: _isZoomed
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          itemCount: total,
          onPageChanged: (i) {
            setState(() => _index = i);
            _reset();
          },
          itemBuilder: (_, i) {
            final isCurrent = i == _index;

            // ⭐ InteractiveViewer ຢູ່ໃນ GestureDetector ທີ່ຈັບ double-tap
            return GestureDetector(
              onDoubleTapDown: isCurrent
                  ? (d) => _doubleTapDetails = d
                  : null,
              onDoubleTap: isCurrent ? _handleDoubleTap : null,
              child: InteractiveViewer(
                transformationController: isCurrent ? _transform : null,
                minScale: 1,
                maxScale: 5,
                panEnabled: true,
                scaleEnabled: true,
                clipBehavior: Clip.none,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i].url,
                    fit: BoxFit.contain,
                    placeholder: (c, u) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image,
                      size: 64,
                      color: AppColors.white54,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}