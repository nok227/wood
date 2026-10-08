import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/widgets/global/dashed_divider.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import '../../pages/gallery/wood_gallery_page.dart';             
import '../../controllers/wood_product_controller.dart';
import 'wood_list_product_card.dart';

class WoodListGroup extends StatelessWidget {
  final String nameKey;
  final Map<String, List<WoodProduct>> typeMap;                      
  final bool isAdmin;
  final WoodProductController controller;
  final void Function(WoodProduct) onEdit;                         
  final void Function(WoodProduct) onDelete;                       

  const WoodListGroup({
    super.key,
    required this.nameKey,
    required this.typeMap,
    required this.isAdmin,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    int totalItems = 0;
    final totalTypes = typeMap.length;
    typeMap.forEach((_, l) => totalItems += l.length);

    final typeKeys = typeMap.keys.toList()
      ..sort((a, b) {
        final c = typeMap[b]!.length.compareTo(typeMap[a]!.length);
        return c != 0 ? c : a.compareTo(b);
      });

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brown300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(totalTypes, totalItems),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < typeKeys.length; i++) ...[
                  _subHeader(typeKeys[i], typeMap[typeKeys[i]]!.length),
                  const SizedBox(height: 4),
                  for (int j = 0;
                      j < typeMap[typeKeys[i]]!.length;
                      j++) ...[
                    _card(typeMap[typeKeys[i]]![j]),
                    if (j < typeMap[typeKeys[i]]!.length - 1)
                      const DashedDivider(
                        dashWidth: 5,
                        dashSpace: 4,
                        height: 1,
                        color: Color(0xFFE0E0E0),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      ),
                  ],
                  if (i < typeKeys.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(int totalTypes, int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.brown600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, color: AppColors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameKey,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$totalTypes ຊະນິດ · $totalItems ລາຍການ',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$totalItems',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(String typeKey, int count) {
    final isUnknown = typeKey == 'ບໍ່ລະບຸຊະນິດ';
    final color = isUnknown ? AppColors.grey600 : AppColors.primary;
    final bgColor = isUnknown ? AppColors.grey100 : AppColors.brown50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            isUnknown ? Icons.help_outline : Icons.local_florist,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isUnknown ? typeKey : 'ຊະນິດ: $typeKey',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count ຂະໜາດ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ປ່ຽນ param ເປັນ WoodProduct
  Widget _card(WoodProduct item) {
    return WoodListProductCard(
      item: item,
      isAdmin: isAdmin,
      onEdit: () => onEdit(item),
      onDelete: () => onDelete(item),
      onImageTap: item.imageUrls.isEmpty
          ? () {}
          : () => Get.to(
                () => WoodGalleryPage(
                  imageUrls: item.imageUrls,
                  title: item.name,
                ),
              ),
    );
  }
}