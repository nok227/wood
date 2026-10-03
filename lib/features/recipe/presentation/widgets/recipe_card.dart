import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: fresh ? Colors.green.shade300 : Colors.brown.shade200,
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumb(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: const Icon(Icons.more_vert,
                                color: Colors.black54),
                            onSelected: (v) {
                              if (v == 'delete') onDelete();
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        color: Colors.red, size: 18),
                                    SizedBox(width: 8),
                                    Text('ລຶບ',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _chip(
                          '${recipe.category.emoji} ${recipe.category.label}',
                          Colors.brown.shade50,
                          Colors.brown.shade700,
                        ),
                        _statusChip(),
                        if (recipe.rating > 0) _stars(),
                      ],
                    ),
                    if (recipe.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        recipe.ingredients.take(4).join(' · ') +
                            (recipe.ingredients.length > 4
                                ? ' +${recipe.ingredients.length - 4}'
                                : ''),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          recipe.lastEatenAt == null
                              ? Icons.schedule
                              : Icons.access_time,
                          size: 11,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            recipe.lastEatenLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: recipe.isDueForVariety
                                  ? Colors.orange.shade800
                                  : Colors.grey.shade600,
                              fontWeight: recipe.isDueForVariety
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!fresh)
                          InkWell(
                            onTap: onMarkEaten,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.green.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.restaurant,
                                      size: 11,
                                      color: Colors.green.shade800),
                                  const SizedBox(width: 3),
                                  Text(
                                    'ກິນແລ້ວ',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    size: 11,
                                    color: Colors.green.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'ກິນຫຼ້າສຸດ',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _thumb() {
    final hasImg = recipe.imageUrls.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 84,
        height: 84,
        color: Colors.brown.shade50,
        child: hasImg
            ? CachedNetworkImage(
                imageUrl: recipe.imageUrls.first,
                fit: BoxFit.cover,
                memCacheWidth: 168,
                placeholder: (c, u) =>
                    Container(color: Colors.brown.shade50),
                errorWidget: (_, __, ___) => Center(
                  child: Text(
                    recipe.category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              )
            : Center(
                child: Text(
                  recipe.category.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _statusChip() {
    Color bg;
    Color fg;
    switch (recipe.status) {
      case RecipeStatus.tried:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case RecipeStatus.want:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case RecipeStatus.never:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
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
          size: 11,
          color: Colors.amber.shade700,
        ),
      ),
    );
  }
}