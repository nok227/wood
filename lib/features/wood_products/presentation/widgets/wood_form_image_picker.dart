import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/wood_product_controller.dart';

class WoodFormImagePicker extends StatelessWidget {
  final WoodProductController controller;
  const WoodFormImagePicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalCount =
        controller.existingImageUrls.length + controller.selectedImages.length;
    final tiles = <Widget>[];

    for (int i = 0; i < controller.existingImageUrls.length; i++) {
      final url = controller.existingImageUrls[i];
      tiles.add(_thumb(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (c, u) => const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (c, u, e) => const Icon(Icons.broken_image),
        ),
        onRemove: () => controller.removeExistingImage(i),
      ));
    }

    for (int i = 0; i < controller.selectedImages.length; i++) {
      final file = controller.selectedImages[i];
      tiles.add(_thumb(
        child: Image.file(file, fit: BoxFit.cover),
        onRemove: () => controller.removeNewImage(i),
      ));
    }

    if (totalCount < WoodProductController.maxImages) {
      tiles.add(GestureDetector(
        onTap: controller.pickImages,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  color: Colors.grey.shade600, size: 22),
              const SizedBox(height: 2),
              Text(
                'ກ້ອງ/ຄັງ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return Wrap(spacing: 8, runSpacing: 8, children: tiles);
  }

  Widget _thumb({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 72, height: 72, child: child),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}