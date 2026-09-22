import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WoodGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final String title;

  const WoodGalleryPage({super.key, required this.imageUrls, required this.title});

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
    _pageController.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // รูปหลัก + ตัวนับ X / Y มุมล่างขวา
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: urls.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: urls[i],
                        fit: BoxFit.contain,
                        placeholder: (c, u) => const CircularProgressIndicator(color: Colors.white),
                        errorWidget: (c, u, e) =>
                            const Icon(Icons.broken_image, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              ],
            ),
          ),

          // แถบรูปย่อด้านล่าง — กดรูปไหนเปลี่ยนไปรูปนั้น
          if (urls.length > 1)
            Container(
              height: 90,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = i == _index;
                  return GestureDetector(
                    onTap: () => _goTo(i),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? Colors.teal : Colors.transparent, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: urls[i],
                          fit: BoxFit.cover,
                          placeholder: (c, u) => const Center(
                            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (c, u, e) => const Icon(Icons.broken_image, size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
