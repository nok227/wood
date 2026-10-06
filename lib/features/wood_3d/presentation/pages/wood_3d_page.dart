import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/wood_3d_style.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import '../widgets/wood_3d_scene.dart';

class Wood3DPage extends StatefulWidget {
  final ValueNotifier<bool>? swipeLock;
  const Wood3DPage({super.key, this.swipeLock});

  @override
  State<Wood3DPage> createState() => _Wood3DPageState();
}

class _Wood3DPageState extends State<Wood3DPage> {
  final controller = Get.find<WoodProductController>();

  String selectedWoodType = Wood3DStyle.allFilter;
  String selectedUnitFilter = Wood3DStyle.allFilter;
  String? selectedName;
  WoodProduct? selectedVariant;
  String? focusedDimension;
  bool showColor = false;

  bool _panelExpanded = true;

  List<WoodProduct> _cachedProducts = const [];
  int _cachedRevision = -1;
  String _cachedWoodType = '__none__';
  String _cachedUnitFilter = '__none__';
  String? _cachedSelectedName;

  List<WoodProduct> _cachedFiltered = const [];
  List<String> _cachedWoodTypeOptions = const [Wood3DStyle.allFilter];
  List<String> _cachedUnitOptions = const [Wood3DStyle.allFilter];
  List<String> _cachedNames = const [];
  List<WoodProduct> _cachedVariants = const [];

  bool? _lastLockValue;

