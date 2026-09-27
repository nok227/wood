// lib/features/wood_products/presentation/pages/wood_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';
import 'package:wood/features/wood_products/presentation/widgets/wood_list_skeleton.dart';
import 'package:wood/core/util/dimension_utils.dart';
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

        // ══════════════════════════════════════════════
        // ✅ Nested grouping: ຊື່ → ຊະນິດ → List ຂະໜາດ
        // ══════════════════════════════════════════════
        final Map<String, Map<String, List<WoodProductModel>>> nested = {};

        for (final item in filteredList) {
          final nameKey = item.name.trim().isEmpty
              ? 'ບໍ່ລະບຸຊື່'
              : item.name.trim();
          final typeKey = item.woodType.trim().isEmpty
              ? 'ບໍ່ລະບຸຊະນິດ'
              : item.woodType.trim();

          nested.putIfAbsent(nameKey, () => {});
          nested[nameKey]!.putIfAbsent(typeKey, () => []);
          nested[nameKey]![typeKey]!.add(item);
        }

        // ✅ ຈັດລຳດັບ ຂະໜາດ (ນ້ອຍ → ໃຫຍ່) ໃນແຕ່ລະຊະນິດ
        nested.forEach((_, typeMap) {
          typeMap.forEach((_, list) {
            list.sort((a, b) {
              final va = a.width * a.length * a.thickness;
              final vb = b.width * b.length * b.thickness;
              return va.compareTo(vb);
            });
          });
        });

        // ✅ ຈັດລຳດັບ ຊື່ — ຕາມຈຳນວນລວມ (ຫຼາຍ → ນ້ອຍ)
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
              // ══════════════════════════════════════════
              // 🔽 ຕົວກັ່ນກອງ
              // ══════════════════════════════════════════
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ກັ່ນກອງ:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
                          fillColor: Colors.brown.shade50,
                          filled: true,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.brown.shade200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.brown.shade200,
                            ),
                          ),
                        ),
                        items: nameOptions
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name == 'ທັງໝົດ' ? 'ທັງໝົດ' : name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
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
                child: nameKeys.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount:
                            displayKeys.length +
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
                          final typeMap = nested[nameKey]!;
                          return _nameGroup(
                            nameKey,
                            typeMap,
                            isAdmin,
                            controller,
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
  // 📦 Group ຊື່ (Level 1)
  // ══════════════════════════════════════════════
  Widget _nameGroup(
    String nameKey,
    Map<String, List<WoodProductModel>> typeMap,
    bool isAdmin,
    WoodProductController controller,
  ) {
    int totalItems = 0;
    int totalTypes = typeMap.length;
    typeMap.forEach((_, l) => totalItems += l.length);

    final typeKeys = typeMap.keys.toList()
      ..sort((a, b) {
        final c = typeMap[b]!.length.compareTo(typeMap[a]!.length);
        return c != 0 ? c : a.compareTo(b);
      });

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.brown.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ຊື່ ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade700, Colors.brown.shade600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameKey,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalTypes ຊະນິດ · $totalItems ລາຍການ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── ແຕ່ລະຊະນິດ (Level 2) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < typeKeys.length; i++) ...[
                  _typeSubHeader(typeKeys[i], typeMap[typeKeys[i]]!.length),
                  const SizedBox(height: 6),
                  ...typeMap[typeKeys[i]]!.map(
                    (item) => _productCard(item, isAdmin, controller),
                  ),
                  if (i < typeKeys.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Subheader ຊະນິດ (Level 2) ──
  Widget _typeSubHeader(String typeKey, int count) {
    final isUnknown = typeKey == 'ບໍ່ລະບຸຊະນິດ';
    final color = isUnknown ? Colors.grey.shade600 : Colors.brown.shade700;
    final bgColor = isUnknown ? Colors.grey.shade100 : Colors.brown.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            isUnknown ? Icons.help_outline : Icons.local_florist,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isUnknown ? typeKey : 'ຊະນິດ: $typeKey',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count ຂະໜາດ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🎴 ກາດສິນຄ້າ (Level 3) — ✅ ມີ 3 ໜ່ວຍ
  // ══════════════════════════════════════════════
  Widget _productCard(
    WoodProductModel item,
    bool isAdmin,
    WoodProductController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade100, width: 1.2),
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
                  : () => Get.to(
                      () => WoodGalleryPage(
                        imageUrls: item.imageUrls,
                        title: item.name,
                      ),
                    ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrls.isEmpty
                    ? Container(
                        width: 82,
                        height: 82,
                        color: Colors.brown.shade50,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.brown.shade300,
                          size: 26,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.imageUrls.first,
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                        memCacheWidth: 136,
                        placeholder: (c, u) => Container(
                          width: 82,
                          height: 82,
                          color: Colors.brown.shade50,
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (c, u, e) => Container(
                          width: 82,
                          height: 82,
                          color: Colors.brown.shade50,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.brown.shade300,
                            size: 26,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),

            // ── ຂໍ້ມູນ ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════
                  // ✅ ຂະໜາດ — ບັນທຶກຕົ້ນສະບັບ + ແປງ 3 ໜ່ວຍ
                  // ═══════════════════════════════════
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 12,
                        color: Colors.brown.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${formatNum(item.width)} × ${formatNum(item.length)} × ${formatNum(item.thickness)} ${item.sizeUnit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // ✅ ແປງໜ່ວຍ — mm → cm · m  /  cm → mm · m  /  m → mm · cm
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2),
                    child: Text(
                      dimConversions(
                        item.width,
                        item.length,
                        item.thickness,
                        item.sizeUnit,
                      ),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.brown.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: Colors.brown.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                  icon: const Icon(Icons.more_vert, size: 20),
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
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Text('ແກ້ໄຂ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text('ລຶບ', style: TextStyle(color: Colors.red)),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
          Icon(Icons.sell_outlined, size: 13, color: Colors.green.shade800),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ລາຄາຂາຍ',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  letterSpacing: 0.3,
                ),
              ),
              AnimatedNumber(
                value: item.price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800,
                ),
                suffix: ' ກີບ',
                duration: 900,
                replayOnRouteChange: true,
              ),
            ],
          ),
          if (item.isPriceNew) ...[
            const SizedBox(width: 6),
            _newBadge(item.daysSincePriceUpdate),
          ],
        ],
      ),
    );
  }

  Widget _newBadge(int days) {
    final remain = 7 - days;
    return Tooltip(
      message: 'ອັບເດດລາຄາ $days ວັນກ່ອນ · ອີກ $remain ວັນຈະຫາຍ',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            const Icon(Icons.fiber_new, color: Colors.white, size: 11),
            const SizedBox(width: 2),
            const Text(
              'ໃໝ່',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
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
            child: const Text('ລຶບ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
