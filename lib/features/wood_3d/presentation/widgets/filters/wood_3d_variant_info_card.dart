import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/wood_3d_style.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';

class Wood3DVariantInfoCard extends StatelessWidget {
  final WoodProduct variant;
  final List<WoodProduct> variants;
  final ValueChanged<WoodProduct?> onVariantChanged;

  const Wood3DVariantInfoCard({
    super.key,
    required this.variant,
    required this.variants,
    required this.onVariantChanged,
  });

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  String _fmtPrice(num v) {
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = variant;

    return Container(
      padding: Wood3DStyle.padCard,
      decoration: BoxDecoration(
        color: Wood3DStyle.brown50,
        borderRadius: Wood3DStyle.r12,
        border: Border.all(color: Wood3DStyle.brown200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                Wood3DStyle.sizeLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Wood3DStyle.gap8,
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WoodProduct>(
                    value: v,
                    isExpanded: true,
                    isDense: true,
                    items: variants
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${_fmt(item.width)}×${_fmt(item.length)}×${_fmt(item.thickness)} ${item.sizeUnit}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onVariantChanged,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                Wood3DStyle.priceLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Text(
                '${_fmtPrice(v.price)} ${Wood3DStyle.currency}',
                style: Wood3DStyle.txInfoPrice,
              ),
            ],
          ),
          Wood3DStyle.gap4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                Wood3DStyle.qtyLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Text('${v.quantity} ${v.unit}',
                  style: Wood3DStyle.txInfoQty),
            ],
          ),
          if (v.zones.isNotEmpty) ...[
            Wood3DStyle.gap6,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  Wood3DStyle.zoneLabelColon,
                  style: Wood3DStyle.txInfoLabel,
                ),
                Wood3DStyle.gap8,
                Expanded(
                  child: Wrap(
                    spacing: Wood3DStyle.wrapSpacing,
                    runSpacing: Wood3DStyle.wrapRunSpacing,
                    children: v.zones
                        .map(
                          (z) => Container(
                            padding: Wood3DStyle.padZoneChip,
                            decoration: BoxDecoration(
                              color: Wood3DStyle.white,
                              borderRadius: Wood3DStyle.r4,
                              border: Border.all(
                                color: Wood3DStyle.brown200,
                              ),
                            ),
                            child: Text(z, style: Wood3DStyle.txZone),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}