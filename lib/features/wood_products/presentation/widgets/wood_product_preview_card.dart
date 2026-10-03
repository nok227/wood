import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

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
    final fmt = NumberFormat('#,###');
    final totalImages = existingImages.length + newImages.length;
    final hasNote = note.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ກວດເບິ່ງຂໍ້ມູນກ່ອນບັນທຶກ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text(
                          'ແກ້ໄຂ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (totalImages > 0) ...[
                  _label(Icons.photo_library_outlined,
                      'ຮູບພາບ ($totalImages)'),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...List.generate(existingImages.length, (i) {
                          return _thumb(
                            child: CachedNetworkImage(
                              imageUrl: existingImages[i],
                              fit: BoxFit.cover,
                              memCacheWidth: 120,
                              placeholder: (c, u) => Container(
                                  color: Colors.grey.shade100),
                              errorWidget: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: Colors.grey),
                            ),
                          );
                        }),
                        ...List.generate(newImages.length, (i) {
                          return _thumb(
                            child: Image.file(newImages[i],
                                fit: BoxFit.cover),
                            isNew: true,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _row(Icons.local_florist, 'ຊະນິດໄມ້',
                    woodType.isEmpty ? '-' : woodType),
                const SizedBox(height: 6),
                _row(Icons.inventory_2_outlined, 'ຊື່ໄມ້',
                    name.isEmpty ? '-' : name),
                const SizedBox(height: 6),
                _row(
                  Icons.straighten,
                  'ຂະໜາດ',
                  '${_fmtNum(width)} × ${_fmtNum(length)} × ${_fmtNum(thickness)} $sizeUnit',
                ),
                const SizedBox(height: 6),
                _zoneRow(zones),
                const SizedBox(height: 6),
                _row(Icons.numbers, 'ໜ່ວຍນັບ',
                    unit.isEmpty ? '-' : unit),
                if (hasNote) ...[
                  const SizedBox(height: 8),
                  _noteBox(note.trim()),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade700,
                        Colors.green.shade600
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sell,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'ລາຄາຂາຍ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${fmt.format(price)} ກີບ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
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

  Widget _noteBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  size: 14, color: Colors.amber.shade900),
              const SizedBox(width: 5),
              Text(
                'ໝາຍເຫດ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.brown.shade900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneRow(List<String> zones) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_outlined,
            size: 14, color: Colors.brown.shade400),
        const SizedBox(width: 6),
        SizedBox(
          width: 78,
          child: Text(
            'ໂຊນ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: zones.isEmpty
              ? Text(
                  'ບໍ່ລະບຸ',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                  ),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: zones
                      .map(
                        (z) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.green.shade400),
                          ),
                          child: Text(
                            z,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _label(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.green.shade700),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.brown.shade400),
        const SizedBox(width: 6),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _thumb({required Widget child, bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isNew
                    ? Colors.green.shade400
                    : Colors.grey.shade300,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ໃໝ່',
                  style: TextStyle(
                    color: Colors.white,
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