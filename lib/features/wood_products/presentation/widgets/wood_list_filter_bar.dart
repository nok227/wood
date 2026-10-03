import 'package:flutter/material.dart';

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
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
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.filter_list,
                    color: Colors.white, size: 13),
              ),
              const SizedBox(width: 6),
              const Text(
                'ກັ່ນກອງ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((name) {
                final sel = selected == name;
                final label = name == 'ທັງໝົດ' ? 'ທັງໝົດ' : name;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    avatar: sel
                        ? Icon(Icons.check_circle,
                            size: 14, color: Colors.brown.shade700)
                        : null,
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            sel ? FontWeight.bold : FontWeight.w600,
                        color: sel
                            ? Colors.brown.shade900
                            : Colors.brown.shade700,
                      ),
                    ),
                    selected: sel,
                    selectedColor: Colors.brown.shade100,
                    backgroundColor: Colors.brown.shade50,
                    side: BorderSide(
                      color: sel
                          ? Colors.brown.shade400
                          : Colors.brown.shade200,
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