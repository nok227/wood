import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import '../../../domain/entities/wood_product.dart';
import 'product_card/swipeable_image.dart';
import 'product_card/product_info_section.dart';
import 'product_card/product_price_row.dart';

class WoodListProductCard extends StatelessWidget {
  final WoodProduct item;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwipeableImage(
            imageUrls: item.imageUrls,
            width: 83, 
            height: 148,
            onTap: item.imageUrls.isEmpty ? null : onImageTap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 148,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProductInfoSection(item: item),
                  ProductPriceRow(item: item),
                ],
              ),
            ),
          ),
          if (isAdmin) _AdminMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ⋮ ปุ่มเมนู admin
// ══════════════════════════════════════════════
class _AdminMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AdminMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<int>(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, size: 18, color: AppColors.grey600),
        onSelected: (v) => v == 1 ? onEdit() : onDelete(),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.edit, color: AppColors.blue, size: 20),
                const SizedBox(width: 12),
                const Text('ແກ້ໄຂ'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.delete, color: AppColors.errorRed, size: 20),
                const SizedBox(width: 12),
                Text('ລຶບ', style: TextStyle(color: AppColors.errorRed)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}