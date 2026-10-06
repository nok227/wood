import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/core/widgets/global/number_formatter.dart';

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
      padding: AccountStyle.padFormSheet,
      constraints: BoxConstraints(
        maxHeight: Get.height * AccountStyle.formMaxHeightFactor,
      ),
      decoration: const BoxDecoration(
        color: AccountStyle.surface,
        borderRadius: AccountStyle.topR20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Handle ──
            Center(
              child: Container(
                width: AccountStyle.handleW,
                height: AccountStyle.handleH,
                decoration: BoxDecoration(
                  color: AccountStyle.grey300,
                  borderRadius: AccountStyle.r4,
                ),
              ),
            ),
            AccountStyle.gapMd,

            // ── Header ──
            Row(
              children: [
                Container(
                  width: AccountStyle.iconCircleSize,
                  height: AccountStyle.iconCircleSize,
                  decoration: BoxDecoration(
                    color: _isIn
                        ? AccountStyle.successLight
                        : AccountStyle.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isIn
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: _isIn
                        ? AccountStyle.success
                        : AccountStyle.error700,
                    size: AccountStyle.iconMd,
                  ),
                ),
                AccountStyle.gapSm,
                Expanded(
                  child: Text(
                    _isIn ? AccountStyle.receiveBtn : AccountStyle.payBtn,
                    style: AccountStyle.formTitle.copyWith(
                      color: _isIn
                          ? AccountStyle.green800
                          : AccountStyle.error800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AccountStyle.grey600, size: 22),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            AccountStyle.gapSm,

            // ── Type toggle ──
            Row(
              children: [
                Expanded(
                  child: _tBtn(AccountStyle.typeIn,
                      Icons.arrow_downward_rounded,
                      AccountStyle.success, _isIn,
                      () => setState(() => type = 'in')),
                ),
                AccountStyle.gapSm,
                Expanded(
                  child: _tBtn(AccountStyle.typeOut,
                      Icons.arrow_upward_rounded,
                      AccountStyle.error700, !_isIn,
                      () => setState(() => type = 'out')),
                ),
              ],
            ),
            AccountStyle.gapLg,

            // ── Content ──
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isIn) _recvContent() else _payContent(),
                    AccountStyle.gapLg,

                    const Text(AccountStyle.paymentTypeLabel,
                        style: AccountStyle.sectionLabel),
                    AccountStyle.gap6,
                    Row(
                      children: [
                        Expanded(
                          child: _tBtn(AccountStyle.cashFull,
                              Icons.payments_outlined,
                              AccountStyle.amber800,
                              payType == 'cash',
                              () => setState(() => payType = 'cash')),
                        ),
                        AccountStyle.gapSm,
                        Expanded(
                          child: _tBtn(AccountStyle.transferFull,
                              Icons.account_balance,
                              AccountStyle.blue700,
                              payType == 'transfer',
                              () => setState(() => payType = 'transfer')),
                        ),
                      ],
                    ),
                    AccountStyle.gapLg,

                    TextField(
                      controller: noteC,
                      maxLines: 2,
                      decoration: _inputDeco(
                        label: AccountStyle.noteLabel,
                        prefix: Icons.sticky_note_2_outlined,
                      ),
                    ),
                    AccountStyle.gapLg,
                  ],
                ),
              ),
            ),

            // ── Save button ──
            SizedBox(
              height: AccountStyle.saveButtonHeight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIn
                      ? AccountStyle.success
                      : AccountStyle.error700,
                  foregroundColor: AccountStyle.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: AccountStyle.r12),
                ),
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _isIn
                      ? AccountStyle.saveReceiveBtn
                      : AccountStyle.savePayBtn,
                  style: AccountStyle.formSaveBtnText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Receive content ──
  Widget _recvContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AccountStyle.amountLabel,
            style: AccountStyle.sectionLabel),
        AccountStyle.gap6,
        TextField(
          controller: recvC,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            NumberFormatter(),
          ],
          style: AccountStyle.amountInput,
          decoration: InputDecoration(
            hintText: AccountStyle.zeroHint,
            hintStyle: const TextStyle(
              color: AccountStyle.grey400,
              fontWeight: FontWeight.w600,
            ),
            border: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide: BorderSide(color: AccountStyle.grey300),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide: BorderSide(color: AccountStyle.grey300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AccountStyle.inputRadius,
              borderSide:
                  BorderSide(color: AccountStyle.green400, width: 2),
            ),
            prefixIcon: const Icon(Icons.numbers,
                color: AccountStyle.green600),
            suffixText: AccountStyle.currency,
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AccountStyle.grey600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Pay content ──
  Widget _payContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AccountStyle.itemsLabel,
            style: AccountStyle.sectionLabel),
        AccountStyle.gap6,
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
                    decoration: _inputDeco(
                      label: '${AccountStyle.itemPrefix} ${idx + 1}',
                      focusColor: AccountStyle.red400,
                      contentPad: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                AccountStyle.gap6,
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: r['price'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      NumberFormatter(),
                    ],
                    decoration: _inputDeco(
                      label: AccountStyle.priceLabel,
                      suffix: AccountStyle.currency,
                      focusColor: AccountStyle.red400,
                      contentPad: const EdgeInsets.symmetric(
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
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AccountStyle.red600, size: 22),
                  ),
              ],
            ),
          );
        }),
        AccountStyle.gapXs,
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AccountStyle.brown700,
            side: const BorderSide(color: AccountStyle.brown300),
            padding: AccountStyle.padAddItem,
            shape: const RoundedRectangleBorder(
                borderRadius: AccountStyle.inputRadius),
          ),
          onPressed: () => setState(() {
            rows.add({
              'name': TextEditingController(),
              'price': TextEditingController(),
            });
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text(AccountStyle.addItemBtn,
              style: AccountStyle.addItemBtnText),
        ),
        AccountStyle.gap10,

        // ── Total ──
        Container(
          padding: AccountStyle.padTotalBox,
          decoration: BoxDecoration(
            color: AccountStyle.errorLight,
            borderRadius: AccountStyle.inputRadius,
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize_outlined,
                  color: AccountStyle.error700, size: 18),
              AccountStyle.gap6,
              const Expanded(
                child: Text(AccountStyle.totalLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AccountStyle.error700)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                    '${fmt.format(_payTotal)} ${AccountStyle.currency}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AccountStyle.error700,
                        letterSpacing: 0.2)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Toggle button ──
  Widget _tBtn(String l, IconData i, Color c, bool sel, VoidCallback tap) {
    return Material(
      color: AccountStyle.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: AccountStyle.inputRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? c : AccountStyle.white,
            borderRadius: AccountStyle.inputRadius,
            border: Border.all(
              color: sel ? c : AccountStyle.grey300,
              width: sel ? 0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: sel ? AccountStyle.white : c, size: 16),
              const SizedBox(width: 5),
              Text(l, style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: sel ? AccountStyle.white : c,
                  letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input decoration helper ──
  InputDecoration _inputDeco({
    required String label,
    IconData? prefix,
    String? suffix,
    Color focusColor = AccountStyle.brown400,
    EdgeInsets? contentPad,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AccountStyle.inputLabel,
      suffixText: suffix,
      isDense: true,
      border: const OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: AccountStyle.grey300),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: AccountStyle.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AccountStyle.inputRadius,
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      contentPadding: contentPad,
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: AccountStyle.brown400, size: 20),
    );
  }

  Future<void> _onSave() async {
    final items = <AccountItem>[];

    if (_isIn) {
      final amount =
          double.tryParse(recvC.text.replaceAll(',', '')) ?? 0;
      if (amount <= 0) {
        Get.snackbar(
            AccountStyle.alertTitle, AccountStyle.alertAmount);
        return;
      }
      items.add(AccountItem(
        name: payType == 'cash'
            ? AccountStyle.receiveCash
            : AccountStyle.receiveTransfer,
        price: amount,
      ));
    } else {
      for (final r in rows) {
        final n = r['name']!.text.trim();
        final p =
            double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
        if (n.isEmpty || p <= 0) continue;
        items.add(AccountItem(name: n, price: p));
      }
      if (items.isEmpty) {
        Get.snackbar(
            AccountStyle.alertTitle, AccountStyle.alertMinItem);
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