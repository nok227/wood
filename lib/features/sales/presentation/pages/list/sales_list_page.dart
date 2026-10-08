import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

import '../../controllers/sales_controller.dart';
import '../../controllers/sales_list_controller.dart';
import '../../widgets/list/sales_filter_chips.dart';
import '../../widgets/list/sales_list_body.dart';
import '../../widgets/list/sales_list_fab.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  @override
  void initState() {
    super.initState();
    Get.put(SalesListController());
  }

  @override
  void dispose() {
    Get.delete<SalesListController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sales = Get.find<SalesController>();
    final list = Get.find<SalesListController>();

    return Scaffold(
      backgroundColor: SaleStyle.bg,
      body: Stack(
        children: [
          Column(
            children: [
              SalesFilterChips(
                controller: sales,
                onChanged: (f) {
                  list.resetLimit();
                  sales.applyDateFilter(f);
                },
              ),
              Expanded(
                child: SalesListBody(sales: sales, list: list),
              ),
            ],
          ),
          SalesFabBackdrop(controller: list),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SalesListFab(controller: list),
    );
  }
}