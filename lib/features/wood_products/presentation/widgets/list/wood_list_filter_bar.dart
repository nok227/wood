import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/wood_style.dart';

class WoodListFilterBar extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const WoodListFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: WoodStyle.white,
        boxShadow: [
          BoxShadow(
            color: WoodStyle.brown700.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: WoodStyle.brown700,
                  borderRadius: WoodStyle.r6,
                ),
                child: const Icon(Icons.filter_list,
                    color: WoodStyle.white, size: 13),
              ),
              const SizedBox(width: 6),
              const Text(
                WoodStyle.filterLabel,
                style: WoodStyle.filterTitle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((name) {
                final sel = selected == name;
                final label = name == WoodStyle.all ? WoodStyle.all : name;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    avatar: sel
                        ? const Icon(Icons.check_circle,
                            size: 14, color: WoodStyle.brown700)
                        : null,
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            sel ? FontWeight.bold : FontWeight.w600,
                        color: sel
                            ? WoodStyle.brown900
                            : WoodStyle.brown700,
                      ),
                    ),
                    selected: sel,
                    selectedColor: WoodStyle.brown100,
                    backgroundColor: WoodStyle.brown50,
                    side: BorderSide(
                      color: sel
                          ? WoodStyle.brown400
                          : WoodStyle.brown200,
                    ),
                    onSelected: (_) => onSelected(name),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}