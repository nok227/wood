import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
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
    final discountTotal = items.fold<double>(0, (s, e) => s + e.discountAmount);
    final net = items.fold<double>(0, (s, e) => s + e.totalAmount);
    final totalQty = items.fold<int>(0, (s, e) => s + e.quantity);

    final isDebt = debt > 0;
    final isMixed = cashPaid > 0 && transferPaid > 0;

    final payLabel = paymentType == 'cash'
        ? SaleStyle.cashFull
        : paymentType == 'transfer'
        ? SaleStyle.transferFull
        : paymentType == 'mixed'
        ? SaleStyle.mixedLabel
        : SaleStyle.debtLabel;

    final payColor = isDebt
        ? SaleStyle.orange800
        : isMixed
        ? SaleStyle.indigo700
        : SaleStyle.green700;

    final totalImages =
        payImgCount +
        billImgCount +
        topUpImgCount +
        debtPayImgCount +
        debtBillCount;

    return Container(
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.bannerRadius,
        boxShadow: SaleStyle.cardMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: SaleStyle.padImgHeader,
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: SaleStyle.brown700,
                  size: SaleStyle.iconMdLg,
                ),
                SaleStyle.gap10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        SaleStyle.previewTitle,
                        style: SaleStyle.txPreviewTitle,
                      ),
                      const Text(
                        SaleStyle.previewSub,
                        style: SaleStyle.txPreviewSub,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${items.length} ${SaleStyle.previewItemsUnit}',
                  style: SaleStyle.txItemCount,
                ),
              ],
            ),
          ),
          _dashedLine(),
          Padding(
            padding: SaleStyle.padImgBody,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionLabel(SaleStyle.sectionItems),
                SaleStyle.gap10,
                ...items.asMap().entries.map((e) {
                  final idx = e.key;
                  final it = e.value;
                  return _itemRow(idx + 1, it, fmt);
                }),
                _dashedLine(),
                _moneyRow(
                  SaleStyle.previewTotal,
                  '${fmt.format(gross)} ${SaleStyle.currency}',
                ),
                if (discountTotal > 0)
                  _moneyRow(
                    SaleStyle.previewDiscountLabel,
                    '-${fmt.format(discountTotal)} ${SaleStyle.currency}',
                    color: SaleStyle.red700,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Text(
                          SaleStyle.previewNet,
                          style: SaleStyle.txPreviewNetLabel,
                        ),
                      ),
                      Text(
                        '${fmt.format(net)} ${SaleStyle.currency}',
                        style: SaleStyle.txPreviewNetValue,
                      ),
                    ],
                  ),
                ),
                _dashedLine(),
                _sectionLabel(SaleStyle.sectionPayment),
                SaleStyle.gapSm,
                Row(
                  children: [
                    Text(
                      '${SaleStyle.detailMethodLabel}: ',
                      style: SaleStyle.txPreviewInfoLabel,
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
                      SaleStyle.gap12,
                      Text(
                        '${SaleStyle.previewReceived}: ',
                        style: SaleStyle.txPreviewInfoLabel,
                      ),
                      Text(
                        fmt.format(received),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: SaleStyle.brown700,
                        ),
                      ),
                    ],
                  ],
                ),
                SaleStyle.gap6,
                if (cashPaid > 0)
                  _moneyRow(
                    SaleStyle.previewCash,
                    '${fmt.format(cashPaid)} ${SaleStyle.currency}',
                    color: SaleStyle.green700,
                  ),
                if (transferPaid > 0)
                  _moneyRow(
                    SaleStyle.previewTransfer,
                    '${fmt.format(transferPaid)} ${SaleStyle.currency}',
                    color: SaleStyle.blue700,
                  ),
                if (debt > 0)
                  _moneyRow(
                    SaleStyle.debtLabel,
                    '${fmt.format(debt)} ${SaleStyle.currency}',
                    color: SaleStyle.orange800,
                    bold: true,
                  ),
                if (bills.isNotEmpty) ...[
                  SaleStyle.gap10,
                  _sectionLabel(SaleStyle.previewBillsPrefix),
                  SaleStyle.gap6,
                  Wrap(
                    spacing: SaleStyle.wrapSpacing,
                    runSpacing: SaleStyle.wrapRunSpacing,
                    children: bills.entries.map((e) {
                      return Text(
                        '${fmt.format(e.key)} × ${e.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SaleStyle.brown800,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (isDebt) ...[
                  _dashedLine(),
                  _sectionLabel(
                    SaleStyle.previewCustLabel,
                    color: SaleStyle.orange800,
                  ),
                  SaleStyle.gapSm,
                  if ((customerName ?? '').trim().isNotEmpty)
                    _row(
                      Icons.person,
                      SaleStyle.detailCustomerPrefix,
                      customerName!,
                    ),
                  if ((customerPhone ?? '').trim().isNotEmpty)
                    _row(
                      Icons.phone,
                      SaleStyle.detailPhonePrefix,
                      customerPhone!,
                    ),
                  if ((customerAddress ?? '').trim().isNotEmpty)
                    _row(
                      Icons.home,
                      SaleStyle.detailAddrPrefix,
                      customerAddress!,
                    ),
                  if (appointmentDate != null)
                    _row(
                      Icons.event_available,
                      SaleStyle.previewApptLabel,
                      '${appointmentDate!.day.toString().padLeft(2, '0')}/${appointmentDate!.month.toString().padLeft(2, '0')}/${appointmentDate!.year}',
                    ),
                  if ((debtNote ?? '').trim().isNotEmpty)
                    _row(
                      Icons.sticky_note_2,
                      SaleStyle.detailNoteLabel,
                      debtNote!,
                    ),
                ],
                if (totalImages > 0) ...[
                  _dashedLine(),
                  _sectionLabel(SaleStyle.previewImgLabel),
                  SaleStyle.gapSm,
                  Wrap(
                    spacing: SaleStyle.wrapCardSpacing * 2,
                    runSpacing: SaleStyle.wrapCardRunSpacing,
                    children: [
                      if (payImgCount > 0)
                        _imgText(
                          Icons.payments,
                          SaleStyle.previewImgPay,
                          payImgCount,
                        ),
                      if (billImgCount > 0)
                        _imgText(
                          Icons.receipt_long,
                          SaleStyle.previewImgBill,
                          billImgCount,
                        ),
                      if (topUpImgCount > 0)
                        _imgText(
                          Icons.add_card,
                          SaleStyle.previewImgTopUp,
                          topUpImgCount,
                        ),
                      if (debtPayImgCount > 0)
                        _imgText(
                          Icons.account_balance_wallet,
                          SaleStyle.previewImgDebt,
                          debtPayImgCount,
                        ),
                      if (debtBillCount > 0)
                        _imgText(
                          Icons.description,
                          SaleStyle.previewImgDebtBill,
                          debtBillCount,
                        ),
                    ],
                  ),
                ],
                if ((note ?? '').trim().isNotEmpty) ...[
                  _dashedLine(),
                  _sectionLabel(SaleStyle.sectionNote),
                  SaleStyle.gap6,
                  Text(
                    note!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: SaleStyle.grey800,
                    ),
                  ),
                ],
                _dashedLine(),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 13,
                        color: SaleStyle.grey400,
                      ),
                      SaleStyle.gapSm,
                      Text(
                        '${SaleStyle.previewTotalQty} $totalQty ${SaleStyle.previewFooterPieces} · ${items.length} ${SaleStyle.previewFooterItems}',
                        style: SaleStyle.txPreviewFooter,
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
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: SaleStyle.grey500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.productName,
                  style: SaleStyle.txPreviewItemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SaleStyle.gap2,
                if (it.woodType.isNotEmpty)
                  _subInfo('${SaleStyle.itemDimPrefix} ${it.woodType}'),
                if (it.hasSize)
                  _subInfo('${SaleStyle.itemDimPrefix}: ${it.dimensionText}'),
                _subInfo(
                  '${it.quantity} ${it.unit} × ${fmt.format(it.unitPrice)}',
                  color: SaleStyle.grey700,
                ),
                if (it.hasDiscount)
                  _subInfo(
                    '${SaleStyle.itemDiscountPrefix} ${fmt.format(it.discountPerUnit)}/${it.unit} · ${SaleStyle.summaryTotal} -${fmt.format(it.discountAmount)}',
                    color: SaleStyle.red700,
                    bold: true,
                  ),
              ],
            ),
          ),
          SaleStyle.gapSm,
          Text(fmt.format(it.totalAmount), style: SaleStyle.txPreviewItemPrice),
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
          color: color ?? SaleStyle.grey600,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {Color? color}) {
    return Text(text, style: SaleStyle.txSectionLabel.copyWith(color: color));
  }

  Widget _dashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          const dashSpace = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();
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
              style: SaleStyle.txPreviewMoneyLabel.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style:
                (bold
                        ? SaleStyle.txPreviewMoneyValueBold
                        : SaleStyle.txPreviewMoneyValue)
                    .copyWith(color: color),
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
          Icon(icon, size: SaleStyle.iconCalendar, color: SaleStyle.grey400),
          SaleStyle.gapSm,
          SizedBox(
            width: 66,
            child: Text(label, style: SaleStyle.txPreviewInfoLabel),
          ),
          Expanded(
            child: Text(
              value,
              style: SaleStyle.txPreviewInfoValue,
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
        Icon(icon, size: SaleStyle.iconCalendar, color: SaleStyle.grey500),
        SaleStyle.gap4,
        Text('$label · $count', style: SaleStyle.txPreviewImgText),
      ],
    );
  }
}
