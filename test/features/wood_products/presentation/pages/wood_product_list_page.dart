// lib/features/wood_products/presentation/pages/wood_product_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/util/blinking_badge.dart';
import '../../../auth/auth_controller.dart';
import '../widgets/animated_number.dart';
import '../widgets/wood_list_skeleton.dart';
import '../../../../core/util/dimension_utils.dart';
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

        // Nested grouping
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

        // ✅ ຈັດລຳດັບຕາມລາຄາຂາຍ ຫຼາຍ → ໜ້ອຍ (ບໍ່ໃຊ່ volume)
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
              // ── Filter ──
              // ── Filter (Chip style) ──
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ຫົວຂໍ້ ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ກັ່ນກອງ:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Chip list ເລື່ອນແນວນອນ ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: nameOptions.map((name) {
                          final selected = selectedNameFilter == name;
                          final label =
                              name == 'ທັງໝົດ' ? 'ທັງໝົດ' : name;

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              showCheckmark: false,
                              avatar: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.brown.shade700,
                                    )
                                  : null,
                              label: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: selected
                                      ? Colors.brown.shade900
                                      : Colors.brown.shade700,
                                ),
                              ),
                              selected: selected,
                              selectedColor: Colors.brown.shade100,
                              backgroundColor: Colors.brown.shade50,
                              side: BorderSide(
                                color: selected
                                    ? Colors.brown.shade400
                                    : Colors.brown.shade200,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedNameFilter = name;
                                  _displayLimit = 10;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── List ──
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade700, Colors.brown.shade600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameKey,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$totalTypes ຊະນິດ · $totalItems ລາຍການ',
                        style: TextStyle(
                          fontSize: 10.5,
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
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < typeKeys.length; i++) ...[
                  _typeSubHeader(typeKeys[i], typeMap[typeKeys[i]]!.length),
                  const SizedBox(height: 4),

                  for (int j = 0; j < typeMap[typeKeys[i]]!.length; j++) ...[
                    _productCard(typeMap[typeKeys[i]]![j], isAdmin, controller),
                    if (j < typeMap[typeKeys[i]]!.length - 1) _dashedDivider(),
                  ],

                  if (i < typeKeys.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── เส้นขีดคั่น ──
  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashSpace = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
  

  // ── Subheader ຊະນິດ ──
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
  // 🎴 ກາດສິນຄ້າ (Level 3)
  // ══════════════════════════════════════════════
  Widget _productCard(
  WoodProductModel item,
  bool isAdmin,
  WoodProductController controller,
) {
  final hasNote = item.note.trim().isNotEmpty;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── ຮູບ 9:16 ──
        _SwipeableImage(
          imageUrls: item.imageUrls,
          width: 72,
          height: 148,
          onTap: item.imageUrls.isEmpty
              ? null
              : () => Get.to(
                  () => WoodGalleryPage(
                    imageUrls: item.imageUrls,
                    title: item.name,
                  ),
                ),
        ),
        const SizedBox(width: 10),

        // ── ຂໍ້ມູນ ──
        Expanded(
          child: SizedBox(
            height: 148,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── ຫົວ: ຂະໜາດ + ໝາຍເຫດ icon ──
                    Row(
                      children: [
                        Text(
                          'ຂະໜາດ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (hasNote) ...[
                          const SizedBox(width: 5),
                          // 🆕 icon ໝາຍເຫດ ພ້ອມ tooltip
                          Tooltip(
                            message: item.note.trim(),
                            triggerMode: TooltipTriggerMode.tap,
                            preferBelow: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.amber.shade400),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sticky_note_2_outlined,
                                    size: 9,
                                    color: Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'ໝາຍເຫດ',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${formatNum(item.width)} × ${formatNum(item.length)} × ${formatNum(item.thickness)} ${item.sizeUnit}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // ແປງໜ່ວຍ
                    _conversionColumn(item),

                    // ໂຊນ
                    const SizedBox(height: 4),
                    _zoneLine(item),

                    const SizedBox(height: 5),

                    // ຈຳນວນ
                    Text(
                      'ຈຳນວນ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ລາຄາ: ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      AnimatedNumber(
                        value: item.price,
                        suffix: ' ກີບ',
                        duration: 900,
                        replayOnRouteChange: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (item.isPriceNew) ...[
                        const SizedBox(width: 5),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: BlinkingBadge(
                            text: 'ລ່າສຸດ',
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Admin menu ──
        if (isAdmin)
          SizedBox(
            width: 28,
            height: 28,
            child: PopupMenuButton<int>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: Colors.grey.shade600,
              ),
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
  );
}

  // 🆕 ໝາຍເຫດ — ແຖວສີເຫຼືອງນ້ອຍໆ
  Widget _noteLine(String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.sticky_note_2_outlined,
          size: 11,
          color: Colors.amber.shade800,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            note,
            style: TextStyle(
              fontSize: 10,
              color: Colors.amber.shade900,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // ໂຊນ — ສະແດງສະເໝີ
  // ══════════════════════════════════════════════
  Widget _zoneLine(WoodProductModel item) {
    if (item.zones.isEmpty) {
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'ໂຊນ: ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: 'ບໍ່ລະບຸ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final displayZones = item.zones.take(4).toList();
    final remaining = item.zones.length - displayZones.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'ໂຊນ: ',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...displayZones.map(
                (z) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.brown.shade200),
                  ),
                  child: Text(
                    z,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
              ),
              if (remaining > 0)
                Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.brown.shade400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // ✅ ແປງໜ່ວຍເປັນ Column
  // ══════════════════════════════════════════════
  Widget _conversionColumn(WoodProductModel item) {
    final conversions = dimConversions(
      item.width,
      item.length,
      item.thickness,
      item.sizeUnit,
    ).split('·').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (conversions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: conversions.map((line) {
        return Text(
          line,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }).toList(),
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

// ══════════════════════════════════════════════
// 🖼️ ຮູບທີ່ປັດໄດ້ (Swipeable)
// ══════════════════════════════════════════════
class _SwipeableImage extends StatefulWidget {
  final List<String> imageUrls;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _SwipeableImage({
    required this.imageUrls,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<_SwipeableImage> createState() => _SwipeableImageState();
}

class _SwipeableImageState extends State<_SwipeableImage> {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ),
        ),
      );
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            PageView.builder(
              key: ValueKey('pv-${widget.imageUrls.first}'),
              controller: _pageCtrl,
              physics: const PageScrollPhysics(),
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[i],
                  fit: BoxFit.contain,
                  memCacheWidth: 216,
                  placeholder: (c, u) => const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  errorWidget: (c, u, e) => Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ),
              ),
            ),

            if (hasMultiple)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.imageUrls.length, (i) {
                      final active = _current == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: active ? 6 : 4,
                        height: active ? 6 : 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.brown.shade700
                              : Colors.white.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),

            if (hasMultiple)
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_current + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}