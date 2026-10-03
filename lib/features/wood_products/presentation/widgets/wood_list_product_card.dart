import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/widgets/blinking_badge.dart';
import 'package:wood/core/widgets/animated_number.dart';
import 'package:wood/core/utils/dimension_utils.dart';
import '../../data/models/wood_product_model.dart';

class WoodListProductCard extends StatelessWidget {
  final WoodProductModel item;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onImageTap;

  const WoodListProductCard({
    super.key,
    required this.item,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
    required this.onImageTap,
  });

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SwipeableImage(
            imageUrls: item.imageUrls,
            width: 72,
            height: 148,
            onTap: item.imageUrls.isEmpty ? null : onImageTap,
          ),
          const SizedBox(width: 10),
          Expanded(child: SizedBox(height: 148, child: _info())),
          if (isAdmin)
            SizedBox(
              width: 28,
              height: 28,
              child: PopupMenuButton<int>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert,
                    size: 18, color: Colors.grey.shade600),
                onSelected: (v) {
                  if (v == 1) {
                    onEdit();
                  } else if (v == 2) {
                    onDelete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('ແກ້ໄຂ'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('ລຶບ', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _info() {
    final hasNote = item.note.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'ຂະໜາດ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasNote) ...[
                  const SizedBox(width: 5),
                  Tooltip(
                    message: item.note.trim(),
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sticky_note_2_outlined,
                              size: 9, color: Colors.amber.shade900),
                          const SizedBox(width: 2),
                          Text(
                            'ໝາຍເຫດ',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 1),
            Text(
              '${_fmt(item.width)} × ${_fmt(item.length)} × ${_fmt(item.thickness)} ${item.sizeUnit}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            _conversionColumn(),
            const SizedBox(height: 4),
            _zoneLine(),
            const SizedBox(height: 5),
            const Text(
              'ຈຳນວນ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${item.quantity} ${item.unit}',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'ລາຄາ: ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              AnimatedNumber(
                value: item.price,
                suffix: ' ກີບ',
                duration: 900,
                replayOnRouteChange: true,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade700,
                  letterSpacing: 0.2,
                ),
              ),
              if (item.isPriceNew) ...[
                const SizedBox(width: 5),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: BlinkingBadge(
                    text: 'ລ່າສຸດ',
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _conversionColumn() {
    final conversions = dimConversions(
      item.width,
      item.length,
      item.thickness,
      item.sizeUnit,
    ).split('·').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (conversions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: conversions.map((line) {
        return Text(
          line,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }).toList(),
    );
  }

  Widget _zoneLine() {
    if (item.zones.isEmpty) {
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'ໂຊນ: ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: 'ບໍ່ລະບຸ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final displayZones = item.zones.take(4).toList();
    final remaining = item.zones.length - displayZones.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'ໂຊນ: ',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...displayZones.map(
                (z) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.brown.shade200),
                  ),
                  child: Text(
                    z,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
              ),
              if (remaining > 0)
                Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.brown.shade400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 🖼️ ຮູບທີ່ປັດໄດ້ (Swipeable)
// ══════════════════════════════════════════════
class _SwipeableImage extends StatefulWidget {
  final List<String> imageUrls;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _SwipeableImage({
    required this.imageUrls,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<_SwipeableImage> createState() => _SwipeableImageState();
}

class _SwipeableImageState extends State<_SwipeableImage> {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ),
        ),
      );
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            PageView.builder(
              key: ValueKey('pv-${widget.imageUrls.first}'),
              controller: _pageCtrl,
              physics: const PageScrollPhysics(),
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[i],
                  fit: BoxFit.contain,
                  memCacheWidth: 216,
                  placeholder: (c, u) => const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  errorWidget: (c, u, e) => Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ),
              ),
            ),
            if (hasMultiple)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.imageUrls.length, (i) {
                      final active = _current == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: active ? 6 : 4,
                        height: active ? 6 : 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.brown.shade700
                              : Colors.white.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            if (hasMultiple)
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_current + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}