import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

class WoodGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const WoodGalleryViewer({
    super.key,
    required this.imageUrls,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<WoodGalleryViewer> createState() => _WoodGalleryViewerState();
}

class _WoodGalleryViewerState extends State<WoodGalleryViewer> {
  final TransformationController _transform = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _resetTransform() {
    _transform.value = Matrix4.identity();
    _isZoomed = false;
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransformChanged);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return PageView.builder(
      controller: widget.pageController,
      itemCount: urls.length,
      onPageChanged: (i) {
        widget.onPageChanged(i);
        _resetTransform();
      },
      itemBuilder: (context, i) {
        final isCurrent = i == widget.currentIndex;

        final imageViewer = InteractiveViewer(
          transformationController: isCurrent ? _transform : null,
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: urls[i],
              fit: BoxFit.contain,
              placeholder: (c, u) => const Center(
                child: CircularProgressIndicator(color: WoodStyle.white),
              ),
              errorWidget: (c, u, e) => const Icon(
                Icons.broken_image,
                color: WoodStyle.white,
                size: WoodStyle.galleryErrorLg,
              ),
            ),
          ),
        );

        if (!isCurrent) return imageViewer;

        return Dismissible(
          key: ValueKey('wood-viewer-$i-${urls[i]}'),
          direction: _isZoomed ? DismissDirection.none : DismissDirection.vertical,
          dismissThresholds: const {
            DismissDirection.up: 0.25,
            DismissDirection.down: 0.25,
          },
          confirmDismiss: (_) async {
            Navigator.of(context).maybePop();
            return false;
          },
          child: imageViewer,
        );
      },
    );
  }
}