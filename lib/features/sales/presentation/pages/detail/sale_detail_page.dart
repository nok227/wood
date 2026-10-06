import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/core/widgets/global/app_image_viewer.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/wood_products/domain/entities/wood_product.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import 'package:wood/features/wood_products/presentation/widgets/option_tile.dart';

import '../../../domain/entities/sale_order_entity.dart';
import '../../controllers/sales_controller.dart';
import '../debt_payment/debt_payment_page.dart';
import '../edit_images/sale_image_edit_page.dart';

import 'dart:ui' as ui;

enum _Alert { success, error, warning, info }

class SaleDetailPage extends StatefulWidget {
  final SaleOrderEntity sale;
  const SaleDetailPage({super.key, required this.sale});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  final ScreenshotController _screenshotCtrl = ScreenshotController();
  bool _savingImage = false;

  double? _downX;
  double? _downY;
  static const double _minSwipe = 60;
  static const double _hRatio = 1.2;

  bool _wasDeletedOnce = false;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  SaleOrderEntity get _liveSale {
    final list = Get.find<SalesController>().allSalesList;
    for (final s in list) {
      if (s.id == widget.sale.id) return s;
    }
    return widget.sale;
  }

  bool get _isDeleted {
    final list = Get.find<SalesController>().allSalesList;
    for (final s in list) {
      if (s.id == widget.sale.id) return false;
    }
    return true;
  }

