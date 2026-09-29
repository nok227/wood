import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import '../widgets/wood_3d_scene.dart';

class Wood3DPage extends StatefulWidget {
  final ValueNotifier<bool>? swipeLock;
  const Wood3DPage({super.key, this.swipeLock});

  @override
  State<Wood3DPage> createState() => _Wood3DPageState();
}

class _Wood3DPageState extends State<Wood3DPage> {
  final controller = Get.find<WoodProductController>();

  String selectedWoodType = 'ທັງໝົດ';
  String? selectedName;
  WoodProductModel? selectedVariant;
  String? focusedDimension;
  bool showColor = false;

  // ✅ ໃໝ່: ສະຖານະຂອງ panel ລຸ່ມ
  bool _panelExpanded = true;

  // Memoization cache
  List<WoodProductModel> _cachedProducts = const [];
  String _cachedWoodType = '__none__';
  List<WoodProductModel> _cachedFiltered = const [];
  List<String> _cachedWoodTypeOptions = const ['ທັງໝົດ'];
  List<String> _cachedNames = const [];
  List<WoodProductModel> _cachedVariants = const [];

  bool? _lastLockValue;

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  bool get _hasAnyChoice =>
      selectedWoodType != 'ທັງໝົດ' ||
      selectedName != null ||
      selectedVariant != null;

