import 'dart:async';
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
  bool _isZoomed = false;
  bool _isPaused = false; // ⭐ สถานะหยุดชั่วคราว

  // ══════════════════════════════════════════
  // ⚙️ Auto-play — 8 วินาที
  // ══════════════════════════════════════════
  static const Duration _interval = Duration(seconds: 8);
  static const Duration _animDuration = Duration(milliseconds: 900);  // ⭐ นุ่มกว่า 500
  static const Curve _curve = Curves.fastOutSlowIn;   
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (_isPaused) return;
    if (_isZoomed) return;
    if (widget.imageUrls.length <= 1) return;

    _autoTimer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      if (!TickerMode.of(context)) return;
      if (!_pageController.hasClients) return;
      if (_isPaused || _isZoomed) return;

      final next = (_index + 1) % widget.imageUrls.length;
      _pageController.animateToPage(
        next,
        duration: _animDuration,
        curve: _curve,
      );
    });
  }

  void _pause() {
    _autoTimer?.cancel();
    if (!_isPaused) setState(() => _isPaused = true);
  }

  void _resume() {
    if (_isPaused) setState(() => _isPaused = false);
    _startAutoPlay();
  }

  void _togglePause() => _isPaused ? _resume() : _pause();

  @override
  void dispose() {
    _autoTimer?.cancel();
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
    _startAutoPlay();
  }

  void _onZoomChanged(bool zoomed) {
    if (_isZoomed == zoomed) return;
    setState(() => _isZoomed = zoomed);
    if (zoomed) {
      _autoTimer?.cancel();
    } else {
      _startAutoPlay();
    }
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
        title: Text(
          widget.title,
          style: const TextStyle(color: WoodStyle.white),
        ),
        iconTheme: const IconThemeData(color: WoodStyle.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: WoodGalleryViewer(
              imageUrls: urls,
              pageController: _pageController,
              currentIndex: _index,
              onPageChanged: (i) {
                setState(() => _index = i);
                _startAutoPlay();
              },
              onZoomChanged: _onZoomChanged,
              onLongPress: _pause, // ⭐ กดค้าง → หยุด
            ),
          ),

          // ── Badge ตัวเลข ──
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

          // ── ปุ่ม Play/Pause ──
          if (hasMultiple)
            Positioned(
              left: 16,
              bottom: hasMultiple ? 108 : 16,
              child: _PlayPauseButton(isPaused: _isPaused, onTap: _togglePause),
            ),

          // ── Thumbnails ──
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

// ══════════════════════════════════════════════
// ⏯️ ปุ่ม Play/Pause — โปร่งใส ไม่บังรูป
// ══════════════════════════════════════════════
class _PlayPauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPaused, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPaused
                // ignore: deprecated_member_use
                ? Colors.white.withOpacity(0.9)
                // ignore: deprecated_member_use
                : Colors.black.withOpacity(0.35),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: isPaused ? Colors.black87 : Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
