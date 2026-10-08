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

class WoodProductListPage extends StatefulWidget {
  const WoodProductListPage({super.key});

  @override
  State<WoodProductListPage> createState() => _WoodProductListPageState();
}

class _WoodProductListPageState extends State<WoodProductListPage>
    with AutomaticKeepAliveClientMixin {
  String selectedNameFilter = WoodStyle.all;

  final ScrollController _scrollController = ScrollController();
  int _displayLimit = WoodStyle.perPage;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - WoodStyle.listThreshold &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
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
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const WoodListSkeleton();
        }
        if (controller.products.isEmpty) {
          return const Center(
            child: Text(WoodStyle.noProductsList, style: WoodStyle.txEmptyState),
          );
        }

        // ── จัดกลุ่ม ──
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
          final typeKey =
              item.woodType.trim().isEmpty ? WoodStyle.noType : item.woodType.trim();
          nested.putIfAbsent(nameKey, () => {});
          nested[nameKey]!.putIfAbsent(typeKey, () => []);
          nested[nameKey]![typeKey]!.add(item);
        }

        nested.forEach((_, typeMap) {
          typeMap.forEach((_, list) => list.sort((a, b) => b.price.compareTo(a.price)));
        });

        final nameKeys = nested.keys.toList()
          ..sort((a, b) {
            int ta = 0, tb = 0;
            nested[a]!.forEach((_, l) => ta += l.length);
            nested[b]!.forEach((_, l) => tb += l.length);
            return tb.compareTo(ta);
          });

        final displayKeys = nameKeys.take(_displayLimit).toList();

        return RefreshIndicator(
          color: WoodStyle.primary,
          onRefresh: () async {
            setState(() => _displayLimit = WoodStyle.perPage);
            await controller.fetchProducts();
          },
          child: Column(
            children: [
              WoodListFilterBar(
                options: nameOptions,
                selected: selectedNameFilter,
                onSelected: (v) => setState(() {
                  selectedNameFilter = v;
                  _displayLimit = WoodStyle.perPage;
                }),
              ),
              Expanded(
                child: nameKeys.isEmpty
                    ? const Center(
                        child: Text(WoodStyle.noFilteredList, style: WoodStyle.txEmptyState),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: WoodStyle.padListPage,
                        itemCount: displayKeys.length +
                            (_isLoadingMore && displayKeys.length < nameKeys.length ? 1 : 0),
                        itemBuilder: (context, idx) {
                          if (idx == displayKeys.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: WoodStyle.pageLoadPadV),
                              child: Center(
                                child: CircularProgressIndicator(color: WoodStyle.primary),
                              ),
                            );
                          }
                          final nameKey = displayKeys[idx];
                          return WoodListGroup(
                            nameKey: nameKey,
                            typeMap: nested[nameKey]!,
                            isAdmin: isAdmin,
                            controller: controller,
                            onEdit: (p) {
                              controller.startEdit(p);
                              Get.to(() => const WoodProductFormPage(isPage: true));
                            },
                            onDelete: (p) => _confirmDelete(controller, p),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(WoodProductController controller, WoodProduct item) {
    Get.defaultDialog(
      title: WoodStyle.deleteTitle,
      middleText: '${WoodStyle.deleteMsgPrefix}${item.name}${WoodStyle.deleteMsgSuffix}',
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