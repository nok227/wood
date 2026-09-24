// lib/features/wood_products/presentation/pages/wood_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:wood/features/auth/auth_controller.dart';
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

  // 🚀 ตัวแปรควบคุมการเลื่อนและจำกัดจำนวนแสดงผล
  final ScrollController _scrollController = ScrollController();
  int _displayLimit = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // 🚀 ติดตั้ง Listener ตรวจจับการเลื่อน Scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🚀 ฟังก์ชันตรวจจับเมื่อเลื่อนลงมาเกือบสุดหน้าจอ
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  // 🚀 โหลดข้อมูลเพิ่มทีละ 10 รายการ
  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    // หน่วงเวลาเล็กน้อยเพื่อให้แสดง Layout โหลดได้อย่างสมูธ
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
    final currencyFormat = NumberFormat('#,###');
    final bool isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
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

        final Map<String, List<WoodProductModel>> groupedProducts = {};
        for (var item in filteredList) {
          final groupKey =
              '${item.name} (ຊະນິດ: ${item.woodType.isEmpty ? "ບໍ່ລະບຸ" : item.woodType})';
          if (!groupedProducts.containsKey(groupKey)) {
            groupedProducts[groupKey] = [];
          }
          groupedProducts[groupKey]!.add(item);
        }

        groupedProducts.forEach((key, list) {
          list.sort((a, b) {
            final volumeA = a.width * a.length * a.thickness;
            final volumeB = b.width * b.length * b.thickness;
            return volumeA.compareTo(volumeB);
          });
        });

        final groupKeys = groupedProducts.keys.toList();
        // 🚀 ตัดข้อมูลแสดงผลตาม _displayLimit
        final displayKeys = groupKeys.take(_displayLimit).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _displayLimit = 10);
            await controller.fetchProducts();
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.brown.shade50,
                child: Row(
                  children: [
                    const Text(
                      'ກັ່ນກອງຕາມຊື່ໄມ້: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                            horizontal: 12,
                            vertical: 8,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: nameOptions
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name == 'ທັງໝົດ'
                                      ? 'ທັງໝົດ (ສະແດງທັງໝົດ)'
                                      : name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedNameFilter = val;
                              _displayLimit = 10; // รีเซ็ตจำนวณแสดงเมื่อกรองใหม่
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: groupKeys.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        // 🚀 เพิ่ม 1 แถวด้านล่างสุดสำหรับแสดงตัวโหลดกำลังโหลดข้อมูล
                        itemCount: displayKeys.length +
                            (_isLoadingMore && displayKeys.length < groupKeys.length ? 1 : 0),
                        itemBuilder: (context, gIndex) {
                          // 🚀 หากเป็นแถบล่างสุดขณะกำลังโหลด ให้แสดง CircularProgressIndicator
                          if (gIndex == displayKeys.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.brown,
                                ),
                              ),
                            );
                          }

                          final groupTitle = displayKeys[gIndex];
                          final items = groupedProducts[groupTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 12,
                                  bottom: 6,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 18,
                                      color: Colors.brown,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      groupTitle,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${items.length} 规格',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...items.map(
                                (item) => Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: item.imageUrls.isEmpty
                                              ? null
                                              : () => Get.to(
                                                  () => WoodGalleryPage(
                                                    imageUrls: item.imageUrls,
                                                    title: item.name,
                                                  ),
                                                ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: item.imageUrls.isEmpty
                                                ? Container(
                                                    width: 65,
                                                    height: 65,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        item.imageUrls.first,
                                                    width: 65,
                                                    height: 65,
                                                    fit: BoxFit.cover,
                                                    placeholder: (c, u) =>
                                                        const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget: (c, u, e) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ຂະໜາດ: ${formatNum(item.width)} × ${formatNum(item.length)} × ${formatNum(item.thickness)} ${item.sizeUnit}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ຈຳນວນ: ${item.quantity} ${item.unit}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ລາຄາ: ${currencyFormat.format(item.price)} ກີບ',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isAdmin)
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: PopupMenuButton<int>(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.more_vert,
                                                size: 22,
                                              ),
                                              onSelected: (value) {
                                                if (value == 1) {
                                                  controller.startEdit(item);
                                                  Get.to(
                                                    () => WoodProductFormPage(
                                                      isPage: true,
                                                    ),
                                                  );
                                                } else if (value == 2) {
                                                  _confirmDelete(
                                                    context,
                                                    controller,
                                                    item,
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text('ແກ້ໄຂ'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'ລົບ',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
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

  void _confirmDelete(
    BuildContext context,
    WoodProductController controller,
    WoodProductModel item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ຍືນຍັນການລົບ'),
        content: const Text('ຕ້ອງການລົບຂໍ້ມູນຂະໜາດນີ້ ແມ່ນຫຼືບໍ່?'),
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
            child: const Text('ລົບ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}