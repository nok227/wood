import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';

import '../../domain/entities/sale_order_entity.dart';
import '../controllers/sales_controller.dart';

class DebtPaymentPage extends StatefulWidget {
  final SaleOrderEntity sale;
  const DebtPaymentPage({super.key, required this.sale});

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final c = Get.find<SalesController>();
  final fmt = NumberFormat('#,###');
  final picker = ImagePicker();

  String _payType = 'cash';
  File? _img;
  bool _loading = false;
  bool _done = false;

  SaleOrderEntity get sale => widget.sale;

  Future<void> _pick() async {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_camera, color: Colors.green),
              title: const Text('ຖ່າຍຮູບ'),
              onTap: () async {
                Get.back();
                final p = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1600,
                  maxHeight: 1600,
                  imageQuality: 80,
                );
                if (p == null) return;
                setState(() => _img = File(p.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('ຄັງຮູບ'),
              onTap: () async {
                Get.back();
                final p = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1600,
                  maxHeight: 1600,
                  imageQuality: 80,
                );
                if (p == null) return;
                setState(() => _img = File(p.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_loading || _done) return;

    if (_img == null) {
      _snack(
        'ຂາດຂໍ້ມູນ',
        _payType == 'cash'
            ? 'ກະລຸນາແນບຮູບເງິນສົດທີ່ຮັບມາ'
            : 'ກະລຸນາແນບຮູບສະລິບໂອນທີ່ຮັບມາ',
        color: Colors.orange.shade800,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _loading = true);

    String? errMsg;

    try {
      final url = await CloudinaryService.uploadImage(
        _img!,
        folder: _payType == 'cash' ? 'sales/debt_cash' : 'sales/debt_transfer',
      ).timeout(const Duration(seconds: 60));

      if (url == null || url.isEmpty) {
        throw Exception('ອັບໂຫຼດຮູບບໍ່ສຳເລັດ');
      }

      await c.payDebt(
        sale.id,
        paymentType: _payType,
        imageUrl: url,
        paidAmount: sale.debtAmount,
      );

      _done = true;
    } catch (e) {
      errMsg = e.toString();
    }

    if (mounted) {
      setState(() => _loading = false);
    }

    if (_done) {
      if (mounted) Navigator.of(context).maybePop();

      Future.delayed(const Duration(milliseconds: 400), () {
        _snack(
          'ສຳເລັດ',
          'ປິດໜີ້ຮຽບຮ້ອຍ · ຮັບເງິນແລ້ວ',
          color: Colors.green.shade700,
          icon: Icons.check_circle,
          duration: const Duration(seconds: 3),
        );
      });
    } else {
      _snack(
        'ຜິດພາດ',
        errMsg ?? 'ບໍ່ສາມາດບັນທຶກໄດ້',
        color: Colors.red.shade700,
        icon: Icons.error_outline,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _snack(
    String title,
    String msg, {
    required Color color,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      msg,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: duration,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      boxShadows: [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _viewOriginalBill() {
    final urls = sale.billImageUrls.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'ໃບບິນໜີ້ທີ່ແນບໄວ້',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: InteractiveViewer(
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: urls.first,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                    errorWidget: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(30),
                      child: Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _wPrefix(sale.customerName, 'ຊື່');
    final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');
    final originalBills =
        sale.billImageUrls.where((u) => u.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('ຢືນຢັນຮັບເງິນໜີ້'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header: ຍອດໜີ້ + ຂໍ້ມູນລູກຄ້າ ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('ຍອດຕິດໜີ້ທີ່ຈະຮັບ',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedNumber(
                        value: sale.debtAmount,
                        suffix: ' ກີບ',
                        duration: 1400,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 20),
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
                  ],
                ),
              ),

              // ── ໃບບິນໜີ້ເດີມ ──
              if (originalBills.isNotEmpty) ...[
                const SizedBox(height: 14),
                InkWell(
                  onTap: _viewOriginalBill,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.shade300, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: originalBills.first,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.orange.shade100,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.orange.shade100,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ໃບບິນໜີ້ຕອນສ້າງ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ແຕະເພື່ອເບິ່ງຂະໜາດເຕັມ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.zoom_in,
                            color: Colors.orange.shade700, size: 22),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── ປະເພດເງິນ ──
              const Text('ປະເພດເງິນ *',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _typeBtn(
                      icon: Icons.payments_outlined,
                      label: 'ເງິນສົດ',
                      color: Colors.amber.shade800,
                      selected: _payType == 'cash',
                      onTap: _loading
                          ? null
                          : () => setState(() => _payType = 'cash'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _typeBtn(
                      icon: Icons.account_balance,
                      label: 'ເງິນໂອນ',
                      color: Colors.blue.shade700,
                      selected: _payType == 'transfer',
                      onTap: _loading
                          ? null
                          : () => setState(() => _payType = 'transfer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── ຮູບເງິນ/ສະລິບ (ບັງຄັບ) ──
              Text(
                _payType == 'cash'
                    ? 'ຮູບເງິນສົດທີ່ຮັບມາ *'
                    : 'ຮູບສະລິບໂອນທີ່ຮັບມາ *',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'ຕ້ອງແນບຮູບທຸກຄັ້ງເພື່ອຢືນຢັນການຮັບເງິນ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: (_img == null && !_loading) ? _pick : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _img == null ? Colors.grey.shade300 : Colors.green,
                      width: _img == null ? 1.5 : 2.5,
                    ),
                  ),
                  child: _img != null
                      ? Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_img!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover),
                          ),
                          if (!_loading)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => setState(() => _img = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 48, color: Colors.brown.shade400),
                            const SizedBox(height: 8),
                            Text('ແຕະເພື່ອແນບຮູບ',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── ປຸ່ມ ──
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                    label: const Text('ຍົກເລີກ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.green.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed:
                        (_loading || _img == null) ? null : _confirm,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_img == null
                            ? Icons.photo_camera_outlined
                            : Icons.check_circle),
                    label: Text(
                      _loading
                          ? 'ກຳລັງບັນທຶກ...'
                          : (_img == null
                              ? 'ແນບຮູບກ່ອນ'
                              : 'ຢືນຢັນຮັບເງິນ'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
            ],
          ),

          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.brown,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'ກຳລັງບັນທຶກ...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _typeBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : color,
                )),
          ],
        ),
      ),
    );
  }

  String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    return v.startsWith(prefix) ? v : '$prefix$v';
  }
}