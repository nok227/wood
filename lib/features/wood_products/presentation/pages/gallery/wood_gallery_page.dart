import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

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
      duration: WoodStyle.galleryAnim,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final hasMultiple = urls.length > 1;

    return Scaffold(
      backgroundColor: WoodStyle.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: WoodStyle.transparent,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: WoodStyle.white)),
        iconTheme: const IconThemeData(color: WoodStyle.white),
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
                padding: WoodStyle.padGalleryBadge,
                decoration: const BoxDecoration(
                  color: WoodStyle.black54,
                  borderRadius: WoodStyle.galleryBadgeR,
                ),
                child: Text(
                  '${_index + 1} / ${urls.length}',
                  style: const TextStyle(
                    color: WoodStyle.white,
                    fontSize: 13,
                  ),
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
                height: WoodStyle.galleryHeight,
                padding: WoodStyle.padGallery,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      WoodStyle.black.withOpacity(0.0),
                      WoodStyle.black
                          .withOpacity(WoodStyle.opacityGradientEnd),
                    ],
                  ),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: urls.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: WoodStyle.galleryGap),
                  itemBuilder: (context, i) {
                    final selected = i == _index;
                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: Container(
                        width: WoodStyle.galleryThumbW,
                        decoration: BoxDecoration(
                          borderRadius: WoodStyle.galleryThumbR,
                          border: Border.all(
                            color: selected
                                ? WoodStyle.tealAccent
                                : WoodStyle.white24,
                            width: WoodStyle.borderW2_0,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: WoodStyle.tealAccent.withOpacity(
                                        WoodStyle.opacityGlow),
                                    blurRadius: WoodStyle.galleryGlowBlur,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: WoodStyle.galleryThumbRSm,
                          child: CachedNetworkImage(
                            imageUrl: urls[i],
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Center(
                              child: SizedBox(
                                width: WoodStyle.galleryPlaceholderSize,
                                height: WoodStyle.galleryPlaceholderSize,
                                child: CircularProgressIndicator(
                                  strokeWidth:
                                      WoodStyle.galleryPlaceholderStroke,
                                ),
                              ),
                            ),
                            errorWidget: (c, u, e) => const Icon(
                              Icons.broken_image,
                              size: WoodStyle.galleryErrorSm,
                              color: WoodStyle.white54,
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