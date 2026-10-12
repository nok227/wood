import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/number_formatter.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import '../../controllers/sales_controller.dart';

class AddPaymentWoodPicker extends StatelessWidget {
  final SalesController c;
  final WoodProductController pc;
  final NumberFormat fmt;
  final String? wood;
  final String? type;
  final String unitFilter;
  final int qty;
  final double disc;
  final TextEditingController qtyC;
  final TextEditingController discC;
  final ValueChanged<String?> onWoodChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String> onUnitFilterChanged;
  final ValueChanged<int> onQtyChanged;
  final ValueChanged<double> onDiscChanged;
  final VoidCallback onAddItem;

  const AddPaymentWoodPicker({
    super.key,
    required this.c,
    required this.pc,
    required this.fmt,
    required this.wood,
    required this.type,
    required this.unitFilter,
    required this.qty,
    required this.disc,
    required this.qtyC,
    required this.discC,
    required this.onWoodChanged,
    required this.onTypeChanged,
    required this.onUnitFilterChanged,
    required this.onQtyChanged,
    required this.onDiscChanged,
    required this.onAddItem,
  });

  /// key ที่ไม่รวม zone → ถ้าต่างกันแค่ zone ถือว่าเป็น "สินค้าเดียวกัน"
  static String _variantKey(WoodProduct p) =>
      '${p.woodType}|${p.name}|'
      '${p.width}|${p.length}|${p.thickness}|${p.sizeUnit}|'
      '${p.price}|${p.unit}|${p.note}';

