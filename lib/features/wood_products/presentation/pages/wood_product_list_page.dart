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

class _WoodProductListPageState extends State<WoodProductListPage> {
  String selectedNameFilter = 'ທັງໝົດ';

  String formatNum(num v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WoodProductController>();
    final currencyFormat = NumberFormat('#,###');

    // 🔐 เช็คสิทธิ์ Admin จากจุดเดียว (AuthController)
    final bool isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ລາຍການໄມ້ໃນຄັງ'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const WoodListSkeleton();
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('ຍັງບໍ່ມີຂໍ້ມູນສິນຄ້າໄມ້'));
        }

        // 1. ดึงรายชื่อไม้ที่ไม่ซ้ำกันมาทำ Dropdown
        final allNames = controller.products
            .map((p) => p.name.trim())
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();
        final nameOptions = ['ທັງໝົດ', ...allNames];

        // 2. กรองตามชื่อไม้ที่เลือก
        final filteredList = selectedNameFilter == 'ທັງໝົດ'
            ? controller.products.toList()
            : controller.products
                .where((p) => p.name.trim() == selectedNameFilter)
                .toList();

        // 3. จัดกลุ่มรายการไม้ตาม "ชื่อไม้ + ชนิดไม้"
        final Map<String, List<WoodProductModel>> groupedProducts = {};
        for (var item in filteredList) {
          final groupKey = '${item.name} (ຊະນິດ: ${item.woodType.isEmpty ? "ບໍ່ລະບຸ" : item.woodType})';
          if (!groupedProducts.containsKey(groupKey)) {
            groupedProducts[groupKey] = [];
          }
          groupedProducts[groupKey]!.add(item);
        }

        // 4. เรียงลำดับรายการไม้ภายในแต่ละกลุ่มตามขนาด
        groupedProducts.forEach((key, list) {
          list.sort((a, b) {
            final volumeA = a.width * a.length * a.thickness;
            final volumeB = b.width * b.length * b.thickness;
            return volumeA.compareTo(volumeB);
          });
        });

        final groupKeys = groupedProducts.keys.toList();

        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: Column(
            children: [
              // 🔽 แถบ Dropdown กรองตามชื่อไม้
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.brown.shade50,
                child: Row(
                  children: [
                    const Text(
                      'ກັ່ນກອງຕາມຊື່ໄມ້: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                            .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name == 'ທັງໝົດ' ? 'ທັງໝົດ (ສະແດງທັງໝົດ)' : name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedNameFilter = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 รายการไม้แสดงผลแยกตามหมวดหมู่
              Expanded(
                child: groupKeys.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: groupKeys.length,
                        itemBuilder: (context, gIndex) {
                          final groupTitle = groupKeys[gIndex];
                          final items = groupedProducts[groupTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header ประจำหมวด
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 12,
                                  bottom: 6,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.category,
                                        size: 18, color: Colors.brown),
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

                              // รายการไม้ภายในหมวด
                              ...items.map((item) => Card(
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
                                          // รูปภาพสินค้า
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (c, u, e) =>
                                                          const Icon(
                                                              Icons.broken_image),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // รายละเอียดขนาด/จำนวน/ราคา
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ຂະໜາດ: ${formatNum(item.width)} × ${formatNum(item.length)} × ${formatNum(item.thickness)} ${item.sizeUnit}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600,
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

                                          // 🔴 แสดงปุ่มแก้ไข / ลบ เฉพาะ Admin เท่านั้น
                                          if (isAdmin)
                                            SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: PopupMenuButton<int>(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.more_vert,
                                                    size: 22),
                                                onSelected: (value) {
                                                  if (value == 1) {
                                                    controller.startEdit(item);
                                                    Get.to(() =>
                                                        WoodProductFormPage());
                                                  } else if (value == 2) {
                                                    _confirmDelete(
                                                        context, controller, item);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 1,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            color: Colors.blue,
                                                            size: 20),
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
                                                            color: Colors.red,
                                                            size: 20),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          'ລົບ',
                                                          style: TextStyle(
                                                              color: Colors.red),
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
                                  )),
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