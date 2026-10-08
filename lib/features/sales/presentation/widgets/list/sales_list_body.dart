import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';

import '../../controllers/sales_controller.dart';
import '../../controllers/sales_list_controller.dart';
import '../sale_card.dart';
import '../sales_list_skeleton.dart';
import 'sales_date_header.dart';
import 'sales_list_empty.dart';

class SalesListBody extends StatelessWidget {
  final SalesController sales;
  final SalesListController list;

  const SalesListBody({
    super.key,
    required this.sales,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Obx(() {
      if (sales.isLoading.value && sales.allSalesList.isEmpty) {
        return const SalesListSkeleton(count: 5);
      }

      final rev = sales.salesRevision.value;
      final items = sales.filteredSalesList;

      if (items.isEmpty) {
        return RefreshIndicator(
          color: SaleStyle.primary,
          onRefresh: () async {
            list.resetLimit();
            await sales.fetchSales();
          },
          child: const SalesListEmpty(),
        );
      }

      final grouped = list.groupByDate(
        items,
        sales.selectedFilter.value,
        rev,
      );
      final groupKeys = list.cachedKeys;
      final displayKeys = groupKeys.take(list.displayLimit.value).toList();
      final hasMore = groupKeys.length > displayKeys.length;

      return RefreshIndicator(
        color: SaleStyle.primary,
        onRefresh: () async {
          list.resetLimit();
          await sales.fetchSales();
        },
        child: ListView.builder(
          controller: list.scrollCtrl,
          padding: SaleStyle.padListFAB,
          itemCount: displayKeys.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == displayKeys.length) {
              return const Padding(
                padding: SaleStyle.padLoadMore,
                child: Center(
                  child: CircularProgressIndicator(
                    color: SaleStyle.primary,
                  ),
                ),
              );
            }

            final dateKey = displayKeys[index];
            final group = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SalesDateHeader(
                  date: group.first.date,
                  count: group.length,
                  formatHeader: list.formatDateHeader,
                ),
                ...group.map(
                  (sale) => RepaintBoundary(
                    key: ValueKey('rb-${sale.id}'),
                    child: SaleCard(
                      key: ValueKey('sale-${sale.id}'),
                      sale: sale,
                      isAdmin: isAdmin,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}