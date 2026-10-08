import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_form_controller.dart';

class RecipeFormImages extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormImages({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tiles = <Widget>[];

      for (int i = 0; i < controller.existingUrls.length; i++) {
        tiles.add(_tile(
          child: CachedNetworkImage(
            imageUrl: controller.existingUrls[i],
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: RecipeStyle.brown50),
            errorWidget: (_, _, _) => const Icon(Icons.broken_image),
          ),
          onRemove: () => controller.removeExistingUrl(i),
        ));
      }

      for (int i = 0; i < controller.newFiles.length; i++) {
        tiles.add(_tile(
          child: Image.file(controller.newFiles[i], fit: BoxFit.cover),
          onRemove: () => controller.removeNewFile(i),
        ));
      }

      if (tiles.length < RecipeStyle.maxImages) {
        tiles.add(GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            width: RecipeStyle.imageTileSize,
            height: RecipeStyle.imageTileSize,
            decoration: BoxDecoration(
              color: RecipeStyle.white,
              border: Border.all(color: RecipeStyle.brown200),
              borderRadius: RecipeStyle.r10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo,
                  color: RecipeStyle.brown400,
                  size: RecipeStyle.iconAdd,
                ),
                RecipeStyle.gap3,
                Text(RecipeStyle.addImageLabel,
                    style: RecipeStyle.addImageLabelStyle),
              ],
            ),
          ),
        ));
      }

      return Wrap(
        spacing: RecipeStyle.wrapImgSpacing,
        runSpacing: RecipeStyle.wrapImgSpacing,
        children: tiles,
      );
    });
  }

  Widget _tile({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: RecipeStyle.r10,
          child: SizedBox(
            width: RecipeStyle.imageTileSize,
            height: RecipeStyle.imageTileSize,
            child: child,
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: RecipeStyle.padImgBadge,
              decoration: const BoxDecoration(
                color: RecipeStyle.textPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: RecipeStyle.imgCloseBadge,
                color: RecipeStyle.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}