  // ⭐ ແປງ Model → Entity ຄັ້ງດຽວ
  //    (ຖ້າ controller ຄືນ List<WoodProduct> ແລ້ວ → ລຶບ helper ນີ້)
  List<WoodProduct> _productsAsEntities() => controller.products.toList();

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  String _fmtPrice(num v) {
    String text = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  bool get _hasAnyChoice =>
      selectedWoodType != Wood3DStyle.allFilter ||
      selectedUnitFilter != Wood3DStyle.allFilter ||
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
      selectedWoodType = Wood3DStyle.allFilter;
      selectedUnitFilter = Wood3DStyle.allFilter;
      selectedName = null;
      selectedVariant = null;
      focusedDimension = null;
      _cachedWoodType = '__none__';
      _cachedUnitFilter = '__none__';
      _cachedSelectedName = null;
    });
  }

  void _recomputeIfNeeded(List<WoodProduct> products, int revision) {
    final changed =
        !identical(_cachedProducts, products) ||
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

    final byUnitOnly = selectedUnitFilter == Wood3DStyle.allFilter
        ? products
        : products.where((p) => p.unit.contains(selectedUnitFilter)).toList();

    final byTypeOnly = selectedWoodType == Wood3DStyle.allFilter
        ? products
        : products.where((p) => p.woodType.trim() == selectedWoodType).toList();

    final byBoth = products.where((p) {
      if (selectedWoodType != Wood3DStyle.allFilter &&
          p.woodType.trim() != selectedWoodType) {
        return false;
      }
      if (selectedUnitFilter != Wood3DStyle.allFilter &&
          !p.unit.contains(selectedUnitFilter)) {
        return false;
      }
      return true;
    }).toList();

    final typeSet =
        byUnitOnly
            .map((p) => p.woodType.trim())
            .where((t) => t.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    _cachedWoodTypeOptions = [Wood3DStyle.allFilter, ...typeSet];

    final unitSet = byTypeOnly
        .map((p) => p.unit.trim())
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();
    if (unitSet.any((u) => u.contains('ວົງ')) && !unitSet.contains('ວົງ')) {
      unitSet.add('ວົງ');
    }
    unitSet.sort((a, b) => a.length.compareTo(b.length));
    _cachedUnitOptions = [Wood3DStyle.allFilter, ...unitSet];

    if (selectedWoodType != Wood3DStyle.allFilter &&
        !_cachedWoodTypeOptions.contains(selectedWoodType)) {
      selectedWoodType = Wood3DStyle.allFilter;
      _cachedWoodType = Wood3DStyle.allFilter;
    }
    if (selectedUnitFilter != Wood3DStyle.allFilter &&
        !_cachedUnitOptions.contains(selectedUnitFilter)) {
      selectedUnitFilter = Wood3DStyle.allFilter;
      _cachedUnitFilter = Wood3DStyle.allFilter;
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
      _cachedVariants = _cachedFiltered
          .where((p) => p.name == selectedName)
          .toList();

      if (_cachedVariants.isEmpty) {
        selectedVariant = null;
      } else {
        final matched = _cachedVariants.where(
          (v) => v.id == selectedVariant?.id,
        );
        selectedVariant = matched.isNotEmpty
            ? matched.first
            : _cachedVariants.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final allProducts = _productsAsEntities();
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
                      color: Wood3DStyle.brown50,
                      child: const Center(
                        child: Text(
                          Wood3DStyle.wood3dPlaceholder,
                          style: Wood3DStyle.txPlaceholder,
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

  Widget _buildBottomPanel(bool hasSelection, List<WoodProduct> allProducts) {
    return AnimatedSize(
      duration: Wood3DStyle.normal,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Wood3DStyle.white,
          boxShadow: [
            BoxShadow(
              color: Wood3DStyle.black.withOpacity(
                Wood3DStyle.panelShadowOpacity,
              ),
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
                  padding: Wood3DStyle.padPanelRow,
                  child: Row(
                    children: [
                      Expanded(
                        child: _dimButton(Wood3DStyle.dimWidth, 'width'),
                      ),
                      Wood3DStyle.gap8,
                      Expanded(
                        child: _dimButton(Wood3DStyle.dimLength, 'length'),
                      ),
                      Wood3DStyle.gap8,
                      Expanded(
                        child: _dimButton(
                          Wood3DStyle.dimThickness,
                          'thickness',
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: Wood3DStyle.padPanelBottom,
                child: allProducts.isEmpty
                    ? const Padding(
                        padding: Wood3DStyle.padEmpty,
                        child: Text(
                          Wood3DStyle.noProductsForm,
                          style: Wood3DStyle.txPlaceholder,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionLabel(
                            Wood3DStyle.woodTypeLabel,
                            Icons.local_florist,
                          ),
                          Wood3DStyle.gap6,
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
                          Wood3DStyle.gap12,
                          _sectionLabel(
                            Wood3DStyle.unitLabel,
                            Icons.straighten,
                          ),
                          Wood3DStyle.gap6,
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
                          Wood3DStyle.gap12,
                          _sectionLabel(
                            Wood3DStyle.nameLabel,
                            Icons.inventory_2_outlined,
                          ),
                          Wood3DStyle.gap6,
                          _compactDropdown<String>(
                            label: null,
                            hint: _cachedNames.isEmpty
                                ? Wood3DStyle.noNameInCategory
                                : Wood3DStyle.pickWoodName,
                            value: selectedName,
                            items: _cachedNames
                                .map(
                                  (n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(
                                      n,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
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
                            Wood3DStyle.gap12,
                            _variantInfoCard(),
                          ],
                          if (_hasAnyChoice) ...[
                            Wood3DStyle.gap6,
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _clearAll,
                                icon: const Icon(
                                  Icons.clear_all,
                                  size: Wood3DStyle.iconStar14,
                                ),
                                label: const Text(
                                  Wood3DStyle.clearSelection,
                                  style: Wood3DStyle.txClearBtn,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Wood3DStyle.error700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
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
        Icon(icon, size: Wood3DStyle.iconStar14, color: Wood3DStyle.brown500),
        Wood3DStyle.gap5,
        Text(text, style: Wood3DStyle.txSectionLabel),
      ],
    );
  }

  Widget _chipRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return SizedBox(
      height: Wood3DStyle.chipRowH,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((opt) {
            final isSel = opt == selected;
            final label = opt == Wood3DStyle.allFilter
                ? Wood3DStyle.allFilter
                : opt;

            return Padding(
              padding: Wood3DStyle.padChipRight,
              child: ChoiceChip(
                showCheckmark: false,
                avatar: isSel
                    ? const Icon(
                        Icons.check_circle,
                        size: Wood3DStyle.iconStar13,
                        color: Wood3DStyle.brown700,
                      )
                    : null,
                label: Text(
                  label,
                  style:
                      (isSel ? Wood3DStyle.txChipSelected : Wood3DStyle.txChip)
                          .copyWith(
                            color: isSel
                                ? Wood3DStyle.brown900
                                : Wood3DStyle.brown700,
                          ),
                ),
                selected: isSel,
                selectedColor: Wood3DStyle.brown100,
                backgroundColor: Wood3DStyle.brown50,
                side: BorderSide(
                  color: isSel ? Wood3DStyle.brown400 : Wood3DStyle.brown200,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: Wood3DStyle.padChipInner,
                labelPadding: Wood3DStyle.padChipLabel,
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
        hintStyle: const TextStyle(color: Wood3DStyle.grey500, fontSize: 13),
        isDense: true,
        filled: true,
        fillColor: Wood3DStyle.brown50.withOpacity(
          Wood3DStyle.dropdownFillOpacity,
        ),
        contentPadding: Wood3DStyle.padDropdown,
        border: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown200),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: Wood3DStyle.r10,
          borderSide: BorderSide(color: Wood3DStyle.brown500, width: 1.5),
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
      padding: Wood3DStyle.padCard,
      decoration: BoxDecoration(
        color: Wood3DStyle.brown50,
        borderRadius: Wood3DStyle.r12,
        border: Border.all(color: Wood3DStyle.brown200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                Wood3DStyle.sizeLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Wood3DStyle.gap8,
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WoodProduct>(
                    value: v,
                    isExpanded: true,
                    isDense: true,
                    items: _cachedVariants
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${_fmt(item.width)}×${_fmt(item.length)}×${_fmt(item.thickness)} ${item.sizeUnit}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
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
                Wood3DStyle.priceLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Text(
                '${_fmtPrice(v.price)} ${Wood3DStyle.currency}',
                style: Wood3DStyle.txInfoPrice,
              ),
            ],
          ),
          Wood3DStyle.gap4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                Wood3DStyle.qtyLabelColon,
                style: Wood3DStyle.txInfoLabel,
              ),
              Text('${v.quantity} ${v.unit}', style: Wood3DStyle.txInfoQty),
            ],
          ),
          if (v.zones.isNotEmpty) ...[
            Wood3DStyle.gap6,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  Wood3DStyle.zoneLabelColon,
                  style: Wood3DStyle.txInfoLabel,
                ),
                Wood3DStyle.gap8,
                Expanded(
                  child: Wrap(
                    spacing: Wood3DStyle.wrapSpacing,
                    runSpacing: Wood3DStyle.wrapRunSpacing,
                    children: v.zones
                        .map(
                          (z) => Container(
                            padding: Wood3DStyle.padZoneChip,
                            decoration: BoxDecoration(
                              color: Wood3DStyle.white,
                              borderRadius: Wood3DStyle.r4,
                              border: Border.all(color: Wood3DStyle.brown200),
                            ),
                            child: Text(z, style: Wood3DStyle.txZone),
                          ),
                        )
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
        padding: const EdgeInsets.symmetric(
          vertical: Wood3DStyle.panelHandlePadV,
        ),
        color: Wood3DStyle.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Wood3DStyle.sliderHandleW,
              height: Wood3DStyle.sliderHandleH,
              decoration: BoxDecoration(
                color: Wood3DStyle.grey400,
                borderRadius: Wood3DStyle.r2,
              ),
            ),
            Wood3DStyle.gap4,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _panelExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: Wood3DStyle.iconStar14,
                  color: Wood3DStyle.grey500,
                ),
                Wood3DStyle.gap4,
                Text(
                  _panelExpanded
                      ? Wood3DStyle.panelHide
                      : Wood3DStyle.panelShow,
                  style: Wood3DStyle.txPanelHint,
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
        backgroundColor: active ? Wood3DStyle.brown700 : null,
        foregroundColor: active ? Wood3DStyle.white : Wood3DStyle.brown700,
        side: const BorderSide(color: Wood3DStyle.brown700),
      ),
      onPressed: () => setState(() {
        focusedDimension = active ? null : value;
      }),
      child: Text(label),
    );
  }
}
