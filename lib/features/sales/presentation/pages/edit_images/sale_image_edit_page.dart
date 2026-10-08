import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/utils/cloudinary_service.dart';
import '../../../domain/entities/sale_order_entity.dart';
import '../../controllers/sales_controller.dart';

class SaleImageEditPage extends StatefulWidget {
  final SaleOrderEntity sale;
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
        color: SaleStyle.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera,
                color: SaleStyle.brown700,
              ),
              title: const Text(SaleStyle.pickCamera),
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
              leading: const Icon(
                Icons.photo_library,
                color: SaleStyle.brown700,
              ),
              title: const Text(SaleStyle.pickGallery),
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
      _snack(
        SaleStyle.alertTitleWarn,
        SaleStyle.alertImgRequired,
        SaleStyle.orange800,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // ⭐ 1. หา URL ที่ถอดออก (ยังไม่ลบ)
      final removed = <String>[
        ...widget.sale.paymentImageUrls.where((u) => !_payUrls.contains(u)),
        ...widget.sale.billImageUrls.where((u) => !_billUrls.contains(u)),
        ...widget.sale.topUpImageUrls.where((u) => !_topUpUrls.contains(u)),
      ];

      // ⭐ 2. Upload รูปใหม่ (ก่อน)
      Future<String?> up(File f, String folder) async {
        try {
          return await CloudinaryService.uploadImage(
            f,
            folder: folder,
          ).timeout(const Duration(seconds: 60));
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

      // ⭐ 3. Save DB ก่อน (สำคัญ!)
      await c.updateSaleImages(
        widget.sale.id,
        paymentImageUrls: finalPay,
        billImageUrls: finalBill,
        topUpImageUrls: finalTopUp,
      );

      // ⭐ 4. ลบ Cloudinary ทีหลัง (background — ไม่ await)
      if (removed.isNotEmpty) {
        CloudinaryService.deleteImages(removed).catchError((e) {
          debugPrint('Cloudinary cleanup error (ignored): $e');
        });
      }

      if (mounted) {
        Navigator.of(context).maybePop(true);
        Future.delayed(SaleStyle.delayAfter, () {
          _snack(
            SaleStyle.alertSuccess,
            SaleStyle.alertEditImgOk,
            SaleStyle.green700,
            Icons.check_circle,
          );
        });
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _snack(
        SaleStyle.errorMsg,
        '${SaleStyle.alertEditImgFail}: $e',
        SaleStyle.red700,
        Icons.error_outline,
      );
    }
  }

  void _snack(String t, String m, Color bg, IconData ic) {
    Get.closeAllSnackbars();
    Get.snackbar(
      t,
      m,
      backgroundColor: bg,
      colorText: SaleStyle.white,
      icon: Icon(ic, color: SaleStyle.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: SaleStyle.snackbarRadius,
      duration: SaleStyle.snackbarShort,
      boxShadows: [
        BoxShadow(
          color: bg.withOpacity(SaleStyle.fabGlowOpacity),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaleStyle.brown50,
      appBar: AppBar(
        title: const Text(SaleStyle.editImagesTitle),
        backgroundColor: SaleStyle.brown700,
        foregroundColor: SaleStyle.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: SaleStyle.padPage,
            children: [
              _infoCard(),
              SaleStyle.gap14,
              _sectionCard(
                title: SaleStyle.imgEditPay,
                subtitle: SaleStyle.imgEditPaySub,
                icon: Icons.payments_outlined,
                color: SaleStyle.green700,
                child: _grid(
                  urls: _payUrls,
                  files: _newPay,
                  onAdd: () => _pick(_newPay),
                  onRemoveUrl: (i) => setState(() => _payUrls.removeAt(i)),
                  onRemoveFile: (i) => setState(() => _newPay.removeAt(i)),
                ),
              ),
              SaleStyle.gap14,
              _sectionCard(
                title: SaleStyle.imgEditBill,
                subtitle: SaleStyle.imgEditBillSub,
                icon: Icons.receipt_long_outlined,
                color: SaleStyle.blue700,
                child: _grid(
                  urls: _billUrls,
                  files: _newBill,
                  onAdd: () => _pick(_newBill),
                  onRemoveUrl: (i) => setState(() => _billUrls.removeAt(i)),
                  onRemoveFile: (i) => setState(() => _newBill.removeAt(i)),
                ),
              ),
              SaleStyle.gap14,
              _sectionCard(
                title: SaleStyle.imgEditTopUp,
                subtitle: SaleStyle.imgEditTopUpSub,
                icon: Icons.add_card,
                color: SaleStyle.orange800,
                child: _grid(
                  urls: _topUpUrls,
                  files: _newTopUp,
                  onAdd: () => _pick(_newTopUp),
                  onRemoveUrl: (i) => setState(() => _topUpUrls.removeAt(i)),
                  onRemoveFile: (i) => setState(() => _newTopUp.removeAt(i)),
                ),
              ),
              SaleStyle.gap90,
            ],
          ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: SaleStyle.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(SaleStyle.loadingBoxPad),
                    decoration: BoxDecoration(
                      color: SaleStyle.white,
                      borderRadius: SaleStyle.r16,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: SaleStyle.brown700,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 14),
                        Text(SaleStyle.saving, style: SaleStyle.textLoadingBox),
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
          padding: SaleStyle.padBottomBar,
          decoration: BoxDecoration(
            color: SaleStyle.white,
            boxShadow: [
              BoxShadow(
                color: SaleStyle.black.withOpacity(
                  SaleStyle.imgSectionBgOpacity,
                ),
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
                  label: const Text(SaleStyle.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SaleStyle.grey700,
                    side: const BorderSide(color: SaleStyle.grey400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SaleStyle.r10,
                    ),
                  ),
                ),
              ),
              SaleStyle.gap10,
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: SaleStyle.loadingBoxSpinner,
                          height: SaleStyle.loadingBoxSpinner,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SaleStyle.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _saving ? SaleStyle.saving : SaleStyle.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SaleStyle.brown700,
                    foregroundColor: SaleStyle.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SaleStyle.r10,
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

  Widget _infoCard() {
    return Container(
      padding: SaleStyle.padCardLg,
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.cardRadius,
        border: Border.all(color: SaleStyle.brown200),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: SaleStyle.brown700,
            size: SaleStyle.iconInfoMd,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(SaleStyle.imgEditHint, style: SaleStyle.textInfoHint),
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
        color: SaleStyle.white,
        borderRadius: SaleStyle.cardRadiusLg,
        border: Border.all(
          color: color.withOpacity(SaleStyle.imgSectionBorderOpacity),
          width: SaleStyle.borderWidthNormal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: SaleStyle.padSectionHeaderImg,
            decoration: BoxDecoration(
              color: color.withOpacity(SaleStyle.imgSectionBgOpacity),
              borderRadius: SaleStyle.topR13,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: SaleStyle.iconMenuSmall),
                SaleStyle.gapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SaleStyle.textImgSectionTitle.copyWith(
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: SaleStyle.textImgSectionSub.copyWith(
                          color: color.withOpacity(
                            SaleStyle.imgSectionSubOpacity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: SaleStyle.padCardLg, child: child),
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
      tiles.add(
        _imgTile(
          child: CachedNetworkImage(
            imageUrl: urls[i],
            fit: BoxFit.cover,
            memCacheWidth: 200,
            placeholder: (c, u) => Container(color: SaleStyle.grey100),
            errorWidget: (_, _, _) =>
                const Icon(Icons.broken_image, color: SaleStyle.grey500),
          ),
          onRemove: () => onRemoveUrl(i),
        ),
      );
    }

    for (int i = 0; i < files.length; i++) {
      tiles.add(
        _imgTile(
          child: Image.file(files[i], fit: BoxFit.cover),
          onRemove: () => onRemoveFile(i),
          isNew: true,
        ),
      );
    }

    tiles.add(
      GestureDetector(
        onTap: onAdd,
        child: Container(
          width: SaleStyle.thumbSaleLg,
          height: SaleStyle.thumbSaleLg,
          decoration: BoxDecoration(
            color: SaleStyle.grey50,
            border: Border.all(
              color: SaleStyle.grey300,
              width: SaleStyle.borderWidthNormal,
            ),
            borderRadius: SaleStyle.r10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: SaleStyle.brown400,
                size: SaleStyle.iconAddPhoto,
              ),
              SaleStyle.gap4,
              const Text(SaleStyle.imgEditAdd, style: SaleStyle.textImgEditAdd),
            ],
          ),
        ),
      ),
    );

    return Wrap(
      spacing: SaleStyle.wrapSpacing,
      runSpacing: SaleStyle.wrapRunSpacing,
      children: tiles,
    );
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
          width: SaleStyle.thumbSaleLg,
          height: SaleStyle.thumbSaleLg,
          decoration: BoxDecoration(
            borderRadius: SaleStyle.r10,
            border: Border.all(
              color: isNew ? SaleStyle.green700 : SaleStyle.grey300,
              width: isNew
                  ? SaleStyle.borderWidthActive
                  : SaleStyle.borderWidthNormal,
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
              padding: SaleStyle.padImgCloseBadge,
              decoration: const BoxDecoration(
                color: SaleStyle.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: SaleStyle.iconCloseSm,
                color: SaleStyle.white,
              ),
            ),
          ),
        ),
        if (isNew)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: SaleStyle.padBadgeTiny,
              decoration: BoxDecoration(
                color: SaleStyle.green700,
                borderRadius: SaleStyle.r4,
              ),
              child: const Text(
                SaleStyle.imgEditNew,
                style: SaleStyle.textBadgeNew,
              ),
            ),
          ),
      ],
    );
  }
}
