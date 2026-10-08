import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/wood_3d_style.dart';

class Wood3DChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const Wood3DChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Wood3DStyle.chipRowH,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((opt) {
            final isSel = opt == selected;
            final label =
                opt == Wood3DStyle.allFilter ? Wood3DStyle.allFilter : opt;

            return Padding(
              padding: Wood3DStyle.padChipRight,
              child: ChoiceChip(
                showCheckmark: false,
                avatar: isSel
                    ? const Icon(
                        Icons.check_circle,
                        size: Wood3DStyle.iconStar13,
                        color: Wood3DStyle.brown700,
                      )
                    : null,
                label: Text(
                  label,
                  style:
                      (isSel ? Wood3DStyle.txChipSelected : Wood3DStyle.txChip)
                          .copyWith(
                    color: isSel
                        ? Wood3DStyle.brown900
                        : Wood3DStyle.brown700,
                  ),
                ),
                selected: isSel,
                selectedColor: Wood3DStyle.brown100,
                backgroundColor: Wood3DStyle.brown50,
                side: BorderSide(
                  color: isSel
                      ? Wood3DStyle.brown400
                      : Wood3DStyle.brown200,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: Wood3DStyle.padChipInner,
                labelPadding: Wood3DStyle.padChipLabel,
                onSelected: (_) => onSelected(opt),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}