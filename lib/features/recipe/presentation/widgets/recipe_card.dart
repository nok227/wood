import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/core/constants/specific/recipe_style.dart';
import '../../domain/entities/recipe.dart';

class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onTap;
  final VoidCallback onMarkEaten;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onMarkEaten,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fresh = recipe.isFreshlyEaten;

    return Card(
      margin: RecipeStyle.padCardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: RecipeStyle.cardRadius,
        side: BorderSide(
          color: fresh ? RecipeStyle.green300 : RecipeStyle.brown200,
          width: RecipeStyle.borderWidthNormal,
        ),
      ),
      child: InkWell(
        borderRadius: RecipeStyle.cardRadius,
        onTap: onTap,
        child: Padding(
          padding: RecipeStyle.padCard,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumb(),
              RecipeStyle.gap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleRow(),
                    RecipeStyle.gap4,
                    _badgeRow(),
                    if (recipe.ingredients.isNotEmpty) ...[
                      RecipeStyle.gap6,
                      _ingredientsPreview(),
                    ],
                    RecipeStyle.gap6,
                    _bottomRow(fresh),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            recipe.name,
            style: RecipeStyle.recipeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: RecipeStyle.thumbPopupSize,
          height: RecipeStyle.thumbPopupSize,
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: RecipeStyle.iconSm,
            icon: const Icon(Icons.more_vert, color: RecipeStyle.black54),
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete,
                      color: RecipeStyle.errorRed,
                      size: RecipeStyle.iconSmMd,
                    ),
                    RecipeStyle.gap8,
                    Text(RecipeStyle.delete, style: RecipeStyle.menuDeleteText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeRow() {
    return Wrap(
      spacing: RecipeStyle.wrapCardSpacing,
      runSpacing: RecipeStyle.wrapCardRunSpacing,
      children: [
        _chip(
          '${recipe.category.emoji} ${recipe.category.label}',
          RecipeStyle.brown50,
          RecipeStyle.primary,
        ),
        _statusChip(),
        if (recipe.rating > 0) _stars(),
      ],
    );
  }

  Widget _ingredientsPreview() {
    final text =
        recipe.ingredients.take(4).join(' · ') +
        (recipe.ingredients.length > 4
            ? ' +${recipe.ingredients.length - 4}'
            : '');
    return Text(
      text,
      style: RecipeStyle.ingredients,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _bottomRow(bool fresh) {
    return Row(
      children: [
        Icon(
          recipe.lastEatenAt == null ? Icons.schedule : Icons.access_time,
          size: RecipeStyle.starSm,
          color: RecipeStyle.grey600,
        ),
        RecipeStyle.gap3,
        Expanded(
          child: Text(
            recipe.lastEatenLabel,
            style: TextStyle(
              fontSize: 11,
              color: recipe.isDueForVariety
                  ? RecipeStyle.warning
                  : RecipeStyle.grey600,
              fontWeight: recipe.isDueForVariety
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!fresh) _eatenButton() else _lastEatenBadge(),
      ],
    );
  }

  Widget _eatenButton() {
    return InkWell(
      onTap: onMarkEaten,
      borderRadius: RecipeStyle.r6,
      child: Container(
        padding: RecipeStyle.padChipMd,
        decoration: BoxDecoration(
          color: RecipeStyle.green50,
          borderRadius: RecipeStyle.r6,
          border: Border.all(color: RecipeStyle.green300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant,
              size: RecipeStyle.starSm,
              color: RecipeStyle.green800,
            ),
            RecipeStyle.gap3,
            Text(RecipeStyle.markEaten, style: RecipeStyle.eatenBtnText),
          ],
        ),
      ),
    );
  }

  Widget _lastEatenBadge() {
    return Container(
      padding: RecipeStyle.padChipMd,
      decoration: BoxDecoration(
        color: RecipeStyle.green50,
        borderRadius: RecipeStyle.r6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: RecipeStyle.starSm,
            color: RecipeStyle.success,
          ),
          RecipeStyle.gap3,
          Text(RecipeStyle.markEatenLast, style: RecipeStyle.eatenBadgeText),
        ],
      ),
    );
  }

  Widget _thumb() {
    final hasImg = recipe.imageUrls.isNotEmpty;
    return ClipRRect(
      borderRadius: RecipeStyle.r10,
      child: Container(
        width: RecipeStyle.thumbRecipe,
        height: RecipeStyle.thumbRecipe,
        color: RecipeStyle.brown50,
        child: hasImg
            ? CachedNetworkImage(
                imageUrl: recipe.imageUrls.first,
                fit: BoxFit.cover,
                memCacheWidth: 168,
                placeholder: (c, u) => Container(color: RecipeStyle.brown50),
                errorWidget: (_, _, _) => Center(
                  child: Text(
                    recipe.category.emoji,
                    style: RecipeStyle.emojiFallback,
                  ),
                ),
              )
            : Center(
                child: Text(
                  recipe.category.emoji,
                  style: RecipeStyle.emojiThumb,
                ),
              ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: RecipeStyle.padChip,
      decoration: BoxDecoration(color: bg, borderRadius: RecipeStyle.r5),
      child: Text(text, style: RecipeStyle.chipPreview.copyWith(color: fg)),
    );
  }

  Widget _statusChip() {
    Color bg;
    Color fg;
    switch (recipe.status) {
      case RecipeStatus.tried:
        bg = RecipeStyle.green50;
        fg = RecipeStyle.green800;
        break;
      case RecipeStatus.want:
        bg = RecipeStyle.amber50;
        fg = RecipeStyle.amber900;
        break;
      case RecipeStatus.never:
        bg = RecipeStyle.grey100;
        fg = RecipeStyle.grey700;
        break;
    }
    return _chip(recipe.status.label, bg, fg);
  }

  Widget _stars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < recipe.rating ? Icons.star : Icons.star_border,
          size: RecipeStyle.starSm,
          color: RecipeStyle.amber700,
        ),
      ),
    );
  }
}
