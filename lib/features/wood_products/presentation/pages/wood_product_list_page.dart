// lib/features/wood_products/presentation/pages/wood_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';
import 'package:wood/features/wood_products/presentation/widgets/wood_list_skeleton.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import 'wood_product_form_page.dart';
import 'wood_gallery_page.dart';

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

  String formatNum(num v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<WoodProductController>();
    final bool isAdmin = Get.find<AuthController>().isAdmin;

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

        // ── ຈັດກຸ່ມຕາມ ຊື່ + ຊະນິດໄມ້ ──
        final Map<String, List<WoodProductModel>> groupedProducts = {};
        for (var item in filteredList) {
          final groupKey =
              '${item.name} (ຊະນິດ: ${item.woodType.isEmpty ? "ບໍ່ລະບຸ" : item.woodType})';
          groupedProducts.putIfAbsent(groupKey, () => []).add(item);
        }

        // ── ຈັດລຳດັບຕາມປະລິມາດ (ນ້ອຍ → ໃຫຍ່) ──
        groupedProducts.forEach((_, list) {
          list.sort((a, b) {
            final va = a.width * a.length * a.thickness;
            final vb = b.width * b.length * b.thickness;
            return va.compareTo(vb);
          });
        });

        final groupKeys = groupedProducts.keys.toList();
        final displayKeys = groupKeys.take(_displayLimit).toList();

        return RefreshIndicator(
          color: Colors.brown,
          onRefresh: () async {
            setState(() => _displayLimit = 10);
            await controller.fetchProducts();
          },
          child: Column(
            children: [
              // ══════════════════════════════════════════
              // 🔽 ຕົວກັ່ນກອງ
              // ══════════════════════════════════════════
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.filter_list,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ກັ່ນກອງ:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: nameOptions.contains(selectedNameFilter)
                            ? selectedNameFilter
                            : 'ທັງໝົດ',
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          fillColor: Colors.brown.shade50,
                          filled: true,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.brown.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.brown.shade200),
                          ),
                        ),
                        items: nameOptions
                            .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name == 'ທັງໝົດ'
                                        ? 'ທັງໝົດ'
                                        : name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedNameFilter = val;
                              _displayLimit = 10;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════════
              // 📋 ລາຍການ
              // ══════════════════════════════════════════
              Expanded(
                child: groupKeys.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: displayKeys.length +
                            (_isLoadingMore &&
                                    displayKeys.length < groupKeys.length
                                ? 1
                                : 0),
                        itemBuilder: (context, gIndex) {
                          if (gIndex == displayKeys.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.brown),
                              ),
                            );
                          }

                          final groupTitle = displayKeys[gIndex];
                          final items = groupedProducts[groupTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── ຫົວກຸ່ມ ──
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, top: 12, bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.brown.shade700,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.category,
                                          size: 12,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        groupTitle,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.brown.shade100,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${items.length} ລາຍການ',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── ແຕ່ລະໄມ້ ──
                              ...items.map(
                                (item) => _productCard(item, isAdmin, controller),
                              ),
                              const SizedBox(height: 8),
                            ],
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

  // ══════════════════════════════════════════════
  // 🎴 ກາດສິນຄ້າ
  // ══════════════════════════════════════════════
  Widget _productCard(
    WoodProductModel item,
    bool isAdmin,
    WoodProductController controller,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.brown.shade100, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ຮູບ ──
            GestureDetector(
              onTap: item.imageUrls.isEmpty
                  ? null
                  : () => Get.to(() => WoodGalleryPage(
                        imageUrls: item.imageUrls,
                        title: item.name,
                      )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrls.isEmpty
                    ? Container(
                        width: 76,
                        height: 76,
                        color: Colors.brown.shade50,
                        child: Icon(Icons.image_not_supported,
                            color: Colors.brown.shade300, size: 28),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.imageUrls.first,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(
                          width: 76,
                          height: 76,
                          color: Colors.brown.shade50,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.brown),
                            ),
                          ),
                        ),
                        errorWidget: (c, u, e) => Container(
                          width: 76,
                          height: 76,
                          color: Colors.brown.shade50,
                          child: Icon(Icons.broken_image,
                              color: Colors.brown.shade300, size: 28),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // ── ຂໍ້ມູນ ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ຂະໜາດ
                  Row(
                    children: [
                      Icon(Icons.straighten,
                          size: 12, color: Colors.brown.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${formatNum(item.width)} × ${formatNum(item.length)} × ${formatNum(item.thickness)} ${item.sizeUnit}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ຈຳນວນ
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 12, color: Colors.brown.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 💰 ລາຄາຂາຍ — ✅ ປັບ UI ໃໝ່ + Badge "ໃໝ່"
                  _priceBox(item),
                ],
              ),
            ),

            // ── Admin menu ──
            if (isAdmin)
              SizedBox(
                width: 32,
                height: 32,
                child: PopupMenuButton<int>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 22),
                  onSelected: (value) {
                    if (value == 1) {
                      controller.startEdit(item);
                      Get.to(() => WoodProductFormPage(isPage: true));
                    } else if (value == 2) {
                      _confirmDelete(context, controller, item);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Text('ແກ້ໄຂ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text('ລຶບ',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 💰 ກ່ອງລາຄາຂາຍ + Badge "ໃໝ່"
  // ══════════════════════════════════════════════
  Widget _priceBox(WoodProductModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell_outlined,
              size: 14, color: Colors.green.shade800),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label "ລາຄາຂາຍ"
              Text(
                'ລາຄາຂາຍ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  letterSpacing: 0.3,
                ),
              ),
              // ตัวเลขราคา
              AnimatedNumber(
                value: item.price,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800,
                ),
                suffix: ' ກີບ',
                duration: 900,
              ),
            ],
          ),
          // 🆕 Badge "ໃໝ່" — ສະແດງພາຍໃນ 7 ວັນຫຼັງແກ້ລາຄາ
          if (item.isPriceNew) ...[
            const SizedBox(width: 8),
            _newBadge(item.daysSincePriceUpdate),
          ],
        ],
      ),
    );
  }

  // 🆕 Badge "ໃໝ່" — ສີແດງ ເດັ່ນ ພ້ອມ tooltip
  Widget _newBadge(int days) {
    final remain = 7 - days;
    return Tooltip(
      message: 'ອັບເດດລາຄາ $days ວັນກ່ອນ · ອີກ $remain ວັນຈະຫາຍ',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.red.shade800],
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fiber_new,
                color: Colors.white, size: 12),
            const SizedBox(width: 2),
            const Text(
              'ໃໝ່',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🗑 ຢືນຢັນລຶບ
  // ══════════════════════════════════════════════
  void _confirmDelete(
    BuildContext context,
    WoodProductController controller,
    WoodProductModel item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ຢືນຢັນການລຶບ'),
        content: const Text('ຕ້ອງການລຶບຂໍ້ມູນຂະໜາດນີ້ ແມ່ນຫຼືບໍ່?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ຍົກເລີກ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteProduct(item.id);
            },
            child:
                const Text('ລຶບ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}