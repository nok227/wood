import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import '../../widgets/gallery/wood_gallery_viewer.dart';
import '../../widgets/gallery/wood_gallery_thumbnails.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
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
            child: WoodGalleryViewer(
              imageUrls: urls,
              pageController: _pageController,
              currentIndex: _index,
              onPageChanged: (i) => setState(() => _index = i),
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
                  style: const TextStyle(color: WoodStyle.white, fontSize: 13),
                ),
              ),
            ),
          ),
          if (hasMultiple)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: WoodGalleryThumbnails(
                imageUrls: urls,
                currentIndex: _index,
                onTap: _goTo,
              ),
            ),
        ],
      ),
    );
  }
}