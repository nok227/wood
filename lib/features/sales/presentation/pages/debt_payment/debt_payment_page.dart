import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/utils/cloudinary_service.dart';
import 'package:wood/core/widgets/global/animated_number.dart';

import '../../../domain/entities/sale_order_entity.dart';
import '../../controllers/sales_controller.dart';

class DebtPaymentPage extends StatefulWidget {
  final SaleOrderEntity sale;
  const DebtPaymentPage({super.key, required this.sale});

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final c = Get.find<SalesController>();
  final picker = ImagePicker();

  String _payType = 'cash';
  File? _img;
  bool _loading = false;
  bool _done = false;

  SaleOrderEntity get sale => widget.sale;

  Future<void> _pick() async {
    Get.bottomSheet(
      Container(
        color: SaleStyle.white,
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera, color: SaleStyle.green700),
            title: const Text(SaleStyle.pickCamera),
            onTap: () async {
              Get.back();
              final p = await picker.pickImage(source: ImageSource.camera,
                  maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
              if (p == null) return;
              setState(() => _img = File(p.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: SaleStyle.green700),
            title: const Text(SaleStyle.pickGallery),
            onTap: () async {
              Get.back();
              final p = await picker.pickImage(source: ImageSource.gallery,
                  maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
              if (p == null) return;
              setState(() => _img = File(p.path));
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_loading || _done) return;

    if (_img == null) {
      _snack(SaleStyle.alertTitleWarn,
          _payType == 'cash' ? SaleStyle.debtPayImgCash : SaleStyle.debtPayImgTransfer,
          color: SaleStyle.orange800, icon: Icons.warning_amber_rounded);
      return;
    }

    setState(() => _loading = true);
    String? errMsg;

    try {
      final url = await CloudinaryService.uploadImage(_img!,
          folder: _payType == 'cash' ? 'sales/debt_cash' : 'sales/debt_transfer')
          .timeout(const Duration(seconds: 60));

      if (url == null || url.isEmpty) throw Exception(SaleStyle.alertEditImgFail);

      await c.payDebt(sale.id, paymentType: _payType, imageUrl: url, paidAmount: sale.debtAmount);
      _done = true;
    } catch (e) {
      errMsg = e.toString();
    }

    if (mounted) setState(() => _loading = false);

    if (_done) {
      if (mounted) Navigator.of(context).maybePop();
      Future.delayed(const Duration(milliseconds: 400), () {
        _snack(SaleStyle.alertSuccess, SaleStyle.debtPaySuccess,
            color: SaleStyle.green700, icon: Icons.check_circle, duration: SaleStyle.snackbarLong);
      });
    } else {
      _snack(SaleStyle.errorMsg, errMsg ?? SaleStyle.alertEditImgFail,
          color: SaleStyle.red700, icon: Icons.error_outline, duration: SaleStyle.snackbarLong);
    }
  }

  void _snack(String title, String msg, {required Color color, required IconData icon,
      Duration duration = SaleStyle.snackbarShort}) {
    Get.closeAllSnackbars();
    Get.snackbar(title, msg,
      backgroundColor: color, colorText: SaleStyle.white,
      icon: Icon(icon, color: SaleStyle.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: SaleStyle.snackbarRadius,
      duration: duration, isDismissible: true,
      animationDuration: SaleStyle.delayDialog,
      boxShadows: [
        BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }

  void _viewOriginalBill() {
    final urls = sale.billImageUrls.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) return;

    Get.dialog(Dialog(
      backgroundColor: SaleStyle.transparent,
      child: Container(
        decoration: BoxDecoration(color: SaleStyle.white, borderRadius: SaleStyle.r14),
        padding: SaleStyle.padCardLg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.receipt_long, color: SaleStyle.green700, size: 20),
            const SizedBox(width: 6),
            const Expanded(child: Text(SaleStyle.debtPayBillSaved,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 4),
          Flexible(child: InteractiveViewer(maxScale: 4,
            child: CachedNetworkImage(imageUrl: urls.first, fit: BoxFit.contain,
              placeholder: (_, _) => const Padding(padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: SaleStyle.green700)),
              errorWidget: (_, _, _) => const Padding(padding: EdgeInsets.all(30),
                  child: Icon(Icons.broken_image, size: 60)),
            ),
          )),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final name = _wPrefix(sale.customerName, 'ຊື່');
    final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');
    final originalBills = sale.billImageUrls.where((u) => u.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: SaleStyle.brown50,
      appBar: AppBar(
        title: const Text(SaleStyle.debtPayTitle),
        backgroundColor: SaleStyle.green700,
        foregroundColor: SaleStyle.white,
      ),
      body: Stack(children: [
        ListView(padding: SaleStyle.padAll16, children: [
          Container(
            padding: SaleStyle.padAll16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SaleStyle.green700, SaleStyle.green400],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: SaleStyle.r14,
            ),
            child: Column(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.receipt_long, color: SaleStyle.white, size: 18),
                SizedBox(width: 6),
                Text(SaleStyle.debtPayAmount,
                    style: TextStyle(color: SaleStyle.white70, fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              FittedBox(fit: BoxFit.scaleDown,
                child: AnimatedNumber(
                  value: sale.debtAmount,
                  suffix: ' ${SaleStyle.currency}',
                  duration: 1400,
                  style: const TextStyle(color: SaleStyle.white, fontSize: 32,
                      fontWeight: FontWeight.w900),
                )),
              const Divider(color: SaleStyle.white24, height: 20),
              if (name.isNotEmpty) _row(Icons.person_outline, name),
              if ((sale.customerPhone ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                _row(Icons.phone_outlined, sale.customerPhone!),
              ],
              if (addr.isNotEmpty) ...[
                const SizedBox(height: 4),
                _row(Icons.home_outlined, addr),
              ],
              if ((sale.debtNote ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                _row(Icons.sticky_note_2_outlined, sale.debtNote!),
              ],
            ]),
          ),
          if (originalBills.isNotEmpty) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: _viewOriginalBill,
              borderRadius: SaleStyle.r12,
              child: Container(
                padding: SaleStyle.padCardLg,
                decoration: BoxDecoration(
                  color: SaleStyle.orange50, borderRadius: SaleStyle.r12,
                  border: Border.all(color: SaleStyle.orange300, width: 1.5)),
                child: Row(children: [
                  ClipRRect(borderRadius: SaleStyle.r8,
                    child: CachedNetworkImage(imageUrl: originalBills.first,
                      width: 56, height: 56, fit: BoxFit.cover,
                      placeholder: (_, _) => Container(width: 56, height: 56, color: SaleStyle.orange100),
                      errorWidget: (_, _, _) => Container(width: 56, height: 56,
                          color: SaleStyle.orange100,
                          child: const Icon(Icons.broken_image)),
                    )),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(SaleStyle.debtPayBillView,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SaleStyle.orange900)),
                    const SizedBox(height: 2),
                    Text(SaleStyle.debtPayBillHint,
                        style: const TextStyle(fontSize: 11, color: SaleStyle.orange700)),
                  ])),
                  const Icon(Icons.zoom_in, color: SaleStyle.orange700, size: 22),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(SaleStyle.debtPayType,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _typeBtn(icon: Icons.payments_outlined,
              label: SaleStyle.cashFull, color: SaleStyle.amber800,
              selected: _payType == 'cash',
              onTap: _loading ? null : () => setState(() => _payType = 'cash'))),
            const SizedBox(width: 8),
            Expanded(child: _typeBtn(icon: Icons.account_balance,
              label: SaleStyle.transferFull, color: SaleStyle.blue700,
              selected: _payType == 'transfer',
              onTap: _loading ? null : () => setState(() => _payType = 'transfer'))),
          ]),
          const SizedBox(height: 20),
          Text(_payType == 'cash' ? SaleStyle.debtPayImgCash : SaleStyle.debtPayImgTransfer,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(SaleStyle.debtPayImgHint,
              style: TextStyle(fontSize: 11, color: SaleStyle.grey600, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          InkWell(
            onTap: (_img == null && !_loading) ? _pick : null,
            borderRadius: SaleStyle.r12,
            child: Container(
              height: SaleStyle.imgTileHeightLg,
              decoration: BoxDecoration(
                color: SaleStyle.white, borderRadius: SaleStyle.r12,
                border: Border.all(
                  color: _img == null ? SaleStyle.grey300 : SaleStyle.green700,
                  width: _img == null ? 1.5 : 2.5),
              ),
              child: _img != null
                ? Stack(children: [
                    ClipRRect(borderRadius: SaleStyle.r12,
                      child: Image.file(_img!, width: double.infinity,
                          height: double.infinity, fit: BoxFit.cover)),
                    if (!_loading) Positioned(top: 6, right: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => _img = null),
                        child: Container(padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: SaleStyle.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: SaleStyle.white, size: 20)),
                      )),
                  ])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_a_photo, size: 48, color: SaleStyle.brown400),
                    const SizedBox(height: 8),
                    Text(SaleStyle.debtPayImgEmpty,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SaleStyle.brown600)),
                  ]),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: SaleStyle.grey700,
                side: const BorderSide(color: SaleStyle.grey400),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: SaleStyle.r8),
              ),
              onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
              label: const Text(SaleStyle.cancel),
            )),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SaleStyle.green700,
                foregroundColor: SaleStyle.white,
                disabledBackgroundColor: SaleStyle.green300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: SaleStyle.r8),
              ),
              onPressed: (_loading || _img == null) ? null : _confirm,
              icon: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: SaleStyle.white))
                : Icon(_img == null ? Icons.photo_camera_outlined : Icons.check_circle),
              label: Text(
                _loading ? SaleStyle.debtPaySaving
                  : (_img == null ? SaleStyle.debtPayAttachFirst : SaleStyle.debtPayOk),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            )),
          ]),
        ]),
        if (_loading) Positioned.fill(
          child: Container(color: SaleStyle.black45,
            child: Center(child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: SaleStyle.white, borderRadius: SaleStyle.r16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(color: SaleStyle.brown700, strokeWidth: 3),
                const SizedBox(height: 14),
                Text(SaleStyle.debtPaySaving,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SaleStyle.brown800)),
              ]),
            )),
          ),
        ),
      ]),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: SaleStyle.white70, size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(text,
          style: const TextStyle(color: SaleStyle.white, fontSize: 13),
          maxLines: 2, overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _typeBtn({required IconData icon, required String label,
      required Color color, required bool selected, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: SaleStyle.r10,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : SaleStyle.white,
          borderRadius: SaleStyle.r10,
          border: Border.all(
            color: selected ? color : SaleStyle.grey300,
            width: selected ? 2 : 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: selected ? SaleStyle.white : color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
              color: selected ? SaleStyle.white : color)),
        ]),
      ),
    );
  }

  String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    return v.startsWith(prefix) ? v : '$prefix$v';
  }
}