import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

class WoodGalleryThumbnails extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WoodGalleryThumbnails({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WoodStyle.galleryHeight,
      padding: WoodStyle.padGallery,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WoodStyle.black.withOpacity(0.0),
            WoodStyle.black.withOpacity(WoodStyle.opacityGradientEnd),
          ],
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: WoodStyle.galleryGap),
        itemBuilder: (context, i) {
          final selected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: WoodStyle.galleryThumbW,
              decoration: BoxDecoration(
                borderRadius: WoodStyle.galleryThumbR,
                border: Border.all(
                  color: selected ? WoodStyle.tealAccent : WoodStyle.white24,
                  width: WoodStyle.borderW2_0,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: WoodStyle.tealAccent
                              .withOpacity(WoodStyle.opacityGlow),
                          blurRadius: WoodStyle.galleryGlowBlur,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: WoodStyle.galleryThumbRSm,
                child: CachedNetworkImage(
                  imageUrl: imageUrls[i],
                  fit: BoxFit.cover,
                  placeholder: (c, u) => const Center(
                    child: SizedBox(
                      width: WoodStyle.galleryPlaceholderSize,
                      height: WoodStyle.galleryPlaceholderSize,
                      child: CircularProgressIndicator(
                        strokeWidth: WoodStyle.galleryPlaceholderStroke,
                      ),
                    ),
                  ),
                  errorWidget: (c, u, e) => const Icon(
                    Icons.broken_image,
                    size: WoodStyle.galleryErrorSm,
                    color: WoodStyle.white54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}