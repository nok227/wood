import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/widgets/number_formatter.dart';
import '../../domain/entities/account_transaction.dart';

class AccountFormSheet extends StatefulWidget {
  final String initialType;
  final Future<void> Function(AccountTransaction) onSubmit;

  const AccountFormSheet({
    super.key,
    required this.initialType,
    required this.onSubmit,
  });

  @override
  State<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<AccountFormSheet> {
  final fmt = NumberFormat('#,###');

  late String type;
  String payType = 'cash';

  final recvC = TextEditingController();
  final noteC = TextEditingController();
  late List<Map<String, TextEditingController>> rows;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    rows = [
      {'name': TextEditingController(), 'price': TextEditingController()},
    ];
  }

  @override
  void dispose() {
    recvC.dispose();
    noteC.dispose();
    for (final r in rows) {
      r['name']!.dispose();
      r['price']!.dispose();
    }
    super.dispose();
  }

  double get _payTotal {
    double t = 0;
    for (final r in rows) {
      t += double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
    }
    return t;
  }

  bool get _isIn => type == 'in';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: Get.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        _isIn ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isIn
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: _isIn
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isIn ? 'ຮັບເງິນ' : 'ຈ່າຍເງິນ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _isIn
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.grey.shade600, size: 22),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _tBtn('ຮັບເຂົ້າ', Icons.arrow_downward_rounded,
                        Colors.green.shade700, _isIn,
                        () => setState(() => type = 'in'))),
                const SizedBox(width: 8),
                Expanded(
                    child: _tBtn('ຈ່າຍອອກ', Icons.arrow_upward_rounded,
                        Colors.red.shade700, !_isIn,
                        () => setState(() => type = 'out'))),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isIn) _recvContent() else _payContent(),
                    const SizedBox(height: 14),
                    const Text('ປະເພດເງິນ *',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _tBtn('ເງິນສົດ',
                                Icons.payments_outlined,
                                Colors.amber.shade800,
                                payType == 'cash',
                                () => setState(() => payType = 'cash'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _tBtn('ເງິນໂອນ',
                                Icons.account_balance,
                                Colors.blue.shade700,
                                payType == 'transfer',
                                () => setState(() => payType = 'transfer'))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: noteC,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'ໝາຍເຫດ (ຖ້າມີ)',
                        labelStyle: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.brown.shade400, width: 1.5),
                        ),
                        isDense: true,
                        prefixIcon: Icon(Icons.sticky_note_2_outlined,
                            color: Colors.brown.shade400, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIn
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: Text(
                    _isIn ? 'ບັນທຶກຮັບເງິນ' : 'ບັນທຶກຈ່າຍເງິນ',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recvContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ຈຳນວນເງິນທີ່ຮັບ *',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: recvC,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            NumberFormatter(),
          ],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.green.shade400, width: 2),
            ),
            prefixIcon:
                Icon(Icons.numbers, color: Colors.green.shade600),
            suffixText: 'ກີບ',
            suffixStyle: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _payContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ລາຍການທີ່ຈ່າຍ *',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        ...rows.asMap().entries.map((e) {
          final idx = e.key;
          final r = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: r['name'],
                    decoration: InputDecoration(
                      labelText: 'ລາຍການ ${idx + 1}',
                      labelStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: r['price'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      NumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'ລາຄາ',
                      labelStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                      suffixText: 'ກີບ',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (rows.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        r['name']!.dispose();
                        r['price']!.dispose();
                        rows.removeAt(idx);
                      });
                    },
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.red.shade600, size: 22),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown.shade700,
            side: BorderSide(color: Colors.brown.shade300),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => setState(() {
            rows.add({
              'name': TextEditingController(),
              'price': TextEditingController()
            });
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('ເພີ່ມລາຍການ',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.summarize_outlined,
                  color: Colors.red.shade700, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text('ລວມທັງໝົດ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade700)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${fmt.format(_payTotal)} ກີບ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade700,
                        letterSpacing: 0.2)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tBtn(String l, IconData i, Color c, bool sel, VoidCallback tap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? c : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? c : Colors.grey.shade300,
              width: sel ? 0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: sel ? Colors.white : c, size: 16),
              const SizedBox(width: 5),
              Text(l,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : c,
                      letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final items = <AccountItem>[];

    if (_isIn) {
      final amount =
          double.tryParse(recvC.text.replaceAll(',', '')) ?? 0;
      if (amount <= 0) {
        Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຈຳນວນເງິນ');
        return;
      }
      items.add(AccountItem(
        name: payType == 'cash' ? 'ຮັບເງິນສົດ' : 'ຮັບເງິນໂອນ',
        price: amount,
      ));
    } else {
      for (final r in rows) {
        final n = r['name']!.text.trim();
        final p = double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
        if (n.isEmpty || p <= 0) continue;
        items.add(AccountItem(name: n, price: p));
      }
      if (items.isEmpty) {
        Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຢ່າງໜ້ອຍ 1 ລາຍການ');
        return;
      }
    }

    final tx = AccountTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      paymentType: payType,
      items: items,
      note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
      date: DateTime.now(),
    );

    Get.back();
    await widget.onSubmit(tx);
  }
}