  /// ⭐ input ที่สะอาด — underline อย่างเดียว ไม่มีกล่อง
  static InputDecoration _deco(String label, IconData icon, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: SaleStyle.grey300, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: SaleStyle.brown700, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: SaleStyle.brown700, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (pc.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(color: SaleStyle.brown700),
          ),
        );
      }

      final allProducts = pc.products;
      if (allProducts.isEmpty) return _emptyBox(SaleStyle.woodEmpty);

      final unitSet = <String>{};
      for (final p in allProducts) {
        final u = p.unit.trim();
        if (u.isNotEmpty) unitSet.add(u);
      }
      if (unitSet.any((u) => u.contains('ວົງ')) && !unitSet.contains('ວົງ')) {
        unitSet.add('ວົງ');
      }
      final unitOptions = unitSet.toList()
        ..sort((a, b) => a.length.compareTo(b.length));
      final unitList = <String>[SaleStyle.woodStatusAll, ...unitOptions];

      final currentUnit = unitList.contains(unitFilter)
          ? unitFilter
          : SaleStyle.woodStatusAll;

      final filteredProducts = currentUnit == SaleStyle.woodStatusAll
          ? allProducts.toList()
          : allProducts.where((p) => p.unit.contains(currentUnit)).toList();

      final names = filteredProducts.map((p) => p.name).toSet().toList();
      if (names.isEmpty) return _emptyBox(SaleStyle.woodEmpty);
      final woodVariants = wood == null
          ? <WoodProduct>[]
          : filteredProducts.where((p) => p.name == wood).toList();

      final types = wood == null
          ? <String>[]
          : woodVariants
                .map(
                  (p) => p.woodType.trim().isEmpty
                      ? SaleStyle.woodUnnamedType
                      : p.woodType,
                )
                .toSet()
                .toList()
        ..sort();

      final rawList = (wood == null || type == null)
          ? <WoodProduct>[]
          : (woodVariants.where((p) {
              final t = p.woodType.trim().isEmpty
                  ? SaleStyle.woodUnnamedType
                  : p.woodType;
              return t == type;
            }).toList())
        ..sort((a, b) => b.price.compareTo(a.price));

      // Dedupe: ต่างกันแค่ zone → เหลือ 1
      final seenKeys = <String>{};
      final list = <WoodProduct>[];
      for (final p in rawList) {
        if (seenKeys.add(_variantKey(p))) list.add(p);
      }

      final selected = c.selectedProduct.value;
      final selectedKey = selected == null ? null : _variantKey(selected);
      final initialKey = (selectedKey != null &&
              list.any((p) => _variantKey(p) == selectedKey))
          ? selectedKey
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: currentUnit,
            isExpanded: true,
            decoration: _deco(SaleStyle.woodUnit, Icons.straighten),
            items: unitList
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u,
                    child: Text(
                      u == SaleStyle.woodStatusAll ? SaleStyle.woodUnitAll : u,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => onUnitFilterChanged(v ?? SaleStyle.woodStatusAll),
          ),
          _dashed(),
          DropdownButtonFormField<String>(
            initialValue: wood,
            isExpanded: true,
            decoration: _deco(SaleStyle.woodName, Icons.category,
                hint: SaleStyle.woodNameHint),
            items: names
                .map(
                  (n) => DropdownMenuItem<String>(
                    value: n,
                    child: Text(n,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                )
                .toList(),
            onChanged: onWoodChanged,
          ),
          if (wood != null) ...[
            _dashed(),
            DropdownButtonFormField<String>(
              initialValue: type,
              isExpanded: true,
              decoration: _deco(SaleStyle.woodType, Icons.local_florist,
                  hint: SaleStyle.woodTypeHint),
              items: types
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(t,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )
                  .toList(),
              onChanged: onTypeChanged,
            ),
          ],
          if (type != null && list.isNotEmpty) ...[
            _dashed(),
            DropdownButtonFormField<String>(
              initialValue: initialKey,
              isExpanded: true,
              decoration: _deco(SaleStyle.woodSize, Icons.straighten,
                  hint: SaleStyle.woodSizeHint),
              items: list
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: _variantKey(p),
                      child: Text(
                        '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ${fmt.format(p.price)} ${SaleStyle.currency}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (key) {
                if (key == null) return;
                c.selectedProduct.value =
                    list.firstWhere((p) => _variantKey(p) == key);
              },
            ),
          ],
          if (c.selectedProduct.value != null) ...[
            SaleStyle.gapMd,
            _selectedPreview(c.selectedProduct.value!, fmt),
            SaleStyle.gapMd,
            _qtyRow(),
            if (disc > 0) ...[SaleStyle.gapMd, _discView()],
            SaleStyle.gapMd,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SaleStyle.green700,
                  foregroundColor: SaleStyle.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: SaleStyle.r10,
                  ),
                  elevation: 0,
                ),
                onPressed: onAddItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  '${SaleStyle.woodAddItem} · $qty ${c.selectedProduct.value?.unit ?? ""}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  /// ⭐ เส้นขีดๆ ระหว่างช่อง
  Widget _dashed() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const dashWidth = 4.0;
            const dashSpace = 4.0;
            final count =
                (constraints.maxWidth / (dashWidth + dashSpace)).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                count,
                (_) => Container(
                  width: dashWidth,
                  height: 1,
                  color: SaleStyle.grey300,
                ),
              ),
            );
          },
        ),
      );

  Widget _emptyBox(String text) {
    return Container(
      padding: SaleStyle.padAll16,
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              color: SaleStyle.grey500, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: SaleStyle.grey700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedPreview(WoodProduct p, NumberFormat fmt) {
    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.brown50,
        borderRadius: SaleStyle.r10,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SaleStyle.brown700,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: SaleStyle.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SaleStyle.brown900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ${SaleStyle.woodInStock} ${p.quantity} ${p.unit}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: SaleStyle.brown700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedNumber(
            value: p.price,
            suffix: ' ${SaleStyle.currency}',
            duration: SaleStyle.animFast.inMilliseconds,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: SaleStyle.brown800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyRow() {
    return Obx(() {
      final p = c.selectedProduct.value;
      if (p == null) return const SizedBox.shrink();
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DigitLimitFormatter(4),
                DotNumberFormatter(),
              ],
              decoration: InputDecoration(
                labelText: '${SaleStyle.qtyLabel} *',
                isDense: true,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: SaleStyle.grey300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: SaleStyle.brown700, width: 1.5),
                ),
                prefixIcon: Icon(Icons.numbers,
                    color: SaleStyle.brown700, size: 18),
                suffixText: p.unit,
              ),
              onChanged: (v) {
                final n = int.tryParse(v.replaceAll('.', '')) ?? 1;
                onQtyChanged(n.clamp(1, 9999));
              },
            ),
          ),
          SaleStyle.gapSm,
          Expanded(
            flex: 2,
            child: TextField(
              controller: discC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DigitLimitFormatter(5),
                DotNumberFormatter(),
              ],
              decoration: InputDecoration(
                labelText: SaleStyle.pricePerUnit,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: SaleStyle.grey300),
                ),
                focusedBorder:  UnderlineInputBorder(
                  borderSide: BorderSide(color: SaleStyle.brown700, width: 1.5),
                ),
                prefixIcon:  Icon(Icons.discount,
                    color: SaleStyle.brown700, size: 18),
                suffixText: SaleStyle.currency,
              ),
              onChanged: (v) => onDiscChanged(
                (double.tryParse(v.replaceAll(',', '')) ?? 0)
                    .clamp(0, double.infinity),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _discView() {
    final p = c.selectedProduct.value!;
    final gross = p.price * qty;
    final discTot = disc * qty;
    final net = (gross - discTot).clamp(0, double.infinity);

    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.red50,
        borderRadius: SaleStyle.r10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.discount, color: SaleStyle.red700, size: 18),
              SizedBox(width: 6),
              Text(
                SaleStyle.discountLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: SaleStyle.red700,
                ),
              ),
            ],
          ),
          SaleStyle.gapSm,
          _discRow(
            '${fmt.format(p.price)} × $qty',
            '${fmt.format(gross)} ${SaleStyle.currency}',
            SaleStyle.black87,
          ),
          const SizedBox(height: 4),
          _discRow(
            '${SaleStyle.itemDiscountPrefix} ${fmt.format(disc)} × $qty',
            '-${fmt.format(discTot)} ${SaleStyle.currency}',
            SaleStyle.red700,
            bold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  SaleStyle.netLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SaleStyle.green700,
                  ),
                ),
              ),
              AnimatedNumber(
                value: net,
                suffix: ' ${SaleStyle.currency}',
                duration: SaleStyle.animFast.inMilliseconds,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: SaleStyle.green700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _discRow(String label, String value, Color color,
      {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}