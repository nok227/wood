import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_strings.dart';

class SectionWrapper extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool done;
  final bool warning;

  const SectionWrapper({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.done = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = done
        ? AppColors.success
        : (warning ? AppColors.amber600 : color);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppLayout.r14,
        border: Border.all(
          color: effectiveColor.withOpacity(done ? 0.5 : 0.25),
          width: done ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(done ? 0.12 : 0.06),
            blurRadius: done ? 10 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                _numberBadge(effectiveColor),
                const SizedBox(width: 10),
                Icon(icon, color: effectiveColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: effectiveColor,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (done)
                  _badge(AppStrings.done, Icons.check, AppColors.success)
                else if (warning)
                  _badge(
                    AppStrings.optional,
                    Icons.edit_note,
                    AppColors.amber600,
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _numberBadge(Color c) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

  Widget _badge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}