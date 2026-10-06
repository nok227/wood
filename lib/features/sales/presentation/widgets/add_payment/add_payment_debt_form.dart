import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/number_formatter.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

class AddPaymentDebtForm extends StatelessWidget {
  final TextEditingController nameC;
  final TextEditingController phoneC;
  final TextEditingController addrC;
  final TextEditingController debtNoteC;
  final TextEditingController debtPaidC;
  final String debtType;
  final double debtPaid;
  final double net;
  final double debtReal;
  final DateTime? apptDate;
  final TimeOfDay? apptTime;
  final File? debtImg;
  final File? debtBillImg;
  final void Function(String) onDebtTypeChanged;
  final void Function(double) onDebtPaidChanged;
  final VoidCallback onPickAppt;
  final void Function() onPickDebtImg;
  final void Function() onClearDebtImg;
  final void Function() onPickDebtBill;
  final void Function() onClearDebtBill;
  final void Function() onClearAppt;

  const AddPaymentDebtForm({
    super.key,
    required this.nameC,
    required this.phoneC,
    required this.addrC,
    required this.debtNoteC,
    required this.debtPaidC,
    required this.debtType,
    required this.debtPaid,
    required this.net,
    required this.debtReal,
    required this.apptDate,
    required this.apptTime,
    required this.debtImg,
    required this.debtBillImg,
    required this.onDebtTypeChanged,
    required this.onDebtPaidChanged,
    required this.onPickAppt,
    required this.onPickDebtImg,
    required this.onClearDebtImg,
    required this.onPickDebtBill,
    required this.onClearDebtBill,
    required this.onClearAppt,
  });

