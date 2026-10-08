import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

class WoodFormSuggestion extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onPick;

  const WoodFormSuggestion({
    super.key,
    required this.items,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final sorted = List<String>.from(items);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 13, color: WoodStyle.brown400),
              const SizedBox(width: 4),
              Text(
                '${WoodStyle.prevInput} (${sorted.length})',
                style: WoodStyle.suggestionHeader,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.map((t) {
              return ActionChip(
                label: Text(t, style: WoodStyle.suggestionChip),
                backgroundColor: WoodStyle.brown50,
                side: const BorderSide(color: WoodStyle.brown200),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () => onPick(t),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}