import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sale_item_entity.dart';

class SaleOrderPreviewCard extends StatelessWidget {
  final List<SaleItemEntity> items;
  final String paymentType;
  final double cashPaid;
  final double transferPaid;
  final double debt;
  final double received;
  final Map<int, int> bills;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? debtNote;
  final DateTime? appointmentDate;
  final String? note;
  final int payImgCount;
  final int billImgCount;
  final int topUpImgCount;
  final int debtPayImgCount;
  final int debtBillCount;

  const SaleOrderPreviewCard({
    super.key,
    required this.items,
    required this.paymentType,
    required this.cashPaid,
    required this.transferPaid,
    required this.debt,
    required this.received,
    required this.bills,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.debtNote,
    this.appointmentDate,
    this.note,
    this.payImgCount = 0,
    this.billImgCount = 0,
    this.topUpImgCount = 0,
    this.debtPayImgCount = 0,
    this.debtBillCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');

    final gross = items.fold<double>(0, (s, e) => s + e.grossAmount);
    final discountTotal =
        items.fold<double>(0, (s, e) => s + e.discountAmount);
    final net = items.fold<double>(0, (s, e) => s + e.totalAmount);
    final totalQty = items.fold<int>(0, (s, e) => s + e.quantity);

    final isDebt = debt > 0;
    final isMixed = cashPaid > 0 && transferPaid > 0;

    final payLabel = paymentType == 'cash'
        ? 'ເງິນສົດ'
        : paymentType == 'transfer'
            ? 'ເງິນໂອນ'
            : paymentType == 'mixed'
                ? 'ປະສົມ'
                : 'ຕິດໜີ້';

    final payColor = isDebt
        ? Colors.orange.shade800
        : isMixed
            ? Colors.indigo.shade700
            : Colors.green.shade700;

    final totalImages = payImgCount +
        billImgCount +
        topUpImgCount +
        debtPayImgCount +
        debtBillCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(Icons.receipt_long,
                    color: Colors.brown.shade700, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ໃບສະຫຼຸບການຂາຍ',
                        style: TextStyle(
                          color: Colors.brown.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'ກວດເບິ່ງກ່ອນບັນທຶກ',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${items.length} ລາຍການ',
                  style: TextStyle(
                    color: Colors.brown.shade700,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _dashedLine(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionLabel('ລາຍການສິນຄ້າ'),
                const SizedBox(height: 10),
                ...items.asMap().entries.map((e) {
                  final idx = e.key;
                  final it = e.value;
                  return _itemRow(idx + 1, it, fmt);
                }),
                _dashedLine(),
                _moneyRow('ຍອດລວມ', '${fmt.format(gross)} ກີບ'),
                if (discountTotal > 0)
                  _moneyRow(
                    'ສ່ວນລົດ',
                    '-${fmt.format(discountTotal)} ກີບ',
                    color: Colors.red.shade700,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'ຍອດຂາຍລວມ',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        '${fmt.format(net)} ກີບ',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                _dashedLine(),
                _sectionLabel('ການຊຳລະ'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'ວິທີ: ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      payLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: payColor,
                      ),
                    ),
                    if (received > 0 && cashPaid > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        'ຮັບມາ: ',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        fmt.format(received),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (cashPaid > 0)
                  _moneyRow(
                    'ຈ່າຍສົດ',
                    '${fmt.format(cashPaid)} ກີບ',
                    color: Colors.green.shade700,
                  ),
                if (transferPaid > 0)
                  _moneyRow(
                    'ຈ່າຍໂອນ',
                    '${fmt.format(transferPaid)} ກີບ',
                    color: Colors.blue.shade700,
                  ),
                if (debt > 0)
                  _moneyRow(
                    'ຕິດໜີ້',
                    '${fmt.format(debt)} ກີບ',
                    color: Colors.orange.shade800,
                    bold: true,
                  ),
                if (bills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _sectionLabel('ນັບແຍກໃບເງິນ'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: bills.entries.map((e) {
                      return Text(
                        '${fmt.format(e.key)} × ${e.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown.shade800,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (isDebt) ...[
                  _dashedLine(),
                  _sectionLabel('ຂໍ້ມູນລູກຄ້າຕິດໜີ້',
                      color: Colors.orange.shade800),
                  const SizedBox(height: 8),
                  if ((customerName ?? '').trim().isNotEmpty)
                    _row(Icons.person, 'ຊື່', customerName!),
                  if ((customerPhone ?? '').trim().isNotEmpty)
                    _row(Icons.phone, 'ເບີໂທ', customerPhone!),
                  if ((customerAddress ?? '').trim().isNotEmpty)
                    _row(Icons.home, 'ທີ່ຢູ່', customerAddress!),
                  if (appointmentDate != null)
                    _row(
                      Icons.event_available,
                      'ນັດຈ່າຍ',
                      '${appointmentDate!.day.toString().padLeft(2, '0')}/${appointmentDate!.month.toString().padLeft(2, '0')}/${appointmentDate!.year}',
                    ),
                  if ((debtNote ?? '').trim().isNotEmpty)
                    _row(Icons.sticky_note_2, 'ໝາຍເຫດ', debtNote!),
                ],
                if (totalImages > 0) ...[
                  _dashedLine(),
                  _sectionLabel('ຮູບພາບແນບ'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      if (payImgCount > 0)
                        _imgText(Icons.payments, 'ຊຳລະ', payImgCount),
                      if (billImgCount > 0)
                        _imgText(
                            Icons.receipt_long, 'ໃບບິນ', billImgCount),
                      if (topUpImgCount > 0)
                        _imgText(Icons.add_card, 'ເຕີມ', topUpImgCount),
                      if (debtPayImgCount > 0)
                        _imgText(Icons.account_balance_wallet,
                            'ຈ່າຍໜີ້', debtPayImgCount),
                      if (debtBillCount > 0)
                        _imgText(Icons.description, 'ໃບບິນໜີ້',
                            debtBillCount),
                    ],
                  ),
                ],
                if ((note ?? '').trim().isNotEmpty) ...[
                  _dashedLine(),
                  _sectionLabel('ໝາຍເຫດ'),
                  const SizedBox(height: 6),
                  Text(
                    note!,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
                _dashedLine(),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                        'ລວມ $totalQty ຊິ້ນ · ${items.length} ລາຍການ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(int idx, SaleItemEntity it, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$idx.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.productName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (it.woodType.isNotEmpty)
                  _subInfo('ຊະນິດ: ${it.woodType}'),
                if (it.hasSize) _subInfo('ຂະໜາດ: ${it.dimensionText}'),
                _subInfo(
                  '${it.quantity} ${it.unit} × ${fmt.format(it.unitPrice)}',
                  color: Colors.grey.shade700,
                ),
                if (it.hasDiscount)
                  _subInfo(
                    'ລົດ ${fmt.format(it.discountPerUnit)}/${it.unit} · ລວມ -${fmt.format(it.discountAmount)}',
                    color: Colors.red.shade700,
                    bold: true,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${fmt.format(it.totalAmount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.brown.shade800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subInfo(String text, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          color: color ?? Colors.grey.shade600,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {Color? color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        color: color ?? Colors.grey.shade500,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _dashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                color: Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _moneyRow(
    String label,
    String value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          SizedBox(
            width: 66,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgText(IconData icon, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          '$label · $count',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}