  String _fmtDim(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  WoodProduct? _findProduct(String productId) {
    try {
      final products = Get.find<WoodProductController>().products;
      for (final p in products) {
        if (p.id == productId) return p;
      }
    } catch (_) {}
    return null;
  }

  String? _dimensionText(WoodProduct? p) {
    if (p == null) return null;
    return '${_fmtDim(p.width)}×${_fmtDim(p.length)}×${_fmtDim(p.thickness)} ${p.sizeUnit}';
  }

  String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return SaleStyle.dash;
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

  void _snack(String title, String msg, {_Alert type = _Alert.info}) {
    Get.closeAllSnackbars();
    late Color bg;
    late IconData icon;
    switch (type) {
      case _Alert.success:
        bg = SaleStyle.green700;
        icon = Icons.check_circle;
        break;
      case _Alert.error:
        bg = SaleStyle.red700;
        icon = Icons.error_outline;
        break;
      case _Alert.warning:
        bg = SaleStyle.orange800;
        icon = Icons.warning_amber_rounded;
        break;
      case _Alert.info:
        bg = SaleStyle.brown700;
        icon = Icons.info_outline;
        break;
    }
    Get.snackbar(
      title,
      msg,
      backgroundColor: bg,
      colorText: SaleStyle.white,
      icon: Icon(icon, color: SaleStyle.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: SaleStyle.snackbarRadius,
      duration: type == _Alert.error
          ? SaleStyle.snackbarLong
          : SaleStyle.snackbarShort,
      isDismissible: true,
      animationDuration: SaleStyle.delayDialog,
      boxShadows: [
        BoxShadow(
          color: bg.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _ok(String t, String m) => _snack(t, m, type: _Alert.success);
  void _err(String t, String m) => _snack(t, m, type: _Alert.error);
  void _warn(String t, String m) => _snack(t, m, type: _Alert.warning);

  Future<void> _saveToDevice() async {
    if (_savingImage) return;
    setState(() => _savingImage = true);
    try {
      final sale = _liveSale;
      final ctrl = Get.find<SalesController>();
      final fmt = NumberFormat('#,###');
      final isAdmin = Get.find<AuthController>().isAdmin;

      final payTitle = sale.paymentType == 'cash'
          ? SaleStyle.detailCashLabel
          : SaleStyle.detailTransferLabel;
      final payUrl = _first(sale.paymentImageUrls);
      final billUrl = _first(sale.billImageUrls);
      final thirdUrl =
          _first(sale.debtPaymentImageUrls) ?? _first(sale.topUpImageUrls);
      final thirdLabel = sale.debtPaymentImageUrls.any((u) => u.isNotEmpty)
          ? SaleStyle.previewImgDebt
          : SaleStyle.previewImgTopUp;

      final allImages = <AppImageItem>[
        ...sale.paymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => AppImageItem(u, label: payTitle)),
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

      for (final img in allImages) {
        try {
          await precacheImage(NetworkImage(img.url), context);
        } catch (_) {}
      }

      final screenWidth = MediaQuery.of(context).size.width;

      final imageBytes = await _screenshotCtrl.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Material(
              color: SaleStyle.bg,
              child: UnconstrainedBox(
                alignment: Alignment.topLeft,
                constrainedAxis: Axis.horizontal,
                child: SizedBox(
                  width: screenWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 28),
                    child: _buildPageContent(
                      sale: sale,
                      ctrl: ctrl,
                      fmt: fmt,
                      isAdmin: isAdmin,
                      payUrl: payUrl,
                      billUrl: billUrl,
                      thirdUrl: thirdUrl,
                      payLabel: payTitle,
                      thirdLabel: thirdLabel,
                      allImages: allImages,
                      forCapture: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 700),
        context: context,
      );

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);

      final fileName = 'sale_detail_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(imageBytes, name: fileName);

      if (mounted) _ok(SaleStyle.alertSuccess, SaleStyle.saveImageSuccess);
    } catch (e, st) {
      debugPrint('❌ ERROR: $e');
      debugPrint('$st');
      if (mounted) _err(SaleStyle.errorMsg, '${SaleStyle.saveImageError}: $e');
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  void _onPointerDown(PointerDownEvent e) {
    _downX = e.position.dx;
    _downY = e.position.dy;
  }

  void _onPointerUp(PointerUpEvent e) {
    final dx0 = _downX;
    final dy0 = _downY;
    _downX = null;
    _downY = null;
    if (dx0 == null || dy0 == null) return;
    final dx = e.position.dx - dx0;
    final dy = e.position.dy - dy0;
    if (dx.abs() < _minSwipe) return;
    if (dx.abs() < dy.abs() * _hRatio) return;
    HapticFeedback.lightImpact();
    Get.back();
  }

  Future<void> _openImageEditor(SalesController ctrl) async {
    final result = await Get.to<bool>(() => SaleImageEditPage(sale: _liveSale));
    if (result == true) _ok(SaleStyle.alertSuccess, SaleStyle.alertEditImgOk);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isDeleted) {
        if (!_wasDeletedOnce) {
          _wasDeletedOnce = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final route = ModalRoute.of(context);
            if (route != null && route.isCurrent) Get.back();
          });
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final sale = _liveSale;
      final ctrl = Get.find<SalesController>();
      final fmt = NumberFormat('#,###');
      final isAdmin = Get.find<AuthController>().isAdmin;

      final payTitle = sale.paymentType == 'cash'
          ? SaleStyle.detailCashLabel
          : SaleStyle.detailTransferLabel;
      final payUrl = _first(sale.paymentImageUrls);
      final billUrl = _first(sale.billImageUrls);
      final thirdUrl =
          _first(sale.debtPaymentImageUrls) ?? _first(sale.topUpImageUrls);
      final thirdLabel = sale.debtPaymentImageUrls.any((u) => u.isNotEmpty)
          ? SaleStyle.previewImgDebt
          : SaleStyle.previewImgTopUp;

      final allImages = <AppImageItem>[
        ...sale.paymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => AppImageItem(u, label: payTitle)),
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

      return Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: SaleStyle.bg,
          appBar: _buildAppBar(isAdmin, ctrl),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            child: _buildPageContent(
              sale: sale,
              ctrl: ctrl,
              fmt: fmt,
              isAdmin: isAdmin,
              payUrl: payUrl,
              billUrl: billUrl,
              thirdUrl: thirdUrl,
              payLabel: payTitle,
              thirdLabel: thirdLabel,
              allImages: allImages,
              forCapture: false,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPageContent({
    required SaleOrderEntity sale,
    required SalesController ctrl,
    required NumberFormat fmt,
    required bool isAdmin,
    required String? payUrl,
    required String? billUrl,
    required String? thirdUrl,
    required String payLabel,
    required String thirdLabel,
    required List<AppImageItem> allImages,
    required bool forCapture,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!forCapture) ...[_buildSummaryHeader(sale, fmt), SaleStyle.gapMd],
        _buildCombinedCard(
          sale: sale,
          ctrl: ctrl,
          fmt: fmt,
          payUrl: payUrl,
          billUrl: billUrl,
          thirdUrl: thirdUrl,
          payLabel: payLabel,
          thirdLabel: thirdLabel,
          allImages: allImages,
          isAdmin: isAdmin,
        ),
        SaleStyle.gapLg,
        _statusBanner(ctrl, isAdmin, sale),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(bool isAdmin, SalesController ctrl) {
    return AppBar(
      title: const Text(
        SaleStyle.detailPageTitle,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      backgroundColor: SaleStyle.brown700,
      foregroundColor: SaleStyle.white,
      elevation: 0,
      actions: [
        if (_savingImage)
          const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: SaleStyle.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22),
            tooltip: SaleStyle.detailSaveDevice,
            onPressed: _saveToDevice,
          ),
        if (isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: SaleStyle.detailSettings,
            offset: const Offset(0, 44),
            shape: const RoundedRectangleBorder(borderRadius: SaleStyle.r12),
            onSelected: (v) {
              switch (v) {
                case 'edit_images':
                  _openImageEditor(ctrl);
                  break;
                case 'delete':
                  _deleteDialog(ctrl);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit_images',
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_size_select_large_outlined,
                      color: SaleStyle.brown700,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      SaleStyle.detailEditImages,
                      style: TextStyle(
                        color: SaleStyle.brown700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: SaleStyle.mismatch,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      SaleStyle.detailDelete,
                      style: TextStyle(
                        color: SaleStyle.mismatch,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(SaleOrderEntity sale, NumberFormat fmt) {
    final isDebt = sale.hasDebt;
    final isConfirmed = sale.isConfirmed;
    final isMismatch = sale.isMismatch;

    Color accent;
    IconData badgeIcon;
    String badgeText;

    if (isMismatch) {
      accent = SaleStyle.mismatch;
      badgeIcon = Icons.warning_amber_rounded;
      badgeText = SaleStyle.detailStatusMismatch;
    } else if (isConfirmed) {
      accent = SaleStyle.confirmed;
      badgeIcon = Icons.check_circle;
      badgeText = SaleStyle.detailStatusConfirmed;
    } else if (isDebt) {
      accent = SaleStyle.orange800;
      badgeIcon = Icons.schedule;
      badgeText = SaleStyle.debtLabel;
    } else {
      accent = SaleStyle.amber800;
      badgeIcon = Icons.hourglass_bottom;
      badgeText = SaleStyle.summaryPending;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SaleStyle.brown700, SaleStyle.brown500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: SaleStyle.r14,
        boxShadow: [
          BoxShadow(
            color: SaleStyle.brown700.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sale.shortSummary,
                      style: const TextStyle(
                        color: SaleStyle.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sale.itemCount} ${SaleStyle.summaryItemsUnit} · ${sale.totalQuantity} ${SaleStyle.summaryPiecesUnit}',
                      style: TextStyle(
                        color: SaleStyle.white.withOpacity(0.75),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: SaleStyle.r20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: SaleStyle.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        color: SaleStyle.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SaleStyle.white.withOpacity(0.15),
              borderRadius: SaleStyle.r10,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: SaleStyle.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    SaleStyle.detailNetLabel,
                    style: TextStyle(
                      color: SaleStyle.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${fmt.format(sale.totalAmount)} ${SaleStyle.currency}',
                  style: const TextStyle(
                    color: SaleStyle.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: SaleStyle.white.withOpacity(0.7),
                size: 11,
              ),
              const SizedBox(width: 5),
              Text(
                _formatFullDate(sale.date),
                style: TextStyle(
                  color: SaleStyle.white.withOpacity(0.8),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime d) {
    const days = [
      'ວັນຈັນ',
      'ວັນອັງຄານ',
      'ວັນພຸດ',
      'ວັນພະຫັດ',
      'ວັນສຸກ',
      'ວັນເສົາ',
      'ວັນອາທິດ',
    ];
    return '${days[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCombinedCard({
    required SaleOrderEntity sale,
    required SalesController ctrl,
    required NumberFormat fmt,
    required String? payUrl,
    required String? billUrl,
    required String? thirdUrl,
    required String payLabel,
    required String thirdLabel,
    required List<AppImageItem> allImages,
    required bool isAdmin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SaleStyle.white,
        borderRadius: SaleStyle.r14,
        boxShadow: SaleStyle.cardMd,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _sectionLabel(
              Icons.photo_library_outlined,
              SaleStyle.detailImgLabel,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _imageTile9x16(
                    payUrl,
                    payLabel,
                    onTap: payUrl == null
                        ? null
                        : () => Get.to(
                            () => AppImageViewer(
                              images: allImages,
                              initialIndex: 0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _imageTile9x16(
                    thirdUrl,
                    thirdLabel,
                    onTap: thirdUrl == null
                        ? null
                        : () => Get.to(
                            () => AppImageViewer(
                              images: allImages,
                              initialIndex: _firstIndexInViewer(
                                allImages,
                                thirdUrl,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _imageTile9x16(
                    billUrl,
                    SaleStyle.detailBillLabel,
                    onTap: billUrl == null
                        ? null
                        : () => Get.to(
                            () => AppImageViewer(
                              images: allImages,
                              initialIndex: _firstIndexInViewer(
                                allImages,
                                billUrl,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            _dashedDivider(),
            _sectionLabel(
              Icons.inventory_2_outlined,
              '${SaleStyle.sectionItems} (${sale.itemCount})',
            ),
            const SizedBox(height: 10),
            ..._buildItemsList(sale, fmt),
            if (sale.hasDiscount) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.discount, size: 13, color: SaleStyle.red600),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      SaleStyle.discountTotal,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SaleStyle.red700,
                      ),
                    ),
                  ),
                  Text(
                    '-${fmt.format(sale.discountTotal)} ${SaleStyle.currency}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: SaleStyle.red700,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    SaleStyle.totalLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: SaleStyle.brown800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${fmt.format(sale.totalAmount)} ${SaleStyle.currency}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: SaleStyle.brown800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            _dashedDivider(),
            _sectionLabel(Icons.payments_outlined, SaleStyle.detailPayLabel),
            const SizedBox(height: 10),
            ..._buildPaymentLines(sale, fmt),
            if (sale.hasDebt) ...[
              _dashedDivider(),
              _sectionLabel(
                Icons.person_outline,
                SaleStyle.detailCustomerLabel,
                color: SaleStyle.orange800,
              ),
              const SizedBox(height: 10),
              ..._buildCustomerLines(sale, ctrl),
            ],
            if ((sale.note ?? '').trim().isNotEmpty) ...[
              _dashedDivider(),
              _sectionLabel(
                Icons.sticky_note_2_outlined,
                SaleStyle.detailNoteLabel,
              ),
              const SizedBox(height: 8),
              Text(
                sale.note!,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: SaleStyle.grey800,
                ),
              ),
            ],
            if (sale.isMismatch &&
                (sale.mismatchNote ?? '').trim().isNotEmpty) ...[
              _dashedDivider(),
              _sectionLabel(
                Icons.warning_amber_rounded,
                SaleStyle.detailMismatchLabel,
                color: SaleStyle.mismatch,
              ),
              const SizedBox(height: 8),
              Text(
                sale.mismatchNote!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: SaleStyle.mismatch,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String text, {Color? color}) {
    final c = color ?? SaleStyle.brown700;
    return Row(
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: c,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
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
                color: SaleStyle.grey200,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imageTile9x16(String? url, String label, {VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: url != null ? onTap : null,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: SaleStyle.grey100,
                borderRadius: SaleStyle.r8,
              ),
              child: ClipRRect(
                borderRadius: SaleStyle.r8,
                child: url != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (c, child, p) {
                              if (p == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 22,
                                color: SaleStyle.grey400,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: SaleStyle.black45,
                                borderRadius: SaleStyle.r5,
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: SaleStyle.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported_outlined,
                            size: 22,
                            color: SaleStyle.grey400,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            SaleStyle.detailNoImg,
                            style: const TextStyle(
                              fontSize: 9,
                              color: SaleStyle.grey500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: SaleStyle.grey600,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  int _firstIndexInViewer(List<AppImageItem> items, String? url) {
    if (url == null) return 0;
    final idx = items.indexWhere((e) => e.url == url);
    return idx < 0 ? 0 : idx;
  }

  List<Widget> _buildItemsList(SaleOrderEntity sale, NumberFormat fmt) {
    final out = <Widget>[];
    for (int idx = 0; idx < sale.items.length; idx++) {
      final it = sale.items[idx];
      final product = _findProduct(it.productId);
      final dimText = product != null
          ? _dimensionText(product)
          : (it.hasSize ? it.dimensionText : null);

      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${idx + 1}.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: SaleStyle.grey400,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      it.productName,
                      style: SaleStyle.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (it.woodType.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          'ຊະນິດ: ${it.woodType}',
                          style: SaleStyle.itemDim,
                        ),
                      ),
                    if (dimText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          '${SaleStyle.itemDimPrefix}: $dimText',
                          style: SaleStyle.itemDim,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Row(
                        children: [
                          Text(
                            '${it.quantity} ${it.unit} × ${fmt.format(it.unitPrice)}',
                            style: SaleStyle.itemDim,
                          ),
                          if (it.hasDiscount) ...[
                            const SizedBox(width: 4),
                            Text(
                              '· ${SaleStyle.itemDiscountPrefix} ${fmt.format(it.discountPerUnit)}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: SaleStyle.red600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                fmt.format(it.totalAmount),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: SaleStyle.brown700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return out;
  }

  List<Widget> _buildPaymentLines(SaleOrderEntity sale, NumberFormat fmt) {
    final payLabel = sale.paymentType == 'cash'
        ? SaleStyle.cashFull
        : sale.paymentType == 'transfer'
        ? SaleStyle.transferFull
        : sale.paymentType == 'mixed'
        ? SaleStyle.mixedLabel
        : SaleStyle.debtLabel;

    final payColor = sale.paymentType == 'cash'
        ? SaleStyle.green700
        : sale.paymentType == 'transfer'
        ? SaleStyle.blue700
        : sale.paymentType == 'mixed'
        ? SaleStyle.indigo700
        : SaleStyle.orange800;

    final out = <Widget>[];
    out.add(
      Row(
        children: [
          const Text(
            '${SaleStyle.detailMethodLabel}: ',
            style: TextStyle(fontSize: 12, color: SaleStyle.grey500),
          ),
          Text(
            payLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: payColor,
            ),
          ),
        ],
      ),
    );

    if (sale.cashPaidAmount > 0) {
      out.add(const SizedBox(height: 4));
      out.add(
        _moneyRow(
          SaleStyle.detailCashPrefix,
          '${fmt.format(sale.cashPaidAmount)} ${SaleStyle.currency}',
          SaleStyle.green700,
        ),
      );
    }
    if (sale.transferPaidAmount > 0) {
      out.add(const SizedBox(height: 4));
      out.add(
        _moneyRow(
          SaleStyle.detailTransferPrefix,
          '${fmt.format(sale.transferPaidAmount)} ${SaleStyle.currency}',
          SaleStyle.blue700,
        ),
      );
    }
    if (sale.receivedAmount > 0 && sale.paymentType == 'cash') {
      out.add(const SizedBox(height: 4));
      out.add(
        _moneyRow(
          SaleStyle.detailReceived,
          '${fmt.format(sale.receivedAmount)} ${SaleStyle.currency}',
          SaleStyle.grey800,
        ),
      );
    }
    if (sale.changeAmount > 0) {
      out.add(const SizedBox(height: 4));
      out.add(
        _moneyRow(
          SaleStyle.detailChange,
          '${fmt.format(sale.changeAmount)} ${SaleStyle.currency}',
          SaleStyle.blue700,
          bold: true,
        ),
      );
    }
    if (sale.hasDebt) {
      out.add(const SizedBox(height: 4));
      out.add(
        _moneyRow(
          SaleStyle.detailDebtAmount,
          '${fmt.format(sale.debtAmount)} ${SaleStyle.currency}',
          SaleStyle.orange800,
          bold: true,
        ),
      );
    }
    return out;
  }

  Widget _moneyRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: SaleStyle.grey600,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 13.5 : 12.5,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCustomerLines(SaleOrderEntity sale, SalesController ctrl) {
    final out = <Widget>[];
    if ((sale.customerName ?? '').trim().isNotEmpty) {
      out.add(
        _infoLine(
          Icons.person,
          'ຊື່',
          _wPrefix(sale.customerName, 'ຊື່'),
          SaleStyle.orange800,
        ),
      );
    }
    if ((sale.customerPhone ?? '').trim().isNotEmpty) {
      out.add(
        _infoLine(
          Icons.phone,
          SaleStyle.detailPhonePrefix,
          sale.customerPhone!,
          SaleStyle.orange800,
        ),
      );
    }
    if ((sale.customerAddress ?? '').trim().isNotEmpty) {
      out.add(
        _infoLine(
          Icons.home,
          SaleStyle.detailAddrPrefix,
          _wPrefix(sale.customerAddress, 'ບ້ານ'),
          SaleStyle.orange800,
        ),
      );
    }
    if (sale.debtDate != null) {
      out.add(
        _infoLine(
          Icons.calendar_today,
          'ວັນທີຕິດໜີ້',
          ctrl.formatLaoDate(sale.debtDate!),
          SaleStyle.orange800,
        ),
      );
    }
    if ((sale.debtNote ?? '').trim().isNotEmpty) {
      out.add(
        _infoLine(
          Icons.sticky_note_2,
          SaleStyle.detailNoteLabel,
          sale.debtNote!,
          SaleStyle.orange800,
        ),
      );
    }
    return out;
  }

  Widget _infoLine(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: SaleStyle.grey600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(
    SalesController ctrl,
    bool isAdmin,
    SaleOrderEntity sale,
  ) {
    final Color c;
    final String txt;
    final IconData? icon;

    if (sale.isMismatch) {
      c = SaleStyle.mismatch;
      txt = SaleStyle.detailStatusMismatch;
      icon = Icons.warning_amber_rounded;
    } else if (sale.isConfirmed) {
      c = SaleStyle.confirmed;
      txt = SaleStyle.detailStatusConfirmed;
      icon = Icons.check_circle;
    } else if (sale.hasDebt) {
      c = SaleStyle.amber800;
      txt = SaleStyle.detailStatusDebtPending;
      icon = null;
    } else {
      c = SaleStyle.amber800;
      txt = SaleStyle.detailStatusPending;
      icon = null;
    }

    final clickable = isAdmin && !sale.isConfirmed;

    final banner = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: SaleStyle.r14,
        border: Border.all(color: c.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon, color: c, size: 20) : _spinIcon(c),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              txt,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: c,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (clickable) ...[
            const SizedBox(width: 6),
            Icon(Icons.touch_app, color: c, size: 16),
          ],
        ],
      ),
    );

    if (!clickable) return banner;
    return InkWell(
      onTap: () => _onStatusTap(ctrl, sale),
      borderRadius: SaleStyle.r14,
      child: banner,
    );
  }

  Widget _spinIcon(Color c) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _spinCtrl,
            child: Icon(Icons.hourglass_bottom, color: c, size: 16),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          ),
        ],
      ),
    );
  }

  void _onStatusTap(SalesController ctrl, SaleOrderEntity sale) {
    if (sale.isMismatch) {
      _mismatchDialog(ctrl, isEdit: true, sale: sale);
    } else if (sale.hasDebt) {
      _confirmReceiveDebt(ctrl, sale);
    } else {
      _pendingDialog(ctrl, sale);
    }
  }

  void _confirmReceiveDebt(SalesController c, SaleOrderEntity sale) {
    final name = _wPrefix(sale.customerName, 'ຊື່');
    final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');

    Get.defaultDialog(
      title: SaleStyle.confirmReceivePayment,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 48, color: SaleStyle.green600),
            const SizedBox(height: 8),
            if (name.isNotEmpty && name != SaleStyle.dash)
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
            if (addr.isNotEmpty && addr != SaleStyle.dash) ...[
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
        if (!mounted) return;
        Get.to(() => DebtPaymentPage(sale: sale));
      },
    );
  }

  void _pendingDialog(SalesController c, SaleOrderEntity sale) {
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
          const SizedBox(height: 4),
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
              _ok(SaleStyle.alertSuccess, SaleStyle.alertConfirmPaid);
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
              if (!mounted) return;
              _mismatchDialog(c, isEdit: false, sale: sale);
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

  void _mismatchDialog(
    SalesController c, {
    required bool isEdit,
    required SaleOrderEntity sale,
  }) {
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
          mainAxisSize: MainAxisSize.min,
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
                        _ok(
                          SaleStyle.alertSuccess,
                          SaleStyle.alertCancelStatus,
                        );
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
                          _warn(
                            SaleStyle.alertTitle,
                            SaleStyle.alertFillReason,
                          );
                          return;
                        }
                        _safeCloseDialog();
                        await Future.delayed(SaleStyle.delayDialog);
                        await c.updateMismatchNote(sale.id, t);
                        _ok(SaleStyle.alertSuccess, SaleStyle.alertUpdatedNote);
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
                      _warn(SaleStyle.alertTitle, SaleStyle.alertFillReason);
                      return;
                    }
                    _safeCloseDialog();
                    await Future.delayed(SaleStyle.delayDialog);
                    await c.markAsMismatch(sale.id, t);
                    _ok(SaleStyle.alertSuccess, SaleStyle.alertMismatchSaved);
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
      textCancel: SaleStyle.detailCloseDialog,
      textConfirm: '',
    );
  }

  void _deleteDialog(SalesController c) {
    Get.defaultDialog(
      title: SaleStyle.confirmDelete,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: SaleStyle.red600,
            ),
            const SizedBox(height: 8),
            Text(
              widget.sale.shortSummary,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${NumberFormat('#,###').format(widget.sale.totalAmount)} ${SaleStyle.currency}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SaleStyle.brown700,
              ),
            ),
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
          ],
        ),
      ),
      textConfirm: SaleStyle.delete,
      textCancel: SaleStyle.cancel,
      confirmTextColor: SaleStyle.white,
      cancelTextColor: SaleStyle.grey700,
      buttonColor: SaleStyle.red700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(SaleStyle.delayDialog);
        await c.deleteSale(widget.sale.id);
        _ok(SaleStyle.alertSuccess, SaleStyle.alertDeleted);
      },
    );
  }

  String? _first(List<String> urls) {
    for (final u in urls) {
      if (u.isNotEmpty) return u;
    }
    return null;
  }
}
