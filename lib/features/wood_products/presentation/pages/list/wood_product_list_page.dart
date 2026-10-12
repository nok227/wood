import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/wood_style.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import '../../controllers/wood_product_controller.dart';
import '../../widgets/list/wood_list_filter_bar.dart';
import '../../widgets/list/wood_list_group.dart';
import '../../widgets/list/wood_list_skeleton.dart';
import '../form/wood_product_form_page.dart';
import 'package:wood/core/widgets/global/loading/loading.dart';

class WoodProductListPage extends StatefulWidget {
  const WoodProductListPage({super.key});

  @override
  State<WoodProductListPage> createState() => _WoodProductListPageState();
}

class _WoodProductListPageState extends State<WoodProductListPage>
    with AutomaticKeepAliveClientMixin {
  String selectedNameFilter = WoodStyle.all;

  int _displayLimit = WoodStyle.perPage;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.pixels >=
            n.metrics.maxScrollExtent - WoodStyle.listThreshold &&
        !_isLoadingMore) {
      // ⭐ เลื่อน setState ไปหลังเฟรม — กัน "Build scheduled during frame"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMore();
      });
    }
    return false;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    if (mounted) setState(() {}); // ⭐ โชว์ loader ทันที

    await Future.delayed(WoodStyle.debounce);

    if (mounted) {
      setState(() {
        _displayLimit += WoodStyle.perPage;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<WoodProductController>();
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: WoodStyle.brown50,
      body: Obx(() {
        // ── Loading ──
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const WoodListSkeleton();
        }
        if (controller.products.isEmpty) {
          return const Center(
            child: Text(WoodStyle.noProductsList,
                style: WoodStyle.txEmptyState),
          );
        }

        // ── Filter + Group ──
        final nameOptions = <String>[
          WoodStyle.all,
          ...controller.products
              .map((p) => p.name.trim())
              .where((n) => n.isNotEmpty)
              .toSet(),
        ];

        final filtered = selectedNameFilter == WoodStyle.all
            ? controller.products.toList()
            : controller.products
                .where((p) => p.name.trim() == selectedNameFilter)
                .toList();

        final Map<String, Map<String, List<WoodProduct>>> nested = {};
        for (final item in filtered) {
          final nameKey =
              item.name.trim().isEmpty ? WoodStyle.noName : item.name.trim();
          final typeKey = item.woodType.trim().isEmpty
              ? WoodStyle.noType
              : item.woodType.trim();
          nested.putIfAbsent(nameKey, () => {});
          nested[nameKey]!.putIfAbsent(typeKey, () => []);
          nested[nameKey]![typeKey]!.add(item);
        }

        nested.forEach((_, typeMap) {
          typeMap.forEach(
              (_, list) => list.sort((a, b) => b.price.compareTo(a.price)));
        });

        final nameKeys = nested.keys.toList()
          ..sort((a, b) {
            int ta = 0, tb = 0;
            nested[a]!.forEach((_, l) => ta += l.length);
            nested[b]!.forEach((_, l) => tb += l.length);
            return tb.compareTo(ta);
          });

        final displayKeys = nameKeys.take(_displayLimit).toList();

        return Column(
          children: [
            // ═══════════════════════════════
            // 🏷️ Filter bar (ด้านบน)
            // ═══════════════════════════════
            WoodListFilterBar(
              options: nameOptions,
              selected: selectedNameFilter,
              onSelected: (v) => setState(() {
                selectedNameFilter = v;
                _displayLimit = WoodStyle.perPage;
              }),
            ),

            // ═══════════════════════════════
            // 📋 List / Empty
            // ═══════════════════════════════
            Expanded(
              child: nameKeys.isEmpty
                  ? const Center(
                      child: Text(WoodStyle.noFilteredList,
                          style: WoodStyle.txEmptyState),
                    )
                  // ⭐ UniqueKey — บังคับ ListView สร้างใหม่ทุกครั้ง
                  //    ป้องกัน ScrollController ผูกซ้ำ
                  : _ProductListView(
                      key: ValueKey('product-list-$selectedNameFilter'),
                      controller: controller,
                      nameKeys: nameKeys,
                      displayKeys: displayKeys,
                      nested: nested,
                      isAdmin: isAdmin,
                      isLoadingMore: _isLoadingMore,
                      onScrollNotification: _onScrollNotification,
                      onRefresh: () async {
                        setState(() => _displayLimit = WoodStyle.perPage);
                        await controller.fetchProducts();
                      },
                      onEdit: (p) {
                        controller.startEdit(p);
                        Get.to(() =>
                            const WoodProductFormPage(isPage: true));
                      },
                      onDelete: (p) => _confirmDelete(controller, p),
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _confirmDelete(WoodProductController controller, WoodProduct item) {
    Get.defaultDialog(
      title: WoodStyle.deleteTitle,
      middleText:
          '${WoodStyle.deleteMsgPrefix}${item.name}${WoodStyle.deleteMsgSuffix}',
      textConfirm: WoodStyle.delete,
      textCancel: WoodStyle.cancel,
      confirmTextColor: WoodStyle.white,
      buttonColor: WoodStyle.error700,
      onConfirm: () {
        Get.back();
        controller.deleteProduct(item.id);
      },
    );
  }
}

// ══════════════════════════════════════════════
// 📋 Product List — แยก widget เด็ดขาด
// ══════════════════════════════════════════════
class _ProductListView extends StatelessWidget {
  final WoodProductController controller;
  final List<String> nameKeys;
  final List<String> displayKeys;
  final Map<String, Map<String, List<WoodProduct>>> nested;
  final bool isAdmin;
  final bool isLoadingMore;
  final bool Function(ScrollNotification) onScrollNotification;
  final Future<void> Function() onRefresh;
  final void Function(WoodProduct) onEdit;
  final void Function(WoodProduct) onDelete;

  const _ProductListView({
    super.key,
    required this.controller,
    required this.nameKeys,
    required this.displayKeys,
    required this.nested,
    required this.isAdmin,
    required this.isLoadingMore,
    required this.onScrollNotification,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: WoodStyle.primary,
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: ListView.builder(
          // ⭐ PageStorageKey — จำตำแหน่ง scroll
          key: const PageStorageKey('wood_products_list'),
          padding: WoodStyle.padListPage,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: displayKeys.length +
              (isLoadingMore && displayKeys.length < nameKeys.length ? 1 : 0),
          itemBuilder: (context, idx) {
            if (idx == displayKeys.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: WoodStyle.pageLoadPadV),
                child: Center(
                  child: RotatingSquaresLoader(size: 40),
                ),
              );
            }
            final nameKey = displayKeys[idx];
            return WoodListGroup(
              nameKey: nameKey,
              typeMap: nested[nameKey]!,
              isAdmin: isAdmin,
              controller: controller,
              onEdit: onEdit,
              onDelete: onDelete,
            );
          },
        ),
      ),
    );
  }
}