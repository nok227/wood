import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SaleImageItem {
  final String url;
  final String label;
  const SaleImageItem(this.url, this.label);
}

/// 🖼️ ເບິ່ງຮູບເຕັມຈໍ:
/// - ຢຸ່ມນິ້ວ/ບີບ ເພື່ອຊູມ
/// - ປັດຊ້າຍ-ຂວາ ເພື່ອປ່ຽນຮູບ
/// - 🆕 ປັດຂຶ້ນ-ລົງ ເພື່ອອອກ (swipe up/down to close)
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

  // 🎯 ຕິດຕາມການຊູມ — ຖ້າຊູມຢູ່ ຈະບໍ່ໃຫ້ປັດອອກ
  final TransformationController _transform = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
                child: Text(
                  '${_index + 1}/$total',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: total,
        onPageChanged: (i) {
          setState(() => _index = i);
          _resetTransform();
        },
        itemBuilder: (_, i) {
          final isCurrent = i == _index;

          final imageViewer = InteractiveViewer(
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

          // 🎯 ຮູບທີ່ສະແດງຢູ່ → ຫຸ້ມ Dismissible ສຳລັບປັດຂຶ້ນ-ລົງອອກ
          if (!isCurrent) return imageViewer;

          return Dismissible(
            key: ValueKey('viewer-${widget.images[i].url}'),
            // ຖ້າຊູມຢູ່ → ປິດການປັດອອກ (ເພື່ອໃຫ້ແພນຮູບໄດ້)
            direction: _isZoomed
                ? DismissDirection.none
                : DismissDirection.vertical,
            // ✅ ປັດພຽງໜ້ອຍກໍ່ອອກ (threshold 25%)
            dismissThresholds: const {
              DismissDirection.up: 0.25,
              DismissDirection.down: 0.25,
            },
            // ✅ ອອກທັນທີທີ່ຮອດ threshold — ບໍ່ຕ້ອງ animate ໄປໝົດຈໍ
            confirmDismiss: (_) async {
              Navigator.of(context).maybePop();
              return false;
            },
            child: imageViewer,
          );
        },
      ),
    );
  }
}