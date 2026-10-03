import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/widgets/animated_number.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
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
            child: CircularProgressIndicator(color: Colors.brown),
          ),
        );
      }

      final allProducts = pc.products;
      if (allProducts.isEmpty) {
        return _emptyBox('ຍັງບໍ່ມີລາຍການໄມ້ໃນຄັງ');
      }

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
      final unitList = <String>['ທັງໝົດ', ...unitOptions];

      final currentUnit = unitList.contains(unitFilter) ? unitFilter : 'ທັງໝົດ';

      final filteredProducts = currentUnit == 'ທັງໝົດ'
          ? allProducts.toList()
          : allProducts.where((p) => p.unit.contains(currentUnit)).toList();

      final names = filteredProducts.map((p) => p.name).toSet().toList();
      if (names.isEmpty) return _emptyBox('ຍັງບໍ່ມີລາຍການໄມ້ໃນຄັງ');

      final woodVariants = wood == null
          ? <WoodProductModel>[]
          : filteredProducts.where((p) => p.name == wood).toList();

      final types = wood == null
          ? <String>[]
          : woodVariants
              .map(
                (p) => p.woodType.trim().isEmpty ? 'ບໍ່ລະບຸ' : p.woodType,
              )
              .toSet()
              .toList()
        ..sort();

      final list = (wood == null || type == null)
          ? <WoodProductModel>[]
          : (woodVariants.where((p) {
              final t =
                  p.woodType.trim().isEmpty ? 'ບໍ່ລະບຸ' : p.woodType;
              return t == type;
            }).toList())
            ..sort((a, b) => b.price.compareTo(a.price));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: currentUnit,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ໜ່ວຍນັບ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten, color: Colors.brown),
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
                      u == 'ທັງໝົດ' ? 'ທັງໝົດ (ໜ່ວຍ)' : u,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              onUnitFilterChanged(v ?? 'ທັງໝົດ');
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: wood,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ຊື່ໄມ້ *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category, color: Colors.brown),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            hint: const Text('ເລືອກຊື່ໄມ້'),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ຊະນິດໄມ້ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist, color: Colors.brown),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              hint: const Text('ເລືອກຊະນິດ'),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: c.selectedProduct.value?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ຂະໜາດ / ລາຄາ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten, color: Colors.brown),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              hint: const Text('ເລືອກຂະໜາດ'),
              items: list
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ${fmt.format(p.price)} ກີບ',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                c.selectedProduct.value =
                    list.firstWhere((p) => p.id == id);
              },
            ),
          ],
          if (c.selectedProduct.value != null) ...[
            const SizedBox(height: 12),
            _selectedPreview(c.selectedProduct.value!, fmt),
            const SizedBox(height: 12),
            _qtyRow(),
            if (disc > 0) ...[const SizedBox(height: 12), _discView()],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onAddItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  'ເພີ່ມລາຍການນີ້ · $qty ${c.selectedProduct.value?.unit ?? ""}',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey.shade500,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedPreview(WoodProductModel p, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade50, Colors.brown.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.brown.shade700,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
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
                    color: Colors.brown.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ຄົງເຫຼືອ ${p.quantity} ${p.unit}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedNumber(
            value: p.price,
            suffix: ' ກີບ',
            duration: 900,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.brown.shade800,
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'ຈຳນວນ *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers, color: Colors.brown),
                suffixText: p.unit,
                isDense: true,
              ),
              onChanged: (v) => onQtyChanged(
                (int.tryParse(v) ?? 1).clamp(1, 99999),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: discC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'ລົດ/ຕົວ',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.discount, color: Colors.brown, size: 18),
                suffixText: 'ກີບ',
                isDense: true,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount, color: Colors.red.shade700, size: 18),
              const SizedBox(width: 6),
              Text(
                'ສ່ວນລົດຂອງລາຍການນີ້',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _discRow(
            '${fmt.format(p.price)} × $qty',
            '${fmt.format(gross)} ກີບ',
            Colors.black87,
          ),
          const SizedBox(height: 4),
          _discRow(
            'ລົດ ${fmt.format(disc)} × $qty',
            '-${fmt.format(discTot)} ກີບ',
            Colors.red.shade700,
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
                  'ຍອດສຸດທິ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              AnimatedNumber(
                value: net,
                suffix: ' ກີບ',
                duration: 900,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
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