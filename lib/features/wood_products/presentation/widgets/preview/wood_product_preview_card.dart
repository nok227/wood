import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

// ══════════════════════════════════════════════
// 🏠 Main Card
// ══════════════════════════════════════════════
class WoodProductPreviewCard extends StatelessWidget {
  final List<String> existingImages;
  final List<File> newImages;
  final String woodType;
  final String name;
  final double width;
  final double length;
  final double thickness;
  final String sizeUnit;
  final String unit;
  final double price;
  final List<String> zones;
  final bool isEditing;
  final String note;

  const WoodProductPreviewCard({
    super.key,
    required this.existingImages,
    required this.newImages,
    required this.woodType,
    required this.name,
    required this.width,
    required this.length,
    required this.thickness,
    required this.sizeUnit,
    required this.unit,
    required this.price,
    this.zones = const [],
    this.isEditing = false,
    this.note = '',
  });

  String _fmtNum(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final totalImages = existingImages.length + newImages.length;
    final hasNote = note.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WoodStyle.green50, WoodStyle.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: WoodStyle.r16,
        border: Border.all(color: WoodStyle.green400, width: 2),
        boxShadow: [
          BoxShadow(
            color: WoodStyle.success.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          _Header(isEditing: isEditing),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── รูป ──
                if (totalImages > 0) ...[
                  _ImagesRow(
                    existingImages: existingImages,
                    newImages: newImages,
                  ),
                  const SizedBox(height: 12),
                ],

                // ── ข้อมูล ──
                _InfoRow(
                  icon: Icons.local_florist,
                  label: WoodStyle.secWoodType,
                  value: woodType.isEmpty ? WoodStyle.dash : woodType,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: WoodStyle.secName,
                  value: name.isEmpty ? WoodStyle.dash : name,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.straighten,
                  label: WoodStyle.secSize,
                  value:
                      '${_fmtNum(width)} × ${_fmtNum(length)} × ${_fmtNum(thickness)} $sizeUnit',
                ),
                const SizedBox(height: 6),

                // ── โซน ──
                _ZoneRow(zones: zones),
                const SizedBox(height: 6),

                // ── หน่วย ──
                _InfoRow(
                  icon: Icons.numbers,
                  label: WoodStyle.unitLabel,
                  value: unit.isEmpty ? WoodStyle.dash : unit,
                ),

                // ── หมายเหตุ ──
                if (hasNote) ...[
                  const SizedBox(height: 8),
                  _NoteBox(text: note.trim()),
                ],

                const SizedBox(height: 14),

                // ── ราคา ──
                _PriceBanner(price: price),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 📌 Header
// ══════════════════════════════════════════════
class _Header extends StatelessWidget {
  final bool isEditing;
  const _Header({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: WoodStyle.success,
        borderRadius: WoodStyle.r14,
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: WoodStyle.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              WoodStyle.previewTitleText,
              style: WoodStyle.previewTitle,
            ),
          ),
          if (isEditing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: WoodStyle.white.withOpacity(0.25),
                borderRadius: WoodStyle.r8,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: WoodStyle.white, size: 11),
                  SizedBox(width: 3),
                  Text(
                    WoodStyle.editBadge,
                    style: WoodStyle.previewEditBadge,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 🖼 รูปภาพ
// ══════════════════════════════════════════════
class _ImagesRow extends StatelessWidget {
  final List<String> existingImages;
  final List<File> newImages;

  const _ImagesRow({
    required this.existingImages,
    required this.newImages,
  });

  @override
  Widget build(BuildContext context) {
    final total = existingImages.length + newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 13,
              color: WoodStyle.success,
            ),
            const SizedBox(width: 5),
            Text(
              '${WoodStyle.imagesLabel} ($total)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: WoodStyle.green800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: WoodStyle.thumbPreview,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(existingImages.length, (i) {
                return _Thumb(
                  child: CachedNetworkImage(
                    imageUrl: existingImages[i],
                    fit: BoxFit.cover,
                    memCacheWidth: 120,
                    placeholder: (c, u) =>
                        const ColoredBox(color: WoodStyle.grey100),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image,
                      size: 20,
                      color: WoodStyle.grey500,
                    ),
                  ),
                );
              }),
              ...List.generate(newImages.length, (i) {
                return _Thumb(
                  child: Image.file(newImages[i], fit: BoxFit.cover),
                  isNew: true,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final Widget child;
  final bool isNew;
  const _Thumb({required this.child, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: WoodStyle.thumbPreview,
            height: WoodStyle.thumbPreview,
            decoration: BoxDecoration(
              borderRadius: WoodStyle.r8,
              border: Border.all(
                color: isNew ? WoodStyle.green400 : WoodStyle.grey300,
                width: isNew ? 2 : 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: child,
            ),
          ),
          if (isNew)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: WoodStyle.success,
                  borderRadius: WoodStyle.r4,
                ),
                child: const Text(
                  WoodStyle.newImg,
                  style: TextStyle(
                    color: WoodStyle.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 📄 Info Row
// ══════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: WoodStyle.brown400),
        const SizedBox(width: 6),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: WoodStyle.grey600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: WoodStyle.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 📍 Zone Row
// ══════════════════════════════════════════════
class _ZoneRow extends StatelessWidget {
  final List<String> zones;
  const _ZoneRow({required this.zones});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.place_outlined, size: 14, color: WoodStyle.brown400),
        const SizedBox(width: 6),
        const SizedBox(
          width: 78,
          child: Text(
            WoodStyle.secZone,
            style: TextStyle(fontSize: 12, color: WoodStyle.grey600),
          ),
        ),
        Expanded(
          child: zones.isEmpty
              ? const Text(
                  WoodStyle.notSpecified,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: WoodStyle.grey500,
                  ),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: zones.map((z) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: WoodStyle.green50,
                        borderRadius: WoodStyle.r5,
                        border: Border.all(color: WoodStyle.green400),
                      ),
                      child: Text(
                        z,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: WoodStyle.green800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 📝 Note Box
// ══════════════════════════════════════════════
class _NoteBox extends StatelessWidget {
  final String text;
  const _NoteBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: WoodStyle.padCard,
      decoration: BoxDecoration(
        color: WoodStyle.amber50,
        borderRadius: WoodStyle.r8,
        border: Border.all(color: WoodStyle.amber300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 14,
                color: WoodStyle.amber900,
              ),
              SizedBox(width: 5),
              Text(
                WoodStyle.note,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: WoodStyle.amber900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: WoodStyle.brown900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 💰 Price Banner
// ══════════════════════════════════════════════
class _PriceBanner extends StatelessWidget {
  final double price;
  const _PriceBanner({required this.price});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WoodStyle.success, WoodStyle.green600],
        ),
        borderRadius: WoodStyle.r10,
        boxShadow: [
          BoxShadow(
            color: WoodStyle.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.sell, color: WoodStyle.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              WoodStyle.priceLabelFull,
              style: TextStyle(
                color: WoodStyle.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${fmt.format(price)} ${WoodStyle.currency}',
            style: const TextStyle(
              color: WoodStyle.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}