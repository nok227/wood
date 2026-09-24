import 'package:flutter/material.dart';

class SaleImageItem {
  final String url;
  final String label;
  const SaleImageItem(this.url, this.label);
}

/// 🖼️ ເບິ່ງຮູບເຕັມຈໍ: ຢຸ່ມນິ້ວ/ບີບເພື່ອຊູມ, ປັດຊ້າຍ-ຂວາເພື່ອປ່ຽນຮູບ
class SaleImageViewer extends StatefulWidget {
  final List<SaleImageItem> images;
  final int initialIndex;

  const SaleImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<SaleImageViewer> createState() => _SaleImageViewerState();
}

class _SaleImageViewerState extends State<SaleImageViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.images[_index].label),
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
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Image.network(
                widget.images[i].url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}