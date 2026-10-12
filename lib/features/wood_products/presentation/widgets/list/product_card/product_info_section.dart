import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/utils/dimension_utils.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';


/// ══════════════════════════════════════════════
/// 📋 PRODUCT INFO — ข้อมูลไม้ (ขนาด, โซน, จำนวน)
/// ══════════════════════════════════════════════
class ProductInfoSection extends StatelessWidget {
  final WoodProduct item;
  const ProductInfoSection({super.key, required this.item});

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sizeHeader(),
        const SizedBox(height: 1),
        Text(
          '${_fmt(item.width)} × ${_fmt(item.length)} × ${_fmt(item.thickness)} ${item.sizeUnit}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
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
            color: AppColors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '${item.quantity} ${item.unit}',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.black87,
          ),
        ),
      ],
    );
  }

  Widget _sizeHeader() {
    final hasNote = item.note.trim().isNotEmpty;
    return Row(
      children: [
        const Text(
          'ຂະໜາດ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.black87,
            letterSpacing: 0.5,
          ),
        ),
        if (hasNote) ...[
          const SizedBox(width: 5),
          _NoteBadge(note: item.note.trim()),
        ],
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
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.grey600,
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
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'ໂຊນ: ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.black87,
              ),
            ),
            TextSpan(
              text: 'ບໍ່ລະບຸ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.grey500,
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
        const Text(
          'ໂຊນ: ',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.black87,
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...displayZones.map((z) => _ZoneChip(label: z)),
              if (remaining > 0)
                Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown400,
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
// 🏷️ Zone chip
// ══════════════════════════════════════════════
class _ZoneChip extends StatelessWidget {
  final String label;
  const _ZoneChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.brown50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.brown200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: AppColors.brown800,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 📝 Note badge
// ══════════════════════════════════════════════
class _NoteBadge extends StatelessWidget {
  final String note;
  const _NoteBadge({required this.note});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: note,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.amber100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.amber400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined,
                size: 9, color: AppColors.amber900),
            const SizedBox(width: 2),
            Text(
              'ໝາຍເຫດ',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: AppColors.amber900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}