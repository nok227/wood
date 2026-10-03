import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
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
  String selectedUnitFilter = 'ທັງໝົດ';
  String? selectedName;
  WoodProductModel? selectedVariant;
  String? focusedDimension;
  bool showColor = false;

  bool _panelExpanded = true;

  // ─── Cache ───
  List<WoodProductModel> _cachedProducts = const [];
  int _cachedRevision = -1;
  String _cachedWoodType = '__none__';
  String _cachedUnitFilter = '__none__';
  String? _cachedSelectedName;

  List<WoodProductModel> _cachedFiltered = const [];
  List<String> _cachedWoodTypeOptions = const ['ທັງໝົດ'];
  List<String> _cachedUnitOptions = const ['ທັງໝົດ'];
  List<String> _cachedNames = const [];
  List<WoodProductModel> _cachedVariants = const [];

  bool? _lastLockValue;

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  String _fmtPrice(num v) {
    String text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  bool get _hasAnyChoice =>
      selectedWoodType != 'ທັງໝົດ' ||
      selectedUnitFilter != 'ທັງໝົດ' ||
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
      selectedUnitFilter = 'ທັງໝົດ';
      selectedName = null;
      selectedVariant = null;
      focusedDimension = null;
      _cachedWoodType = '__none__';
      _cachedUnitFilter = '__none__';
      _cachedSelectedName = null;
    });
  }

  void _recomputeIfNeeded(List<WoodProductModel> products, int revision) {
    final changed = !identical(_cachedProducts, products) ||
        _cachedRevision != revision ||
        _cachedWoodType != selectedWoodType ||
        _cachedUnitFilter != selectedUnitFilter ||
        _cachedSelectedName != selectedName;

    if (!changed) return;

    _cachedProducts = products;
    _cachedRevision = revision;
    _cachedWoodType = selectedWoodType;
    _cachedUnitFilter = selectedUnitFilter;
    _cachedSelectedName = selectedName;

    final byUnitOnly = selectedUnitFilter == 'ທັງໝົດ'
        ? products
        : products
            .where((p) => p.unit.contains(selectedUnitFilter))
            .toList();

    final byTypeOnly = selectedWoodType == 'ທັງໝົດ'
        ? products
        : products
            .where((p) => p.woodType.trim() == selectedWoodType)
            .toList();

    final byBoth = products.where((p) {
      if (selectedWoodType != 'ທັງໝົດ' &&
          p.woodType.trim() != selectedWoodType) {
        return false;
      }
      if (selectedUnitFilter != 'ທັງໝົດ' &&
          !p.unit.contains(selectedUnitFilter)) {
        return false;
      }
      return true;
    }).toList();

    final typeSet = byUnitOnly
        .map((p) => p.woodType.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    _cachedWoodTypeOptions = ['ທັງໝົດ', ...typeSet];

    final unitSet = byTypeOnly
        .map((p) => p.unit.trim())
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();
    if (unitSet.any((u) => u.contains('ວົງ')) && !unitSet.contains('ວົງ')) {
      unitSet.add('ວົງ');
    }
    unitSet.sort((a, b) => a.length.compareTo(b.length));
    _cachedUnitOptions = ['ທັງໝົດ', ...unitSet];

    if (selectedWoodType != 'ທັງໝົດ' &&
        !_cachedWoodTypeOptions.contains(selectedWoodType)) {
      selectedWoodType = 'ທັງໝົດ';
      _cachedWoodType = 'ທັງໝົດ';
    }
    if (selectedUnitFilter != 'ທັງໝົດ' &&
        !_cachedUnitOptions.contains(selectedUnitFilter)) {
      selectedUnitFilter = 'ທັງໝົດ';
      _cachedUnitFilter = 'ທັງໝົດ';
    }

    _cachedFiltered = byBoth;
    _cachedNames = byBoth.map((p) => p.name).toSet().toList()..sort();

    if (selectedName != null && !_cachedNames.contains(selectedName)) {
      selectedName = null;
      selectedVariant = null;
      _cachedSelectedName = null;
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
        final revision = controller.productsRevision.value;
        _recomputeIfNeeded(allProducts, revision);

        final hasSelection = selectedVariant != null;
        _syncSwipeLock(_hasAnyChoice);

        return Column(
          children: [
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
            _buildBottomPanel(hasSelection, allProducts),
          ],
        );
      }),
    );
  }

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
            _panelHandle(hasSelection),
            if (_panelExpanded) ...[
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                child: allProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'ຍັງບໍ່ມີຂໍ້ມູນໃນຄັງ ກະລຸນາເພີ່ມຂໍ້ມູນກ່ອນ',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionLabel('ຊະນິດໄມ້', Icons.local_florist),
                          const SizedBox(height: 6),
                          _chipRow(
                            options: _cachedWoodTypeOptions,
                            selected: selectedWoodType,
                            onSelected: (v) => setState(() {
                              selectedWoodType = v;
                              selectedName = null;
                              selectedVariant = null;
                              focusedDimension = null;
                            }),
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('ໜ່ວຍນັບ', Icons.straighten),
                          const SizedBox(height: 6),
                          _chipRow(
                            options: _cachedUnitOptions,
                            selected: selectedUnitFilter,
                            onSelected: (v) => setState(() {
                              selectedUnitFilter = v;
                              selectedName = null;
                              selectedVariant = null;
                              focusedDimension = null;
                            }),
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('ຊື່ໄມ້', Icons.inventory_2_outlined),
                          const SizedBox(height: 6),
                          _compactDropdown<String>(
                            label: null,
                            hint: _cachedNames.isEmpty
                                ? 'ບໍ່ມີຊື່ໃນໝວດນີ້'
                                : 'ເລືອກຊື່ໄມ້',
                            value: selectedName,
                            items: _cachedNames
                                .map((n) => DropdownMenuItem(
                                      value: n,
                                      child: Text(n,
                                          overflow:
                                              TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: _cachedNames.isEmpty
                                ? null
                                : (v) => setState(() {
                                      selectedName = v;
                                      focusedDimension = null;
                                    }),
                          ),
                          if (selectedName != null &&
                              _cachedVariants.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _variantInfoCard(),
                          ],
                          if (_hasAnyChoice) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _clearAll,
                                icon: const Icon(Icons.clear_all, size: 14),
                                label: const Text(
                                  'ລ້າງການເລືອກ',
                                  style: TextStyle(fontSize: 11.5),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.brown.shade600),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.brown.shade700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _chipRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((opt) {
            final isSel = opt == selected;
            final label = opt == 'ທັງໝົດ' ? 'ທັງໝົດ' : opt;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: isSel
                    ? Icon(
                        Icons.check_circle,
                        size: 13,
                        color: Colors.brown.shade700,
                      )
                    : null,
                label: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                    color: isSel
                        ? Colors.brown.shade900
                        : Colors.brown.shade700,
                  ),
                ),
                selected: isSel,
                selectedColor: Colors.brown.shade100,
                backgroundColor: Colors.brown.shade50,
                side: BorderSide(
                  color: isSel
                      ? Colors.brown.shade400
                      : Colors.brown.shade200,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                onSelected: (_) => onSelected(opt),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _compactDropdown<T>({
    String? label,
    String? hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.brown.shade50.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.brown.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.brown.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.brown.shade500, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _variantInfoCard() {
    final v = selectedVariant;
    if (v == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'ຂະໜາດ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WoodProductModel>(
                    value: v,
                    isExpanded: true,
                    isDense: true,
                    items: _cachedVariants
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                '${_fmt(item.width)}×${_fmt(item.length)}×${_fmt(item.thickness)} ${item.sizeUnit}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: (nv) => setState(() {
                      selectedVariant = nv;
                      focusedDimension = null;
                    }),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ລາຄາ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '${_fmtPrice(v.price)} ກີບ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ຈຳນວນ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '${v.quantity} ${v.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (v.zones.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ໂຊນ:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: v.zones
                        .map((z) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.brown.shade200),
                              ),
                              child: Text(
                                z,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _panelHandle(bool hasSelection) {
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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