  void _syncSwipeLock(bool locked) {
    final lock = widget.swipeLock;
    if (lock == null) return;
    if (lock.value == locked) {
      _lastLockValue = locked;
      return;
    }
    if (_lastLockValue == locked) return;
    _lastLockValue = locked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = widget.swipeLock;
      if (l != null && l.value != locked) l.value = locked;
    });
  }

  void _clearAll() {
    setState(() {
      selectedWoodType = 'ທັງໝົດ';
      selectedName = null;
      selectedVariant = null;
      focusedDimension = null;
      _cachedWoodType = '__none__';
    });
  }

  void _recomputeIfNeeded(List<WoodProductModel> products) {
    final sourceChanged = !identical(_cachedProducts, products);
    final filterChanged = _cachedWoodType != selectedWoodType;

    if (sourceChanged || filterChanged) {
      _cachedProducts = products;
      _cachedWoodType = selectedWoodType;

      final types = products
          .map((p) => p.woodType.trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();
      _cachedWoodTypeOptions = ['ທັງໝົດ', ...types];

      _cachedFiltered = selectedWoodType == 'ທັງໝົດ'
          ? products
          : products
              .where((p) => p.woodType.trim() == selectedWoodType)
              .toList();

      _cachedNames = _cachedFiltered.map((p) => p.name).toSet().toList();

      if (selectedName != null && !_cachedNames.contains(selectedName)) {
        selectedName = null;
        selectedVariant = null;
      }
    }

    if (selectedName == null) {
      _cachedVariants = const [];
      selectedVariant = null;
    } else {
      _cachedVariants =
          _cachedFiltered.where((p) => p.name == selectedName).toList();

      if (_cachedVariants.isEmpty) {
        selectedVariant = null;
      } else {
        final matched =
            _cachedVariants.where((v) => v.id == selectedVariant?.id);
        selectedVariant =
            matched.isNotEmpty ? matched.first : _cachedVariants.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final allProducts = controller.products;
        _recomputeIfNeeded(allProducts);

        final hasSelection = selectedVariant != null;
        _syncSwipeLock(_hasAnyChoice);

        return Column(
          children: [
            // ✅ ລຶບປຸ່ມສີທີ່ຢູ່ຂ້າງເທິງອອກແລ້ວ
            Expanded(
              child: hasSelection
                  ? RepaintBoundary(
                      child: Wood3DScene(
                        key: ValueKey(selectedVariant!.id),
                        productName: selectedVariant!.name,
                        width: selectedVariant!.width,
                        length: selectedVariant!.length,
                        thickness: selectedVariant!.thickness,
                        sizeUnit: selectedVariant!.sizeUnit,
                        unit: selectedVariant!.unit,
                        focusedDimension: focusedDimension,
                        showColor: showColor,
                        onToggleColor: () =>
                            setState(() => showColor = !showColor),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.brown[50],
                      child: const Center(
                        child: Text(
                          'ພື້ນທີ່ສະແດງໂມເດວໄມ້ 3D',
                          style:
                              TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                      ),
                    ),
            ),

            // ✅ Panel ລຸ່ມ — ຊ່ອນ/ສະແດງໄດ້
            _buildBottomPanel(hasSelection, allProducts),
          ],
        );
      }),
    );
  }

  // ══════════════════════════════════════════════
  // ✅ Panel ລຸ່ມ — ປັດຂຶ້ນ/ລົງ ຫຼື ແຕະ ເພື່ອຊ່ອນ/ສະແດງ
  // ══════════════════════════════════════════════
  Widget _buildBottomPanel(
    bool hasSelection,
    List<WoodProductModel> allProducts,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _panelHandle(),
            if (_panelExpanded) ...[
              // dim buttons (ກວ້າງ/ຍາວ/ໜາ)
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(child: _dimButton('ກວ້າງ', 'width')),
                      const SizedBox(width: 8),
                      Expanded(child: _dimButton('ຍາວ', 'length')),
                      const SizedBox(width: 8),
                      Expanded(child: _dimButton('ໜາ', 'thickness')),
                    ],
                  ),
                ),
              // Dropdowns
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: allProducts.isEmpty
                    ? const Text(
                        'ຍັງບໍ່ມີຂໍ້ມູນໃນຄັງ ກະລຸນາເພີ່ມຂໍ້ມູນກ່ອນ',
                        style: TextStyle(color: Colors.black54),
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedWoodType,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'ຊະນິດໄມ້',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: _cachedWoodTypeOptions
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type == 'ທັງໝົດ'
                                                  ? 'ທັງໝົດ (ສະແດງທັງໝົດ)'
                                                  : type,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    selectedWoodType = v ?? 'ທັງໝົດ';
                                    selectedName = null;
                                    selectedVariant = null;
                                    focusedDimension = null;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _clearButton(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedName,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'ຊື່ໄມ້',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  hint: const Text('ເລືອກຊື່ໄມ້'),
                                  items: _cachedNames
                                      .map((n) => DropdownMenuItem(
                                            value: n,
                                            child: Text(n,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    selectedName = v;
                                    focusedDimension = null;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child:
                                    DropdownButtonFormField<WoodProductModel>(
                                  value: selectedVariant,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'ຂະໜາດ',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  hint: const Text('ເລືອກຂະໜາດ'),
                                  items: _cachedVariants
                                      .map((v) => DropdownMenuItem<
                                              WoodProductModel>(
                                            value: v,
                                            child: Text(
                                              '${_fmt(v.width)}×${_fmt(v.length)}×${_fmt(v.thickness)} ${v.sizeUnit}',
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: selectedName == null
                                      ? null
                                      : (v) => setState(() {
                                            selectedVariant = v;
                                            focusedDimension = null;
                                          }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ Handle bar — ແຕະ ຫຼື ປັດ ເພື່ອຊ່ອນ/ສະແດງ
  Widget _panelHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _panelExpanded = !_panelExpanded),
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 200 && _panelExpanded) {
          setState(() => _panelExpanded = false);
        } else if (v < -200 && !_panelExpanded) {
          setState(() => _panelExpanded = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _panelExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _panelExpanded
                      ? 'ປັດລົງ ຫຼື ແຕະ ເພື່ອຊ່ອນ'
                      : 'ປັດຂຶ້ນ ຫຼື ແຕະ ເພື່ອສະແດງ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _clearButton() {
    final enabled = _hasAnyChoice;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: enabled ? Colors.red : Colors.black12),
        ),
        onPressed: enabled ? _clearAll : null,
        icon: const Icon(Icons.clear_all, size: 18),
        label: const Text('ລ້າງ'),
      ),
    );
  }

  Widget _dimButton(String label, String value) {
    final active = focusedDimension == value;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? Colors.brown : null,
        foregroundColor: active ? Colors.white : Colors.brown,
        side: const BorderSide(color: Colors.brown),
      ),
      onPressed: () => setState(() {
        focusedDimension = active ? null : value;
      }),
      child: Text(label),
    );
  }
}