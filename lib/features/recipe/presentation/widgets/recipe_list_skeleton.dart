import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/recipe_style.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_box.dart';
import 'package:wood/core/widgets/global/skeletons/shimmer_host.dart';

class RecipeListSkeleton extends StatelessWidget {
  const RecipeListSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerHost(
      builder: (context, p) => ListView.builder(
        padding: RecipeStyle.padListSkeleton,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, _) => Card(
          margin: RecipeStyle.padCardMargin,
          shape: const RoundedRectangleBorder(
            borderRadius: RecipeStyle.cardRadius,
            side: BorderSide(
              color: RecipeStyle.grey300,
              width: RecipeStyle.borderWidthNormal,
            ),
          ),
          child: Padding(
            padding: RecipeStyle.padCard,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: RecipeStyle.thumbRecipe,
                  height: RecipeStyle.thumbRecipe,
                  progress: p,
                  radius: 10,
                ),
                RecipeStyle.gap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShimmerBox(
                              width: double.infinity,
                              height: 15,
                              progress: p,
                            ),
                          ),
                          RecipeStyle.gap8,
                          ShimmerBox(
                            width: 20,
                            height: 20,
                            progress: p,
                            shape: BoxShape.circle,
                          ),
                        ],
                      ),
                      RecipeStyle.gap6,
                      Wrap(
                        spacing: RecipeStyle.wrapCardSpacing,
                        runSpacing: RecipeStyle.wrapCardRunSpacing,
                        children: [
                          ShimmerBox(
                            width: 60,
                            height: 14,
                            progress: p,
                            radius: 5,
                          ),
                          ShimmerBox(
                            width: 50,
                            height: 14,
                            progress: p,
                            radius: 5,
                          ),
                          ShimmerBox(
                            width: 55,
                            height: 14,
                            progress: p,
                            radius: 5,
                          ),
                        ],
                      ),
                      RecipeStyle.gap6,
                      ShimmerBox(
                        width: double.infinity,
                        height: 11,
                        progress: p,
                      ),
                      RecipeStyle.gap4,
                      ShimmerBox(width: 140, height: 11, progress: p),
                      RecipeStyle.gap8,
                      Row(
                        children: [
                          ShimmerBox(width: 100, height: 11, progress: p),
                          const Spacer(),
                          ShimmerBox(
                            width: 60,
                            height: 20,
                            progress: p,
                            radius: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}