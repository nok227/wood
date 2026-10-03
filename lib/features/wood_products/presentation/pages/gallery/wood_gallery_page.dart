import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WoodGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final String title;

  const WoodGalleryPage({
    super.key,
    required this.imageUrls,
    required this.title,
  });

  @override
  State<WoodGalleryPage> createState() => _WoodGalleryPageState();
}

class _WoodGalleryPageState extends State<WoodGalleryPage> {
  late final PageController _pageController;
  int _index = 0;

  final TransformationController _transform = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final hasMultiple = urls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: urls.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                _resetTransform();
              },
              itemBuilder: (context, i) {
                final isCurrent = i == _index;

                final imageViewer = InteractiveViewer(
                  transformationController: isCurrent ? _transform : null,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: urls[i],
                      fit: BoxFit.contain,
                      placeholder: (c, u) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (c, u, e) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                );

                if (!isCurrent) return imageViewer;

                return Dismissible(
                  key: ValueKey('wood-viewer-$i-${urls[i]}'),
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
                  child: imageViewer,
                );
              },
            ),
          ),
          Positioned(
            right: 16,
            bottom: hasMultiple ? 108 : 16,
            child: IgnorePointer(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_index + 1} / ${urls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          if (hasMultiple)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 100,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: urls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = i == _index;
                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: Container(
                        width: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                selected ? Colors.tealAccent : Colors.white24,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color:
                                        Colors.tealAccent.withOpacity(0.45),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: urls[i],
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (c, u, e) => const Icon(
                              Icons.broken_image,
                              size: 20,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}