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

  // ══════════════════════════════════════════════
  // ✅ Memoization cache
  // ══════════════════════════════════════════════
  List<WoodProductModel> _cachedProducts = const [];
  String _cachedWoodType = '__none__';
  List<WoodProductModel> _cachedFiltered = const [];
  List<String> _cachedWoodTypeOptions = const ['ທັງໝົດ'];
  List<String> _cachedNames = const [];
  List<WoodProductModel> _cachedVariants = const [];

  // ✅ ປ້ອງກັນ _syncSwipeLock schedule ຊ້ຳ
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
      _cachedWoodType = '__none__'; // ✅ invalidate
    });
  }

  // ══════════════════════════════════════════════
  // ✅ ຄຳນວນໃໝ່ສະເພາະເວລາຂໍ້ມູນ ຫຼື filter ປ່ຽນ
  // ══════════════════════════════════════════════
  void _recomputeIfNeeded(List<WoodProductModel> products) {
    final sourceChanged = !identical(_cachedProducts, products);
    final filterChanged = _cachedWoodType != selectedWoodType;

    if (sourceChanged || filterChanged) {
      _cachedProducts = products;
      _cachedWoodType = selectedWoodType;

      // Wood types
      final types = products
          .map((p) => p.woodType.trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();
      _cachedWoodTypeOptions = ['ທັງໝົດ', ...types];

      // Filtered products
      _cachedFiltered = selectedWoodType == 'ທັງໝົດ'
          ? products
          : products
              .where((p) => p.woodType.trim() == selectedWoodType)
              .toList();

      // Names
      _cachedNames = _cachedFiltered.map((p) => p.name).toSet().toList();

      // Validate selectedName
      if (selectedName != null && !_cachedNames.contains(selectedName)) {
        selectedName = null;
        selectedVariant = null;
      }
    }

    // Variants — ຄຳນວນທຸກຄັ້ງທີ່ selectedName ປ່ຽນ (ໄວ ເພາະ _cachedFiltered ຖືກ cache)
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
            if (hasSelection)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _colorButton(),
                ),
              ),
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
            if (hasSelection)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                                  // selectedVariant ຈະຖືກອັບເດດໃນ _recomputeIfNeeded
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
                                    .map((v) =>
                                        DropdownMenuItem<WoodProductModel>(
                                          value: v,
                                          child: Text(
                                            '${_fmt(v.width)}×${_fmt(v.length)}×${_fmt(v.thickness)} ${v.sizeUnit}',
                                            overflow: TextOverflow.ellipsis,
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
        );
      }),
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

  Widget _colorButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: showColor ? Colors.brown : null,
        foregroundColor: showColor ? Colors.white : Colors.brown,
        side: const BorderSide(color: Colors.brown),
      ),
      onPressed: () => setState(() => showColor = !showColor),
      icon: const Icon(Icons.palette, size: 18),
      label: const Text('ສີ'),
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