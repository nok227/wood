import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

class SalesListEmpty extends StatelessWidget {
  const SalesListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SaleStyle.gap120,
        Center(
          child: Text(
            SaleStyle.noSales,
            style: SaleStyle.textEmptyList,
          ),
        ),
      ],
    );
  }
}