  @override
  Widget build(BuildContext context) {
    final canPay = debtType == 'cash' || debtType == 'transfer';
    final fmt = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RowLabel(Icons.payments_outlined, SaleStyle.debtFormTitle),
        SaleStyle.gapSm,
        Row(children: [
          Expanded(child: _dChip(SaleStyle.cashLabel, Icons.payments_outlined, 'cash')),
          SaleStyle.gapSm,
          Expanded(child: _dChip(SaleStyle.transferLabel, Icons.account_balance, 'transfer')),
          SaleStyle.gapSm,
          Expanded(child: _dChip('ຍັງບໍ່ຈ່າຍ', Icons.schedule, 'none')),
        ]),
        if (canPay) ...[
          SaleStyle.gapLg,
          const _RowLabel(Icons.numbers, SaleStyle.debtPaidLabel),
          SaleStyle.gapSm,
          TextField(
            controller: debtPaidC,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NumberFormatter(),
            ],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.payments, color: SaleStyle.brown700),
              suffixText: SaleStyle.currency,
              helperText:
                  'ຍອດ ${fmt.format(net)} · ເຫຼືອ ${fmt.format(debtReal)}',
              helperStyle: const TextStyle(
                color: SaleStyle.orange800,
                fontWeight: FontWeight.bold,
              ),
            ),
            onChanged: (v) {
              final n = double.tryParse(v.replaceAll(',', '')) ?? 0;
              onDebtPaidChanged(n.clamp(0, net).toDouble());
            },
          ),
          SaleStyle.gapLg,
          const _RowLabel(
            Icons.photo_camera_outlined,
            SaleStyle.debtImgLabel,
          ),
          SaleStyle.gapSm,
          _subImg(
            debtType == 'cash'
                ? SaleStyle.debtImgAddCash
                : SaleStyle.debtImgAddTransfer,
            debtImg,
            debtType == 'cash'
                ? Icons.payments_outlined
                : Icons.receipt_long_outlined,
            onPickDebtImg,
            onClearDebtImg,
          ),
        ],
        SaleStyle.gapLg,
        _RowLabel(
          Icons.event_available,
          canPay ? SaleStyle.debtApptLabelPending : SaleStyle.debtApptLabel,
        ),
        SaleStyle.gapSm,
        InkWell(
          onTap: onPickAppt,
          borderRadius: SaleStyle.r10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: SaleStyle.white,
              borderRadius: SaleStyle.r10,
              border: Border.all(
                color: apptDate == null
                    ? SaleStyle.grey300
                    : SaleStyle.orange400,
                width: apptDate == null ? 1.2 : 2,
              ),
            ),
            child: Row(children: [
              Icon(
                apptDate == null
                    ? Icons.calendar_today_outlined
                    : Icons.calendar_today,
                color: apptDate == null
                    ? SaleStyle.grey600
                    : SaleStyle.orange700,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _apptTxt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: apptDate == null
                        ? SaleStyle.grey600
                        : SaleStyle.orange900,
                  ),
                ),
              ),
              if (apptDate != null)
                GestureDetector(
                  onTap: onClearAppt,
                  child: const Icon(Icons.close, color: SaleStyle.grey600, size: 18),
                )
              else
                const Icon(Icons.arrow_forward_ios,
                    color: SaleStyle.grey400, size: 14),
            ]),
          ),
        ),
        SaleStyle.gapLg,
        const _RowLabel(Icons.person_outline, SaleStyle.debtCustLabel),
        SaleStyle.gapSm,
        _tf(nameC, SaleStyle.debtNameLabel, Icons.person_outline),
        SaleStyle.gapSm,
        _tf(phoneC, SaleStyle.debtPhoneLabel, Icons.phone_outlined,
            type: TextInputType.phone),
        SaleStyle.gapSm,
        _tf(addrC, SaleStyle.debtAddrLabel, Icons.home_outlined, lines: 2),
        SaleStyle.gapSm,
        _tf(debtNoteC, SaleStyle.debtNoteLabel, Icons.sticky_note_2_outlined,
            lines: 2),
        SaleStyle.gapLg,
        const _RowLabel(Icons.receipt_long_outlined, SaleStyle.debtBillLabel),
        const SizedBox(height: 4),
        const Text(
          SaleStyle.debtBillHint,
          style: TextStyle(
            fontSize: 11,
            color: SaleStyle.grey600,
            fontStyle: FontStyle.italic,
          ),
        ),
        SaleStyle.gapSm,
        _subImg(
          SaleStyle.debtBillAdd,
          debtBillImg,
          Icons.receipt_long_outlined,
          onPickDebtBill,
          onClearDebtBill,
          big: true,
        ),
        SaleStyle.gapLg,
        Container(
          padding: SaleStyle.padSection,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SaleStyle.orange100, SaleStyle.orange50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: SaleStyle.r10,
            border: Border.all(color: SaleStyle.orange400, width: 1.5),
          ),
          child: Column(children: [
            _sumRow(SaleStyle.debtTotalSales,
                '${fmt.format(net)} ${SaleStyle.currency}'),
            if (debtPaid > 0) ...[
              const SizedBox(height: 4),
              _sumRow(
                SaleStyle.debtPaidLabel2,
                '-${fmt.format(debtPaid)} ${SaleStyle.currency}',
                color: SaleStyle.green700,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: SaleStyle.orange),
            ),
            Row(children: [
              const Expanded(
                child: Text(
                  SaleStyle.debtRealLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SaleStyle.orange800,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedNumber(
                  value: debtReal,
                  suffix: ' ${SaleStyle.currency}',
                  duration: SaleStyle.animFast.inMilliseconds,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: SaleStyle.orange800,
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ],
    );
  }

  String get _apptTxt {
    if (apptDate == null) return SaleStyle.debtApptPick;
    final d = apptDate!;
    final t = apptTime ?? const TimeOfDay(hour: 9, minute: 0);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Widget _dChip(String label, IconData icon, String value) {
    final sel = debtType == value;
    return InkWell(
      onTap: () => onDebtTypeChanged(value),
      borderRadius: SaleStyle.r10,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: sel ? SaleStyle.orange700 : SaleStyle.white,
          borderRadius: SaleStyle.r10,
          border: Border.all(
            color: sel ? SaleStyle.orange800 : SaleStyle.grey300,
            width: sel ? 2 : 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: sel ? SaleStyle.white : SaleStyle.brown700, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: sel ? SaleStyle.white : SaleStyle.brown800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
    int lines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: SaleStyle.brown700),
      ),
    );
  }

  Widget _subImg(
    String title,
    File? f,
    IconData icon,
    VoidCallback onPick,
    VoidCallback onRm, {
    bool big = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: SaleStyle.brown700,
          ),
        ),
        SaleStyle.gapSm,
        _imgTile(
          '',
          f,
          onPick,
          onRm,
          h: (big && f != null) ? SaleStyle.imgTileHeightXLg : 120,
          fit: big ? BoxFit.contain : BoxFit.cover,
        ),
      ],
    );
  }

  Widget _imgTile(
    String title,
    File? f,
    VoidCallback onTap,
    VoidCallback onRm, {
    double h = SaleStyle.imgTileHeight,
    BoxFit fit = BoxFit.cover,
  }) {
    return InkWell(
      onTap: f == null ? onTap : null,
      borderRadius: SaleStyle.r10,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: fit == BoxFit.contain && f != null
              ? SaleStyle.grey100
              : SaleStyle.grey50,
          borderRadius: SaleStyle.r10,
          border: Border.all(
            color: f == null ? SaleStyle.grey300 : SaleStyle.green700,
            width: f == null ? 1.2 : 2,
          ),
        ),
        child: f != null
            ? Stack(children: [
                ClipRRect(
                  borderRadius: SaleStyle.r10,
                  child: Image.file(
                    f,
                    width: double.infinity,
                    height: double.infinity,
                    fit: fit,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRm,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SaleStyle.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: SaleStyle.white, size: 16),
                    ),
                  ),
                ),
              ])
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: title.isEmpty ? 56 : 38,
                      color: SaleStyle.brown400,
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SaleStyle.brown700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) => Row(children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: SaleStyle.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? SaleStyle.textPrimary,
          ),
        ),
      ]);
}

class _RowLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RowLabel(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: SaleStyle.brown700, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: SaleStyle.brown700,
          ),
        ),
      ]);
}