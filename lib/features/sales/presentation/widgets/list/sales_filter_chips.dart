import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

import '../../controllers/sales_controller.dart';

class SalesFilterChips extends StatelessWidget {
  final SalesController controller;
  final void Function(DateFilter) onChanged;

  const SalesFilterChips({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SaleStyle.white,
      padding: SaleStyle.padFilterRow,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: SaleStyle.padH8,
        child: Obx(
          () => Row(
            children: [
              _chip(SaleStyle.filterAll, DateFilter.all),
              _chip(SaleStyle.filterToday, DateFilter.today),
              _chip(SaleStyle.filterWeek, DateFilter.week),
              _chip(SaleStyle.filterMonth, DateFilter.month),
              _chip(SaleStyle.filterYear, DateFilter.year),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, DateFilter filter) {
    final isSelected = controller.selectedFilter.value == filter;
    return Padding(
      padding: SaleStyle.padFilterChip,
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(
          Icons.check_circle,
          color: isSelected ? SaleStyle.brown700 : SaleStyle.grey400,
          size: SaleStyle.iconCheckSm,
        ),
        label: Text(
          label,
          style: (isSelected
                  ? SaleStyle.textFilterChipSelected
                  : SaleStyle.textFilterChip)
              .copyWith(
            color: isSelected ? SaleStyle.brown900 : SaleStyle.brown700,
          ),
        ),
        selected: isSelected,
        selectedColor: SaleStyle.brown100,
        backgroundColor: SaleStyle.brown50,
        onSelected: (selected) {
          if (selected) onChanged(filter);
        },
      ),
    );
  }
}