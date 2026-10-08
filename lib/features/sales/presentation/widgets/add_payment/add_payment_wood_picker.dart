import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/number_formatter.dart'; // ← ใหม่
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (pc.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
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

      final types =
          wood == null
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

      final list =
          (wood == null || type == null)
                ? <WoodProduct>[]
                : (woodVariants.where((p) {
                    final t = p.woodType.trim().isEmpty
                        ? SaleStyle.woodUnnamedType
                        : p.woodType;
                    return t == type;
                  }).toList())
            ..sort((a, b) => b.price.compareTo(a.price));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: currentUnit,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: SaleStyle.woodUnit,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten, color: SaleStyle.brown700),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items: unitList
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u,
                    child: Text(
                      u == SaleStyle.woodStatusAll ? SaleStyle.woodUnitAll : u,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => onUnitFilterChanged(v ?? SaleStyle.woodStatusAll),
          ),
          SaleStyle.gapMd,
          DropdownButtonFormField<String>(
            initialValue: wood,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: SaleStyle.woodName,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category, color: SaleStyle.brown700),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            hint: const Text(SaleStyle.woodNameHint),
            items: names
                .map(
                  (n) => DropdownMenuItem<String>(
                    value: n,
                    child: Text(
                      n,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            onChanged: onWoodChanged,
          ),
          if (wood != null) ...[
            SaleStyle.gapMd,
            DropdownButtonFormField<String>(
              initialValue: type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: SaleStyle.woodType,
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.local_florist,
                  color: SaleStyle.brown700,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              hint: const Text(SaleStyle.woodTypeHint),
              items: types
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onTypeChanged,
            ),
          ],
          if (type != null && list.isNotEmpty) ...[
            SaleStyle.gapMd,
            DropdownButtonFormField<String>(
              initialValue: c.selectedProduct.value?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: SaleStyle.woodSize,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten, color: SaleStyle.brown700),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              hint: const Text(SaleStyle.woodSizeHint),
              items: list
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ${fmt.format(p.price)} ${SaleStyle.currency}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                c.selectedProduct.value = list.firstWhere((p) => p.id == id);
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

  Widget _emptyBox(String text) {
    return Container(
      padding: SaleStyle.padAll16,
      decoration: BoxDecoration(
        color: SaleStyle.grey50,
        borderRadius: SaleStyle.r10,
        border: Border.all(color: SaleStyle.grey300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: SaleStyle.grey500,
            size: 24,
          ),
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
        gradient: const LinearGradient(
          colors: [SaleStyle.brown50, SaleStyle.brown100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: SaleStyle.r10,
        border: Border.all(color: SaleStyle.brown300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: SaleStyle.brown700,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: SaleStyle.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
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
                  style: const TextStyle(
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
            style: const TextStyle(
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
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.numbers,
                  color: SaleStyle.brown700,
                ),
                suffixText: p.unit,
                isDense: true,
              ),
              // ✅ แก้: ลบจุดก่อน parse
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
              decoration: const InputDecoration(
                labelText: SaleStyle.pricePerUnit,
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.discount,
                  color: SaleStyle.brown700,
                  size: 18,
                ),
                suffixText: SaleStyle.currency,
                isDense: true,
              ),
              onChanged: (v) => onDiscChanged(
                (double.tryParse(v.replaceAll(',', '')) ?? 0).clamp(
                  0,
                  double.infinity,
                ),
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
        border: Border.all(color: SaleStyle.red300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.discount, color: SaleStyle.red700, size: 18),
              const SizedBox(width: 6),
              const Text(
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

  Widget _discRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
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
