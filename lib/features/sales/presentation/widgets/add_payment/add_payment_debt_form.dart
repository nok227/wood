import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood/core/widgets/number_formatter.dart';
import 'package:wood/core/widgets/animated_number.dart';

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

  static final _fmt = _FmtHelper();

  @override
  Widget build(BuildContext context) {
    final canPay = debtType == 'cash' || debtType == 'transfer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RowLabel(Icons.payments_outlined, 'ລູກຄ້າຈ່າຍກ່ອນຫຼືບໍ່?'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _dChip('ສົດ', Icons.payments_outlined, 'cash')),
            const SizedBox(width: 8),
            Expanded(child: _dChip('ໂອນ', Icons.account_balance, 'transfer')),
            const SizedBox(width: 8),
            Expanded(child: _dChip('ຍັງບໍ່ຈ່າຍ', Icons.schedule, 'none')),
          ],
        ),
        if (canPay) ...[
          const SizedBox(height: 16),
          const _RowLabel(Icons.numbers, 'ຈຳນວນທີ່ຈ່າຍກ່ອນ *'),
          const SizedBox(height: 8),
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
              prefixIcon: const Icon(Icons.payments, color: Colors.brown),
              suffixText: 'ກີບ',
              helperText:
                  'ຍອດ ${_fmt.money(net)} · ເຫຼືອ ${_fmt.money(debtReal)}',
              helperStyle: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onChanged: (v) {
              final n = double.tryParse(v.replaceAll(',', '')) ?? 0;
              onDebtPaidChanged(n.clamp(0, net).toDouble());
            },
          ),
          const SizedBox(height: 16),
          const _RowLabel(
            Icons.photo_camera_outlined,
            'ຮູບເງິນທີ່ຈ່າຍກ່ອນ (ຖ້າມີ)',
          ),
          const SizedBox(height: 8),
          _subImg(
            debtType == 'cash' ? 'ແນບຮູບເງິນສົດ' : 'ແນບຮູບສະລິບ',
            debtImg,
            debtType == 'cash'
                ? Icons.payments_outlined
                : Icons.receipt_long_outlined,
            onPickDebtImg,
            onClearDebtImg,
          ),
        ],
        const SizedBox(height: 16),
        _RowLabel(
          Icons.event_available,
          canPay ? 'ນັດວັນຈ່າຍທີ່ເຫຼືອ' : 'ນັດວັນຈ່າຍ',
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickAppt,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: apptDate == null
                    ? Colors.grey.shade300
                    : Colors.orange.shade400,
                width: apptDate == null ? 1.2 : 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  apptDate == null
                      ? Icons.calendar_today_outlined
                      : Icons.calendar_today,
                  color: apptDate == null
                      ? Colors.grey.shade600
                      : Colors.orange.shade700,
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
                          ? Colors.grey.shade600
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
                if (apptDate != null)
                  GestureDetector(
                    onTap: onClearAppt,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _RowLabel(Icons.person_outline, 'ຂໍ້ມູນລູກຄ້າ'),
        const SizedBox(height: 8),
        _tf(nameC, 'ຊື່ລູກຄ້າ *', Icons.person_outline),
        const SizedBox(height: 8),
        _tf(phoneC, 'ເບີໂທ *', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 8),
        _tf(addrC, 'ທີ່ຢູ່ *', Icons.home_outlined, lines: 2),
        const SizedBox(height: 8),
        _tf(
          debtNoteC,
          'ໝາຍເຫດໜີ້ (ຖ້າມີ)',
          Icons.sticky_note_2_outlined,
          lines: 2,
        ),
        const SizedBox(height: 16),
        const _RowLabel(Icons.receipt_long_outlined, 'ຮູບໃບບິນໜີ້ *'),
        const SizedBox(height: 4),
        Text(
          'ຖ່າຍຮູບໃບບິນທີ່ລູກຄ້າຢືນຢັນການຕິດໜີ້',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        _subImg(
          'ແນບຮູບໃບບິນໜີ້',
          debtBillImg,
          Icons.receipt_long_outlined,
          onPickDebtBill,
          onClearDebtBill,
          big: true,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade100, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade400, width: 1.5),
          ),
          child: Column(
            children: [
              _sumRow('ຍອດຂາຍທັງໝົດ', '${_fmt.money(net)} ກີບ'),
              if (debtPaid > 0) ...[
                const SizedBox(height: 4),
                _sumRow(
                  'ຈ່າຍກ່ອນ',
                  '-${_fmt.money(debtPaid)} ກີບ',
                  color: Colors.green.shade700,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Colors.orange),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ຍອດຕິດໜີ້ຕົວຈິງ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedNumber(
                      value: debtReal,
                      suffix: ' ກີບ',
                      duration: 1000,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _apptTxt {
    if (apptDate == null) return 'ເລືອກວັນ/ເວລານັດ';
    final d = apptDate!;
    final t = apptTime ?? const TimeOfDay(hour: 9, minute: 0);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Widget _dChip(String label, IconData icon, String value) {
    final sel = debtType == value;
    return InkWell(
      onTap: () => onDebtTypeChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: sel ? Colors.orange.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? Colors.orange.shade800 : Colors.grey.shade300,
            width: sel ? 2 : 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: sel ? Colors.white : Colors.brown.shade700,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : Colors.brown.shade800,
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
        prefixIcon: Icon(icon, color: Colors.brown),
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
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 8),
        _imgTile(
          '',
          f,
          onPick,
          onRm,
          h: (big && f != null) ? 320 : 120,
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
    double h = 110,
    BoxFit fit = BoxFit.cover,
  }) {
    return InkWell(
      onTap: f == null ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: fit == BoxFit.contain && f != null
              ? Colors.grey.shade100
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: f == null ? Colors.grey.shade300 : Colors.green,
            width: f == null ? 1.2 : 2,
          ),
        ),
        child: f != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: title.isEmpty ? 56 : 38,
                      color: Colors.brown.shade400,
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      );
}

class _RowLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RowLabel(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: Colors.brown, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      );
}

class _FmtHelper {
  String money(num v) => _nf.format(v);
  static final _nf = _numFmt();
}

class _numFmt {
  String format(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}