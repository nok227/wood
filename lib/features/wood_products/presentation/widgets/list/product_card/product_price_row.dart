import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import 'package:wood/features/wood_products/presentation/widgets/blinking_badge.dart';

/// ══════════════════════════════════════════════
/// 💰 PRODUCT PRICE ROW — ราคา + badge "ล่าสุด"
/// ══════════════════════════════════════════════
class ProductPriceRow extends StatelessWidget {
  final WoodProduct item;
  const ProductPriceRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Align(
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
              color: AppColors.black87,
              letterSpacing: 0.3,
            ),
          ),
          AnimatedNumber(
            value: item.price,
            suffix: ' ກີບ',
            duration: 900,
            replayOnRouteChange: true,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
              letterSpacing: 0.2,
            ),
          ),
          if (item.isPriceNew) ...[
            const SizedBox(width: 5),
            Transform.translate(
              offset: const Offset(0, -8),
              child: const BlinkingBadge(
                text: 'ລ່າສຸດ',
                color: AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }
}