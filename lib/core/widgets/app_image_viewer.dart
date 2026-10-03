import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transform.addListener(_onTransform);
  }

  void _onTransform() {
    final z = _transform.value.getMaxScaleOnAxis() > 1.05;
    if (z != _isZoomed && mounted) setState(() => _isZoomed = z);
  }

  void _reset() {
    _transform.value = Matrix4.identity();
    _isZoomed = false;
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(current.label ?? ''),
        actions: [
          if (total > 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('${_index + 1}/$total',
                    style: const TextStyle(color: Colors.white70)),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: total,
        onPageChanged: (i) {
          setState(() => _index = i);
          _reset();
        },
        itemBuilder: (_, i) {
          final isCurrent = i == _index;
          final viewer = InteractiveViewer(
            transformationController: isCurrent ? _transform : null,
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[i].url,
                fit: BoxFit.contain,
                placeholder: (c, u) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          );

          if (!isCurrent) return viewer;
          if (!widget.closeOnSwipe) return viewer;

          return Dismissible(
            key: ValueKey('viewer-${widget.images[i].url}'),
            direction: _isZoomed
                ? DismissDirection.none
                : DismissDirection.vertical,
            dismissThresholds: const {
              DismissDirection.up: 0.25,
              DismissDirection.down: 0.25,
            },
            confirmDismiss: (_) async {
              Navigator.of(context).maybePop();
              return false;
            },
            child: viewer,
          );
        },
      ),
    );
  }
}