import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
import '../../controllers/wood_product_controller.dart';
import '../../widgets/wood_list_filter_bar.dart';
import '../../widgets/wood_list_group.dart';
import '../../widgets/wood_list_skeleton.dart';
import '../form/wood_product_form_page.dart';

class WoodProductListPage extends StatefulWidget {
  const WoodProductListPage({super.key});

  @override
  State<WoodProductListPage> createState() => _WoodProductListPageState();
}

class _WoodProductListPageState extends State<WoodProductListPage>
    with AutomaticKeepAliveClientMixin {
  String selectedNameFilter = 'ທັງໝົດ';

  final ScrollController _scrollController = ScrollController();
  int _displayLimit = 10;
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
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _displayLimit += 10;
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
      backgroundColor: Colors.brown[50],
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const WoodListSkeleton();
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('ຍັງບໍ່ມີຂໍ້ມູນສິນຄ້າໄມ້'));
        }

        final allNames = controller.products
            .map((p) => p.name.trim())
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();
        final nameOptions = ['ທັງໝົດ', ...allNames];

        final filteredList = selectedNameFilter == 'ທັງໝົດ'
            ? controller.products.toList()
            : controller.products
                .where((p) => p.name.trim() == selectedNameFilter)
                .toList();

        final Map<String, Map<String, List<WoodProductModel>>> nested = {};

        for (final item in filteredList) {
          final nameKey =
              item.name.trim().isEmpty ? 'ບໍ່ລະບຸຊື່' : item.name.trim();
          final typeKey = item.woodType.trim().isEmpty
              ? 'ບໍ່ລະບຸຊະນິດ'
              : item.woodType.trim();

          nested.putIfAbsent(nameKey, () => {});
          nested[nameKey]!.putIfAbsent(typeKey, () => []);
          nested[nameKey]![typeKey]!.add(item);
        }

        nested.forEach((_, typeMap) {
          typeMap.forEach((_, list) {
            list.sort((a, b) => b.price.compareTo(a.price));
          });
        });

        final nameKeys = nested.keys.toList()
          ..sort((a, b) {
            int totalA = 0;
            int totalB = 0;
            nested[a]!.forEach((_, l) => totalA += l.length);
            nested[b]!.forEach((_, l) => totalB += l.length);
            return totalB.compareTo(totalA);
          });

        final displayKeys = nameKeys.take(_displayLimit).toList();

        return RefreshIndicator(
          color: Colors.brown,
          onRefresh: () async {
            setState(() => _displayLimit = 10);
            await controller.fetchProducts();
          },
          child: Column(
            children: [
              WoodListFilterBar(
                options: nameOptions,
                selected: selectedNameFilter,
                onSelected: (v) => setState(() {
                  selectedNameFilter = v;
                  _displayLimit = 10;
                }),
              ),
              Expanded(
                child: nameKeys.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: displayKeys.length +
                            (_isLoadingMore &&
                                    displayKeys.length < nameKeys.length
                                ? 1
                                : 0),
                        itemBuilder: (context, idx) {
                          if (idx == displayKeys.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.brown,
                                ),
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
                              Get.to(() =>
                                  const WoodProductFormPage(isPage: true));
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

  void _confirmDelete(
    WoodProductController controller,
    WoodProductModel item,
  ) {
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      middleText: 'ຕ້ອງການລຶບ "${item.name}" ແມ່ນຫຼືບໍ່?',
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () {
        Get.back();
        controller.deleteProduct(item.id);
      },
    );
  }
}