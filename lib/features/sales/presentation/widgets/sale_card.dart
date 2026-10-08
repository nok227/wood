import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/animated_number.dart';
import 'package:wood/core/widgets/global/app_image_viewer.dart';
import 'package:wood/features/sales/presentation/controllers/sales_controller.dart';
import 'package:wood/features/sales/presentation/pages/debt_payment/debt_payment_page.dart';
import 'package:wood/features/sales/presentation/pages/detail/sale_detail_page.dart';
import 'package:wood/features/wood_products/presentation/widgets/option_tile.dart';

import '../../domain/entities/sale_order_entity.dart';

final ValueNotifier<String?> _openMenuId = ValueNotifier<String?>(null);

class SaleCard extends StatelessWidget {
  final SaleOrderEntity sale;
  final bool isAdmin;

  const SaleCard({super.key, required this.sale, required this.isAdmin});

  static String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    return v.startsWith(prefix) ? v : '$prefix$v';
  }

  void _safeCloseDialog() {
    if (Get.isDialogOpen ?? false) {
      final ctx = Get.context;
      if (ctx != null) {
        Navigator.of(ctx, rootNavigator: true).pop();
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesController>();
    final fmt = NumberFormat('#,###');

    final payUrl = _first(sale.paymentImageUrls);
    final billUrl = _first(sale.billImageUrls);
    final thirdUrl =
        _first(sale.debtPaymentImageUrls) ?? _first(sale.topUpImageUrls);

    final payLabel = sale.paymentType == 'cash'
        ? SaleStyle.detailCashLabel
        : SaleStyle.detailTransferLabel;

    final images = <AppImageItem>[
      ...sale.paymentImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => AppImageItem(u, label: payLabel)),
      ...sale.topUpImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => AppImageItem(u, label: SaleStyle.previewImgTopUp)),
      ...sale.billImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => AppImageItem(u, label: SaleStyle.detailBillLabel)),
      ...sale.debtPaymentImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => AppImageItem(u, label: SaleStyle.previewImgDebt)),
    ];

    // helper — หา index ของ url ใน images
    int idxOf(String? url) {
      if (url == null) return 0;
      final i = images.indexWhere((e) => e.url == url);
      return i < 0 ? 0 : i;
    }

    void openAt(String? url) {
      if (images.isEmpty) return;
      Get.to(() => AppImageViewer(images: images, initialIndex: idxOf(url)));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.cardRadius,
        boxShadow: SaleStyle.card,
      ),
      child: Material(
        color: SaleStyle.transparent,
        child: InkWell(
          borderRadius: SaleStyle.cardRadius,
          onTap: () => Get.to(() => SaleDetailPage(sale: sale)),
          child: Padding(
            padding: SaleStyle.padCard,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 3 ຮູບ ──
                  Column(
                    children: [
                      _thumb(
                        payUrl,
                        payUrl == null ? null : () => openAt(payUrl),
                      ),
                      SaleStyle.gap4,
                      _thumb(
                        billUrl,
                        billUrl == null ? null : () => openAt(billUrl),
                      ),
                      SaleStyle.gap4,
                      _thumb(
                        thirdUrl,
                        thirdUrl == null ? null : () => openAt(thirdUrl),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfo(ctrl, fmt)),
                  _FloatingActionsButton(
                    key: ValueKey('act-${sale.id}'),
                    saleId: sale.id,
                    isAdmin: isAdmin,
                    onDelete: () => _deleteDialog(ctrl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(SalesController ctrl, NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sale.shortSummary,
          style: SaleStyle.cardTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (sale.hasMultiItems) ...[
          SaleStyle.gap4,
          ...sale.items
              .take(2)
              .map(
                (it) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: SaleStyle.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${it.productName} · ${it.quantity} ${it.unit}'
                          '${it.hasDiscount ? " · ${SaleStyle.itemDiscountPrefix} ${fmt.format(it.discountPerUnit)}" : ""}',
                          style: SaleStyle.cardSubMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (sale.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 9),
              child: Text(
                '+${sale.items.length - 2} ${SaleStyle.itemsSuffix}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: SaleStyle.brown600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
        SaleStyle.gap4,
        Text(
          '${sale.itemCount} ${SaleStyle.cardItemsPrefix} · ${sale.totalQuantity} ${SaleStyle.cardPiecesPrefix}',
          style: SaleStyle.cardMeta,
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              '${SaleStyle.cardTotalPrefix} ',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: SaleStyle.grey500,
              ),
            ),
            AnimatedNumber(
              value: sale.totalAmount,
              suffix: ' ${SaleStyle.currency}',
              duration: SaleStyle.animNormal.inMilliseconds,
              replayOnRouteChange: true,
              style: SaleStyle.moneyLg.copyWith(color: SaleStyle.brown700),
            ),
          ],
        ),
        SaleStyle.gap4,
        Row(
          children: [
            const Text(
              SaleStyle.cardTypePrefix,
              style: TextStyle(fontSize: 11.5, color: SaleStyle.grey500),
            ),
            Text(
              sale.paymentType == 'cash'
                  ? SaleStyle.cashFull
                  : sale.paymentType == 'transfer'
                  ? SaleStyle.transferFull
                  : sale.paymentType == 'mixed'
                  ? SaleStyle.mixedLabel
                  : SaleStyle.debtLabel,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: SaleStyle.grey800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          ctrl.formatLaoDate(sale.date),
          style: const TextStyle(fontSize: 10.5, color: SaleStyle.grey500),
        ),
        if (sale.discountTotal > 0) ...[
          SaleStyle.gap4,
          _miniChip(
            icon: Icons.discount,
            text:
                '${SaleStyle.cardDiscountPrefix} ${fmt.format(sale.discountTotal)} ${SaleStyle.currency}',
            color: SaleStyle.red700,
          ),
        ],
        if (sale.changeAmount > 0) ...[
          SaleStyle.gap4,
          _miniChip(
            icon: Icons.swap_horiz,
            text:
                '${SaleStyle.cardChangePrefix} ${fmt.format(sale.changeAmount)} ${SaleStyle.currency}',
            color: SaleStyle.blue700,
          ),
        ],
        const SizedBox(height: 6),
        _paymentBadge(fmt),
        if ((sale.note ?? '').trim().isNotEmpty) ...[
          SaleStyle.gap4,
          _miniChip(
            icon: Icons.sticky_note_2_outlined,
            text: sale.note!,
            color: SaleStyle.brown700,
          ),
        ],
        const Spacer(),
        _statusButton(ctrl),
      ],
    );
  }

  Widget _paymentBadge(NumberFormat fmt) {
    if (sale.hasDebt) {
      final name = _wPrefix(sale.customerName, 'ຊື່');
      final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');
      final phone = (sale.customerPhone ?? '').trim();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _badge(
            icon: Icons.warning_amber_rounded,
            text:
                '${SaleStyle.debtLabel} ${fmt.format(sale.debtAmount)} ${SaleStyle.currency}',
            color: SaleStyle.orange800,
          ),
          if (name.isNotEmpty) ...[
            SaleStyle.gap3,
            _infoRow(Icons.person_outline, name),
          ],
          if (phone.isNotEmpty) ...[
            SaleStyle.gap2,
            _infoRow(Icons.phone_outlined, phone),
          ],
          if (addr.isNotEmpty) ...[
            SaleStyle.gap2,
            _infoRow(Icons.home_outlined, addr),
          ],
          if ((sale.debtNote ?? '').trim().isNotEmpty) ...[
            SaleStyle.gap2,
            _infoRow(Icons.sticky_note_2_outlined, sale.debtNote!),
          ],
        ],
      );
    }

    if (sale.isMixed) {
      return _badge(
        icon: Icons.call_split,
        text:
            '${SaleStyle.cardMixedPrefix} ${fmt.format(sale.cashPaidAmount)} · ${SaleStyle.transferLabel} ${fmt.format(sale.transferPaidAmount)}',
        color: SaleStyle.indigo700,
      );
    }

    return _badge(
      icon: Icons.verified_outlined,
      text: SaleStyle.cardPayment,
      color: SaleStyle.green700,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 11, color: SaleStyle.orange800),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: SaleStyle.orange800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _badge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: SaleStyle.badge.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _miniChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: SaleStyle.miniChip.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String? _first(List<String> urls) {
    for (final u in urls) {
      if (u.isNotEmpty) return u;
    }
    return null;
  }

  Widget _thumb(String? url, VoidCallback? onTap) {
    return GestureDetector(
      onTap: url != null ? onTap : null,
      child: ClipRRect(
        borderRadius: SaleStyle.thumbRadius,
        child: SizedBox(
          width: SaleStyle.thumbSale,
          height: SaleStyle.thumbSaleH,
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  memCacheWidth: 152,
                  placeholder: (c, u) => const SizedBox.shrink(),
                  errorWidget: (_, _, _) => _noImagePlaceholder(),
                )
              : _noImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _noImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: SaleStyle.grey300,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            SaleStyle.cardNoImg,
            style: const TextStyle(
              fontSize: 9,
              color: SaleStyle.grey400,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(SalesController c) {
    if (sale.isMismatch) {
      return InkWell(
        onTap: isAdmin ? () => _mismatchDialog(c, isEdit: true) : null,
        borderRadius: SaleStyle.r8,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: SaleStyle.red50,
            borderRadius: SaleStyle.r8,
            border: Border.all(
              color: SaleStyle.mismatch.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: SaleStyle.mismatch,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isAdmin ? SaleStyle.cardMismatchEdit : SaleStyle.cardMismatch,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SaleStyle.mismatch,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sale.isConfirmed) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Checkmark(size: 16),
          SizedBox(width: 6),
          Text(
            SaleStyle.detailStatusConfirmed,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: SaleStyle.confirmed,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }

    if (sale.hasDebt) {
      return InkWell(
        onTap: isAdmin ? () => _confirmReceiveDebt(c) : null,
        borderRadius: SaleStyle.r8,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: SaleStyle.amber50,
            borderRadius: SaleStyle.r8,
            border: Border.all(
              color: SaleStyle.amber700.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Waiting(size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isAdmin ? SaleStyle.cardDebtConfirm : SaleStyle.cardCheck,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SaleStyle.amber900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: isAdmin ? () => _pendingDialog(c) : null,
      borderRadius: SaleStyle.r8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: SaleStyle.amber50,
          borderRadius: SaleStyle.r8,
          border: Border.all(
            color: SaleStyle.amber700.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _Waiting(size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                isAdmin ? SaleStyle.cardPending : SaleStyle.cardCheck,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SaleStyle.amber900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReceiveDebt(SalesController c) {
    final name = _wPrefix(sale.customerName, 'ຊື່');
    final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');

    Get.defaultDialog(
      title: SaleStyle.confirmReceivePayment,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const Icon(Icons.receipt_long, size: 48, color: SaleStyle.green600),
            const SizedBox(height: 8),
            if (name.isNotEmpty)
              Text(
                '${SaleStyle.detailCustomerPrefix}: $name',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if ((sale.customerPhone ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${SaleStyle.detailPhonePrefix}: ${sale.customerPhone}',
                style: const TextStyle(fontSize: 12, color: SaleStyle.grey700),
              ),
            ],
            if (addr.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${SaleStyle.detailAddrPrefix}: $addr',
                style: const TextStyle(fontSize: 12, color: SaleStyle.grey700),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              '${SaleStyle.detailDebtAmount}: ${NumberFormat('#,###').format(sale.debtAmount)} ${SaleStyle.currency}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SaleStyle.orange800,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: SaleStyle.amber50,
                borderRadius: SaleStyle.r10,
                border: Border.all(color: SaleStyle.amber300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.help_outline, color: SaleStyle.amber900, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      SaleStyle.detailReceivedDebt,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: SaleStyle.amber900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      textConfirm: SaleStyle.confirmPaidBtn,
      textCancel: SaleStyle.notYetBtn,
      confirmTextColor: SaleStyle.white,
      buttonColor: SaleStyle.green700,
      cancelTextColor: SaleStyle.grey700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(SaleStyle.delayClose);
        while (Get.isDialogOpen ?? false) {
          _safeCloseDialog();
          await Future.delayed(const Duration(milliseconds: 120));
        }
        Get.to(() => DebtPaymentPage(sale: sale));
      },
    );
  }

  void _pendingDialog(SalesController c) {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      backgroundColor: SaleStyle.white,
      radius: 20,
      barrierDismissible: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: SaleStyle.amber50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: SaleStyle.amber800,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            SaleStyle.pendingTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: SaleStyle.black87,
            ),
          ),
          SaleStyle.gap4,
          const Text(
            SaleStyle.pendingSubtitle,
            style: TextStyle(fontSize: 12, color: SaleStyle.grey500),
          ),
          const SizedBox(height: 18),
          OptionTile(
            icon: Icons.check_circle_outline,
            iconColor: SaleStyle.green700,
            iconBg: SaleStyle.green50,
            title: SaleStyle.confirmPaymentStatus,
            subtitle: SaleStyle.confirmPaymentSub,
            onTap: () async {
              _safeCloseDialog();
              await Future.delayed(SaleStyle.delayDialog);
              await c.confirmPaymentStatus(sale.id, false);
            },
          ),
          const SizedBox(height: 10),
          OptionTile(
            icon: Icons.warning_amber_rounded,
            iconColor: SaleStyle.mismatch,
            iconBg: SaleStyle.red50,
            title: SaleStyle.mismatchBtn,
            subtitle: SaleStyle.mismatchBtnSub,
            onTap: () async {
              _safeCloseDialog();
              await Future.delayed(SaleStyle.delayDialog);
              while (Get.isDialogOpen ?? false) {
                _safeCloseDialog();
                await Future.delayed(const Duration(milliseconds: 120));
              }
              _mismatchDialog(c, isEdit: false);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: SaleStyle.r10,
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text(
                SaleStyle.cancel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SaleStyle.grey600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mismatchDialog(SalesController c, {required bool isEdit}) {
    final noteCtrl = TextEditingController(
      text: isEdit ? (sale.mismatchNote ?? '') : '',
    );

    Get.defaultDialog(
      title: isEdit
          ? SaleStyle.detailEditReason
          : SaleStyle.detailMismatchTitle,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: SaleStyle.alertFillReason2,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (isEdit)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SaleStyle.grey700,
                        side: const BorderSide(color: SaleStyle.grey400),
                      ),
                      onPressed: () async {
                        _safeCloseDialog();
                        await Future.delayed(SaleStyle.delayDialog);
                        await c.clearMismatch(sale.id);
                      },
                      child: const Text(SaleStyle.cancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SaleStyle.mismatch,
                      ),
                      onPressed: () async {
                        final t = noteCtrl.text.trim();
                        if (t.isEmpty) {
                          Get.snackbar(
                            SaleStyle.errorMsg,
                            SaleStyle.alertFillReason,
                          );
                          return;
                        }
                        _safeCloseDialog();
                        await Future.delayed(SaleStyle.delayDialog);
                        await c.updateMismatchNote(sale.id, t);
                      },
                      child: const Text(
                        SaleStyle.detailSaveReason,
                        style: TextStyle(color: SaleStyle.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SaleStyle.mismatch,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () async {
                    final t = noteCtrl.text.trim();
                    if (t.isEmpty) {
                      Get.snackbar(
                        SaleStyle.errorMsg,
                        SaleStyle.alertFillReason,
                      );
                      return;
                    }
                    _safeCloseDialog();
                    await Future.delayed(SaleStyle.delayDialog);
                    await c.markAsMismatch(sale.id, t);
                  },
                  child: const Text(
                    SaleStyle.detailMismatchConfirm,
                    style: TextStyle(color: SaleStyle.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      textCancel: SaleStyle.close,
      textConfirm: '',
    );
  }

  void _deleteDialog(SalesController c) {
    if (Get.isDialogOpen ?? false) return;

    Get.defaultDialog(
      title: SaleStyle.confirmDelete,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: SaleStyle.red600,
            ),
            const SizedBox(height: 8),
            Text(
              sale.shortSummary,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${NumberFormat('#,###').format(sale.totalAmount)} ${SaleStyle.currency}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SaleStyle.brown700,
              ),
            ),
            if (sale.hasMultiItems) ...[
              SaleStyle.gap4,
              Text(
                '${SaleStyle.batchDelete} ${sale.itemCount} ${SaleStyle.previewFooterItems}',
                style: const TextStyle(fontSize: 12, color: SaleStyle.grey700),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SaleStyle.red50,
                borderRadius: SaleStyle.r8,
                border: Border.all(color: SaleStyle.red200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: SaleStyle.red700, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      SaleStyle.deleteConfirmPrefix,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SaleStyle.red700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              SaleStyle.deleteConfirmMsg,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      textConfirm: SaleStyle.delete,
      textCancel: SaleStyle.cancel,
      confirmTextColor: SaleStyle.white,
      cancelTextColor: SaleStyle.grey700,
      buttonColor: SaleStyle.red700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(SaleStyle.delayDialog);
        await c.deleteSale(sale.id);
      },
    );
  }
}

// ══════════════════════════════════════════════
// ⋮ → 🗑
// ══════════════════════════════════════════════
class _FloatingActionsButton extends StatefulWidget {
  final String saleId;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _FloatingActionsButton({
    super.key,
    required this.saleId,
    required this.isAdmin,
    required this.onDelete,
  });

  @override
  State<_FloatingActionsButton> createState() => _FloatingActionsButtonState();
}

class _FloatingActionsButtonState extends State<_FloatingActionsButton>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: SaleStyle.floatMenu,
  );

  @override
  void initState() {
    super.initState();
    _openMenuId.addListener(_onGlobalChange);
  }

  @override
  void dispose() {
    _openMenuId.removeListener(_onGlobalChange);
    _ctrl.dispose();
    super.dispose();
  }

  void _onGlobalChange() {
    if (!mounted) return;
    if (_open && _openMenuId.value != widget.saleId) {
      _closeLocal();
    }
  }

  void _closeLocal() {
    if (!_open) return;
    setState(() => _open = false);
    _ctrl.reverse();
  }

  void _close() {
    _closeLocal();
    if (_openMenuId.value == widget.saleId) {
      _openMenuId.value = null;
    }
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenuId.value = widget.saleId;
      setState(() => _open = true);
      _ctrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) return const SizedBox.shrink();

    final actions = <_ActionItem>[
      _ActionItem(
        icon: Icons.delete,
        color: SaleStyle.mismatch,
        shadow: SaleStyle.red200,
        onTap: () {
          _close();
          Future.delayed(SaleStyle.swipeDelay, () {
            if (mounted) widget.onDelete();
          });
        },
      ),
    ];

    final totalHeight = 40.0 + (actions.length * 52.0);
    const width = 60.0;

    return SizedBox(
      width: width,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_open)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(
                _open ? Icons.close : Icons.more_vert,
                color: _open ? SaleStyle.brown700 : SaleStyle.black54,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: _toggle,
            ),
          ),
          for (int i = 0; i < actions.length; i++)
            Positioned(
              right: 0,
              top: 42 + (i * 52.0),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => IgnorePointer(
                  ignoring: !_open,
                  child: Opacity(
                    opacity: _ctrl.value,
                    child: Transform.translate(
                      offset: Offset(0, -18 * (1 - _ctrl.value)),
                      child: Transform.scale(
                        scale: 0.7 + 0.3 * _ctrl.value,
                        child: child,
                      ),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: _open ? actions[i].onTap : null,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SaleStyle.white,
                      boxShadow: [
                        BoxShadow(
                          color: actions[i].shadow.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      actions[i].icon,
                      color: actions[i].color,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final Color color;
  final Color shadow;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.color,
    required this.shadow,
    required this.onTap,
  });
}

class _Waiting extends StatelessWidget {
  final double size;
  const _Waiting({this.size = 18});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.hourglass_bottom,
    size: size * 0.85,
    color: SaleStyle.amber800,
  );
}

class _Checkmark extends StatelessWidget {
  final double size;
  const _Checkmark({this.size = 18});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: SaleStyle.animPulse,
    curve: Curves.elasticOut,
    builder: (_, v, child) => Transform.scale(scale: v, child: child),
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: SaleStyle.confirmed,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: SaleStyle.white, size: size * 0.7),
    ),
  );
}
