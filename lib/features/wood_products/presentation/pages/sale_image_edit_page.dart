import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wood/core/util/cloudinary_service.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';

class SaleImageEditPage extends StatefulWidget {
  final SaleEntity sale;
  const SaleImageEditPage({super.key, required this.sale});

  @override
  State<SaleImageEditPage> createState() => _SaleImageEditPageState();
}

class _SaleImageEditPageState extends State<SaleImageEditPage> {
  final c = Get.find<SalesController>();
  final picker = ImagePicker();

  late List<String> _payUrls;
  late List<String> _billUrls;
  late List<String> _topUpUrls;

  final List<File> _newPay = [];
  final List<File> _newBill = [];
  final List<File> _newTopUp = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _payUrls = List.from(widget.sale.paymentImageUrls);
    _billUrls = List.from(widget.sale.billImageUrls);
    _topUpUrls = List.from(widget.sale.topUpImageUrls);
  }

  Future<void> _pick(List<File> target) async {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.brown),
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
                setState(() => target.add(File(p.path)));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Colors.brown),
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
                setState(() => target.add(File(p.path)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    if (_payUrls.isEmpty && _newPay.isEmpty) {
      _snack('ຂາດຂໍ້ມູນ', 'ຕ້ອງມີຮູບການຊຳລະຢ່າງໜ້ອຍ 1 ຮູບ',
          Colors.orange.shade800, Icons.warning_amber_rounded);
      return;
    }

    setState(() => _saving = true);

    try {
      final removed = <String>[
        ...widget.sale.paymentImageUrls.where((u) => !_payUrls.contains(u)),
        ...widget.sale.billImageUrls.where((u) => !_billUrls.contains(u)),
        ...widget.sale.topUpImageUrls.where((u) => !_topUpUrls.contains(u)),
      ];
      if (removed.isNotEmpty) {
        try {
          await CloudinaryService.deleteImages(removed);
        } catch (_) {}
      }

      Future<String?> up(File f, String folder) async {
        try {
          return await CloudinaryService.uploadImage(f, folder: folder)
              .timeout(const Duration(seconds: 60));
        } catch (_) {
          return null;
        }
      }

      final newPayUrls = <String>[];
      for (final f in _newPay) {
        final u = await up(f, 'sales/payments');
        if (u != null) newPayUrls.add(u);
      }
      final newBillUrls = <String>[];
      for (final f in _newBill) {
        final u = await up(f, 'sales/bills');
        if (u != null) newBillUrls.add(u);
      }
      final newTopUpUrls = <String>[];
      for (final f in _newTopUp) {
        final u = await up(f, 'sales/topup');
        if (u != null) newTopUpUrls.add(u);
      }

      final finalPay = [..._payUrls, ...newPayUrls];
      final finalBill = [..._billUrls, ...newBillUrls];
      final finalTopUp = [..._topUpUrls, ...newTopUpUrls];

      await c.updateSaleImages(
        widget.sale.id,
        paymentImageUrls: finalPay,
        billImageUrls: finalBill,
        topUpImageUrls: finalTopUp,
      );

      if (mounted) {
        Navigator.of(context).maybePop(true);
        Future.delayed(const Duration(milliseconds: 250), () {
          _snack('ສຳເລັດ', 'ແກ້ໄຂຮູບຮຽບຮ້ອຍແລ້ວ',
              Colors.green.shade700, Icons.check_circle);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _snack('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e',
          Colors.red.shade700, Icons.error_outline);
    }
  }

  void _snack(String t, String m, Color bg, IconData ic) {
    Get.closeAllSnackbars();
    Get.snackbar(
      t, m,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(ic, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: bg.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('ແກ້ໄຂຮູບພາບ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _infoCard(),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'ຮູບການຊຳລະ',
                subtitle: 'ຮູບເງິນສົດ / ສະລິບໂອນ',
                icon: Icons.payments_outlined,
                color: Colors.green.shade700,
                child: _grid(
                  urls: _payUrls,
                  files: _newPay,
                  onAdd: () => _pick(_newPay),
                  onRemoveUrl: (i) => setState(() => _payUrls.removeAt(i)),
                  onRemoveFile: (i) => setState(() => _newPay.removeAt(i)),
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'ຮູບໃບບິນ',
                subtitle: 'ໃບບິນຮ້ານ / ໃບບິນໜີ້',
                icon: Icons.receipt_long_outlined,
                color: Colors.blue.shade700,
                child: _grid(
                  urls: _billUrls,
                  files: _newBill,
                  onAdd: () => _pick(_newBill),
                  onRemoveUrl: (i) => setState(() => _billUrls.removeAt(i)),
                  onRemoveFile: (i) =>
                      setState(() => _newBill.removeAt(i)),
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'ຮູບເງິນເຕີມ',
                subtitle: 'ສະລິບ / ສົດເຕີມ',
                icon: Icons.add_card,
                color: Colors.orange.shade800,
                child: _grid(
                  urls: _topUpUrls,
                  files: _newTopUp,
                  onAdd: () => _pick(_newTopUp),
                  onRemoveUrl: (i) =>
                      setState(() => _topUpUrls.removeAt(i)),
                  onRemoveFile: (i) =>
                      setState(() => _newTopUp.removeAt(i)),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
          if (_saving)
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
                            color: Colors.brown, strokeWidth: 3),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                  label: const Text('ຍົກເລີກ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _saving ? 'ກຳລັງບັນທຶກ...' : 'ບັນທຶກ',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.brown.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ແກ້ໄຂໄດ້ສະເພາະຮູບ — ບໍ່ສາມາດແກ້ລາຄາ / ຈຳນວນ / ລູກຄ້າ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: color.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _grid({
    required List<String> urls,
    required List<File> files,
    required VoidCallback onAdd,
    required void Function(int) onRemoveUrl,
    required void Function(int) onRemoveFile,
  }) {
    final tiles = <Widget>[];

    for (int i = 0; i < urls.length; i++) {
      tiles.add(_imgTile(
        child: CachedNetworkImage(
          imageUrl: urls[i],
          fit: BoxFit.cover,
          memCacheWidth: 200,
          placeholder: (c, u) => Container(color: Colors.grey.shade100),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        ),
        onRemove: () => onRemoveUrl(i),
      ));
    }

    for (int i = 0; i < files.length; i++) {
      tiles.add(_imgTile(
        child: Image.file(files[i], fit: BoxFit.cover),
        onRemove: () => onRemoveFile(i),
        isNew: true,
      ));
    }

    tiles.add(
      GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  color: Colors.brown.shade400, size: 26),
              const SizedBox(height: 4),
              Text(
                'ເພີ່ມຮູບ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.brown.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Wrap(spacing: 8, runSpacing: 8, children: tiles);
  }

  Widget _imgTile({
    required Widget child,
    required VoidCallback onRemove,
    bool isNew = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isNew ? Colors.green : Colors.grey.shade300,
              width: isNew ? 2 : 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: child,
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
        if (isNew)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ໃໝ່',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}