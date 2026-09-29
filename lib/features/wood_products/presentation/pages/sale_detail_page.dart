import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import 'package:wood/core/util/option_tile.dart';

import '../../domain/entities/sale_order_entity.dart';
import '../controllers/sales_controller.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import '../widgets/sale_image_viewer.dart';
import 'debt_payment_page.dart';
import 'sale_image_edit_page.dart';
import '../../../auth/auth_controller.dart';

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
  bool _saving = false;

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

  WoodProductModel? _findProduct(String productId) {
    try {
      final products = Get.find<WoodProductController>().products;
      for (final p in products) {
        if (p.id == productId) return p;
      }
    } catch (_) {}
    return null;
  }

  String _fmtDim(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  String? _dimensionText(WoodProductModel? p) {
    if (p == null) return null;
    return '${_fmtDim(p.width)}×${_fmtDim(p.length)}×${_fmtDim(p.thickness)} ${p.sizeUnit}';
  }

  String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '-';
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

  // ══════════════════════════════════════════════
  // 🎨 Snackbar
  // ══════════════════════════════════════════════
  void _snack(String title, String msg, {_Alert type = _Alert.info}) {
    Get.closeAllSnackbars();

    late Color bg;
    late IconData icon;

    switch (type) {
      case _Alert.success:
        bg = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case _Alert.error:
        bg = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      case _Alert.warning:
        bg = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case _Alert.info:
        bg = Colors.brown.shade700;
        icon = Icons.info_outline;
        break;
    }

    Get.snackbar(
      title,
      msg,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: type == _Alert.error ? 3 : 2),
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
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
  void _info(String t, String m) => _snack(t, m, type: _Alert.info);

  // ══════════════════════════════════════════════
  // 💾 ບັນທຶກລົງເຄື່ອງ
  //    • ບໍ່ມີ AppBar  →  ບໍ່ມີ header  →  ບໍ່ overflow
  // ══════════════════════════════════════════════
  Future<void> _saveToDevice() async {
    if (_savingImage) return;
    setState(() => _savingImage = true);

    try {
      final sale = _liveSale;
      final ctrl = Get.find<SalesController>();
      final fmt = NumberFormat('#,###');
      final isAdmin = Get.find<AuthController>().isAdmin;

      // ── ກະກຽມ data ──
      final payTitle =
          sale.paymentType == 'cash' ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບໂອນ';
      final payUrl = _first(sale.paymentImageUrls);
      final billUrl = _first(sale.billImageUrls);
      final thirdUrl =
          _first(sale.debtPaymentImageUrls) ?? _first(sale.topUpImageUrls);
      final thirdLabel = sale.debtPaymentImageUrls.any((u) => u.isNotEmpty)
          ? 'ຮູບຈ່າຍໜີ້'
          : 'ຮູບເງິນເຕີມ';

      final allImages = <SaleImageItem>[
        ...sale.paymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, payTitle)),
        ...sale.topUpImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບເງິນເຕີມ')),
        ...sale.billImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບໃບບິນ')),
        ...sale.debtPaymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບຈ່າຍໜີ້')),
      ];

      // ✅ Precache ຮູບທັງໝົດ ກ່ອນ capture
      for (final img in allImages) {
        try {
          await precacheImage(NetworkImage(img.url), context);
        } catch (_) {}
      }

      final screenWidth = MediaQuery.of(context).size.width;
      // ✅ ຄວາມສູງເຜື່ອ ສຳລັບ content ທັງໝົດ
      final estimatedHeight =
          MediaQuery.of(context).size.height * 3 + 500;

      debugPrint('════════════════════════════════════');
      debugPrint('💾 CAPTURE — START');
      debugPrint('   width = $screenWidth');
      debugPrint('   estimatedHeight = $estimatedHeight');
      debugPrint('════════════════════════════════════');

      // ✅ ຈັບພາບຈາກ widget ໃໝ່ (ບໍ່ມີ AppBar ບໍ່ມີ header)
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
              color: const Color(0xFFF5F0EA),
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

      debugPrint('✅ Captured: ${imageBytes.length} bytes');

      // ── ບັນທຶກ ──
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      final fileName =
          'sale_detail_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(imageBytes, name: fileName);

      debugPrint('✅ SAVED: $fileName');
      debugPrint('════════════════════════════════════');

      if (mounted) _ok('ສຳເລັດ', 'ບັນທຶກລົງຄັງຮູບແລ້ວ');
    } catch (e, st) {
      debugPrint('❌ ERROR: $e');
      debugPrint('$st');
      if (mounted) _err('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  // ══════════════════════════════════════════════
  // 👆 ປັດຊ້າຍ/ຂວາ ເພື່ອກັບ
  // ══════════════════════════════════════════════
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
    final result = await Get.to<bool>(
      () => SaleImageEditPage(sale: _liveSale),
    );
    if (result == true) {
      _ok('ສຳເລັດ', 'ແກ້ໄຂຮູບຮຽບຮ້ອຍແລ້ວ');
    }
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
            if (route != null && route.isCurrent) {
              Get.back();
            }
          });
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final sale = _liveSale;
      final ctrl = Get.find<SalesController>();
      final fmt = NumberFormat('#,###');
      final isAdmin = Get.find<AuthController>().isAdmin;

      final payTitle =
          sale.paymentType == 'cash' ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບໂອນ';

      final payUrl = _first(sale.paymentImageUrls);
      final billUrl = _first(sale.billImageUrls);
      final thirdUrl =
          _first(sale.debtPaymentImageUrls) ?? _first(sale.topUpImageUrls);
      final thirdLabel = sale.debtPaymentImageUrls.any((u) => u.isNotEmpty)
          ? 'ຮູບຈ່າຍໜີ້'
          : 'ຮູບເງິນເຕີມ';

      final allImages = <SaleImageItem>[
        ...sale.paymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, payTitle)),
        ...sale.topUpImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບເງິນເຕີມ')),
        ...sale.billImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບໃບບິນ')),
        ...sale.debtPaymentImageUrls
            .where((u) => u.isNotEmpty)
            .map((u) => SaleImageItem(u, 'ຮູບຈ່າຍໜີ້')),
      ];

      return Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F0EA),
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

  // ══════════════════════════════════════════════
  // 📄 Content — ໃຊ້ທັງສະແດງ ແລະ capture
  //    forCapture = true  →  ບໍ່ມີ summary header
  // ══════════════════════════════════════════════
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
    required List<SaleImageItem> allImages,
    required bool forCapture,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ ບໍ່ສະແດງ header ຕອນ capture
        if (!forCapture) ...[
          _buildSummaryHeader(sale, fmt),
          const SizedBox(height: 12),
        ],

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
        const SizedBox(height: 14),
        _statusBanner(ctrl, isAdmin, sale),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 🔝 AppBar
  // ══════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(bool isAdmin, SalesController ctrl) {
    return AppBar(
      title: const Text(
        'ລາຍລະອຽດການຂາຍ',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      backgroundColor: Colors.brown.shade700,
      foregroundColor: Colors.white,
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
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22),
            tooltip: 'ບັນທຶກລົງເຄື່ອງ',
            onPressed: _saveToDevice,
          ),
        if (isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'ຕັ້ງຄ່າ',
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      color: Colors.brown,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ແກ້ໄຂຮູບພາບ',
                      style: TextStyle(
                        color: Colors.brown,
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
                      color: Color(0xFFB71C1C),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ລຶບລາຍການ',
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
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

  // ══════════════════════════════════════════════
  // 🎯 Summary Header
  // ══════════════════════════════════════════════
  Widget _buildSummaryHeader(SaleOrderEntity sale, NumberFormat fmt) {
    final isDebt = sale.hasDebt;
    final isConfirmed = sale.isConfirmed;
    final isMismatch = sale.isMismatch;

    Color accent;
    IconData badgeIcon;
    String badgeText;

    if (isMismatch) {
      accent = const Color(0xFFB71C1C);
      badgeIcon = Icons.warning_amber_rounded;
      badgeText = 'ບັນຊີບໍ່ຕົງ';
    } else if (isConfirmed) {
      accent = const Color(0xFF2E7D32);
      badgeIcon = Icons.check_circle;
      badgeText = 'ເງິນເຂົ້າແລ້ວ';
    } else if (isDebt) {
      accent = Colors.orange.shade800;
      badgeIcon = Icons.schedule;
      badgeText = 'ຕິດໜີ້';
    } else {
      accent = Colors.amber.shade800;
      badgeIcon = Icons.hourglass_bottom;
      badgeText = 'ລໍຖ້າ';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade700, Colors.brown.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.25),
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
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sale.itemCount} ລາຍການ · ${sale.totalQuantity} ຊິ້ນ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ຍອດລວມ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${fmt.format(sale.totalAmount)} ກີບ',
                  style: const TextStyle(
                    color: Colors.white,
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
              Icon(Icons.calendar_today,
                  color: Colors.white.withOpacity(0.7), size: 11),
              const SizedBox(width: 5),
              Text(
                _formatFullDate(sale.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
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
      'ວັນຈັນ', 'ວັນອັງຄານ', 'ວັນພຸດ',
      'ວັນພະຫັດ', 'ວັນສຸກ', 'ວັນເສົາ', 'ວັນອາທິດ',
    ];
    return '${days[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  // ══════════════════════════════════════════════
  // 🎴 Combined Card — ✅ mainAxisSize.min
  // ══════════════════════════════════════════════
  Widget _buildCombinedCard({
    required SaleOrderEntity sale,
    required SalesController ctrl,
    required NumberFormat fmt,
    required String? payUrl,
    required String? billUrl,
    required String? thirdUrl,
    required String payLabel,
    required String thirdLabel,
    required List<SaleImageItem> allImages,
    required bool isAdmin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min, // ✅ ປ້ອງກັນ overflow
          children: [
            _sectionLabel(Icons.photo_library_outlined, 'ຮູບພາບຢືນຢັນ'),
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
                              () => SaleImageViewer(
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
                              () => SaleImageViewer(
                                images: allImages,
                                initialIndex: _firstIndexInViewer(
                                    allImages, thirdUrl),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _imageTile9x16(
                    billUrl,
                    'ຮູບໃບບິນ',
                    onTap: billUrl == null
                        ? null
                        : () => Get.to(
                              () => SaleImageViewer(
                                images: allImages,
                                initialIndex: _firstIndexInViewer(
                                    allImages, billUrl),
                              ),
                            ),
                  ),
                ),
              ],
            ),

            _dashedDivider(),

            _sectionLabel(
                Icons.inventory_2_outlined, 'ລາຍການສິນຄ້າ (${sale.itemCount})'),
            const SizedBox(height: 10),
            ..._buildItemsList(sale, fmt),

            if (sale.hasDiscount) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.discount,
                      size: 13, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ສ່ວນລົດລວມ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  Text(
                    '-${fmt.format(sale.discountTotal)} ກີບ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'ລວມທັງໝົດ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${fmt.format(sale.totalAmount)} ກີບ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            _dashedDivider(),

            _sectionLabel(Icons.payments_outlined, 'ການຊຳລະ'),
            const SizedBox(height: 10),
            ..._buildPaymentLines(sale, fmt),

            if (sale.hasDebt) ...[
              _dashedDivider(),
              _sectionLabel(
                  Icons.person_outline, 'ຂໍ້ມູນລູກຄ້າຕິດໜີ້',
                  color: Colors.orange.shade800),
              const SizedBox(height: 10),
              ..._buildCustomerLines(sale, ctrl),
            ],

            if ((sale.note ?? '').trim().isNotEmpty) ...[
              _dashedDivider(),
              _sectionLabel(Icons.sticky_note_2_outlined, 'ໝາຍເຫດ'),
              const SizedBox(height: 8),
              Text(
                sale.note!,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            ],

            if (sale.isMismatch &&
                (sale.mismatchNote ?? '').trim().isNotEmpty) ...[
              _dashedDivider(),
              _sectionLabel(
                  Icons.warning_amber_rounded, 'ເຫດຜົນບັນຊີບໍ່ຕົງ',
                  color: const Color(0xFFB71C1C)),
              const SizedBox(height: 8),
              Text(
                sale.mismatchNote!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFFB71C1C),
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
    final c = color ?? Colors.brown.shade700;
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
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imageTile9x16(
    String? url,
    String label, {
    VoidCallback? onTap,
  }) {
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 22,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 12,
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
                              Icons.image_not_supported_outlined,
                              size: 22,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ບໍ່ມີຮູບ',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  int _firstIndexInViewer(List<SaleImageItem> items, String? url) {
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade400,
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (it.woodType.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          'ຊະນິດ: ${it.woodType}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    if (dimText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          'ຂະໜາດ: $dimText',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Row(
                        children: [
                          Text(
                            '${it.quantity} ${it.unit} × ${fmt.format(it.unitPrice)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (it.hasDiscount) ...[
                            const SizedBox(width: 4),
                            Text(
                              '· ລົດ ${fmt.format(it.discountPerUnit)}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.red.shade600,
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
                '${fmt.format(it.totalAmount)}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.brown.shade700,
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
        ? 'ເງິນສົດ'
        : sale.paymentType == 'transfer'
            ? 'ເງິນໂອນ'
            : sale.paymentType == 'mixed'
                ? 'ປະສົມ'
                : 'ຕິດໜີ້';

    final payColor = sale.paymentType == 'cash'
        ? Colors.green.shade700
        : sale.paymentType == 'transfer'
            ? Colors.blue.shade700
            : sale.paymentType == 'mixed'
                ? Colors.indigo.shade700
                : Colors.orange.shade800;

    final out = <Widget>[];

    out.add(
      Row(
        children: [
          Text(
            'ວິທີ: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
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
      out.add(_moneyRow(
        'ຈ່າຍສົດ',
        '${fmt.format(sale.cashPaidAmount)} ກີບ',
        Colors.green.shade700,
      ));
    }
    if (sale.transferPaidAmount > 0) {
      out.add(const SizedBox(height: 4));
      out.add(_moneyRow(
        'ຈ່າຍໂອນ',
        '${fmt.format(sale.transferPaidAmount)} ກີບ',
        Colors.blue.shade700,
      ));
    }
    if (sale.receivedAmount > 0 && sale.paymentType == 'cash') {
      out.add(const SizedBox(height: 4));
      out.add(_moneyRow(
        'ຮັບມາ',
        '${fmt.format(sale.receivedAmount)} ກີບ',
        Colors.grey.shade800,
      ));
    }
    if (sale.changeAmount > 0) {
      out.add(const SizedBox(height: 4));
      out.add(_moneyRow(
        'ເງິນທອນ',
        '${fmt.format(sale.changeAmount)} ກີບ',
        Colors.blue.shade700,
        bold: true,
      ));
    }
    if (sale.hasDebt) {
      out.add(const SizedBox(height: 4));
      out.add(_moneyRow(
        'ຍອດຕິດໜີ້',
        '${fmt.format(sale.debtAmount)} ກີບ',
        Colors.orange.shade800,
        bold: true,
      ));
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
              color: Colors.grey.shade600,
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

  List<Widget> _buildCustomerLines(
      SaleOrderEntity sale, SalesController ctrl) {
    final out = <Widget>[];

    if ((sale.customerName ?? '').trim().isNotEmpty) {
      out.add(_infoLine(
        Icons.person,
        'ຊື່',
        _wPrefix(sale.customerName, 'ຊື່'),
        Colors.orange.shade800,
      ));
    }
    if ((sale.customerPhone ?? '').trim().isNotEmpty) {
      out.add(_infoLine(
        Icons.phone,
        'ເບີໂທ',
        sale.customerPhone!,
        Colors.orange.shade800,
      ));
    }
    if ((sale.customerAddress ?? '').trim().isNotEmpty) {
      out.add(_infoLine(
        Icons.home,
        'ທີ່ຢູ່',
        _wPrefix(sale.customerAddress, 'ບ້ານ'),
        Colors.orange.shade800,
      ));
    }
    if (sale.debtDate != null) {
      out.add(_infoLine(
        Icons.calendar_today,
        'ວັນທີຕິດໜີ້',
        ctrl.formatLaoDate(sale.debtDate!),
        Colors.orange.shade800,
      ));
    }
    if ((sale.debtNote ?? '').trim().isNotEmpty) {
      out.add(_infoLine(
        Icons.sticky_note_2,
        'ໝາຍເຫດ',
        sale.debtNote!,
        Colors.orange.shade800,
      ));
    }

    return out;
  }

  Widget _infoLine(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
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
      c = const Color(0xFFB71C1C);
      txt = 'ບັນຊີບໍ່ຕົງກັນ';
      icon = Icons.warning_amber_rounded;
    } else if (sale.isConfirmed) {
      c = const Color(0xFF2E7D32);
      txt = 'ເງິນເຂົ້າແລ້ວ';
      icon = Icons.check_circle;
    } else if (sale.hasDebt) {
      c = Colors.amber.shade800;
      txt = 'ແຕະຢືນຢັນຮັບເງິນ';
      icon = null;
    } else {
      c = Colors.amber.shade800;
      txt = 'ແຕະຈັດການ';
      icon = null;
    }

    final clickable = isAdmin && !sale.isConfirmed;

    final banner = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.withOpacity(0.5),
          width: 1.0,
        ),
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
      borderRadius: BorderRadius.circular(14),
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
      title: 'ຢືນຢັນການຮັບເງິນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long,
                size: 48, color: Colors.green.shade600),
            const SizedBox(height: 8),
            if (name.isNotEmpty && name != '-')
              Text(
                'ລູກຄ້າ: $name',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if ((sale.customerPhone ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'ເບີໂທ: ${sale.customerPhone}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            if (addr.isNotEmpty && addr != '-') ...[
              const SizedBox(height: 2),
              Text(
                'ທີ່ຢູ່: $addr',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'ຍອດຕິດໜີ້: ${NumberFormat('#,###').format(sale.debtAmount)} ກີບ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.amber.shade900,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ທ່ານໄດ້ຮັບເງິນໜີ້ທີ່ຄ້າງນີ້ແລ້ວບໍ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'ຢືນຢັນ · ຮັບເງິນແລ້ວ',
      textCancel: 'ຍັງບໍ່ຮັບ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green.shade700,
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(const Duration(milliseconds: 350));
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
      backgroundColor: Colors.white,
      radius: 20,
      barrierDismissible: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fact_check_outlined,
              color: Colors.amber.shade800,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ຈັດການສະຖານະ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ເລືອກການດຳເນີນການ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 18),
          OptionTile(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green.shade700,
            iconBg: Colors.green.shade50,
            title: 'ຢືນຢັນເງິນເຂົ້າ',
            subtitle: 'ບັນທຶກວ່າຮັບເງິນຄົບແລ້ວ',
            onTap: () async {
              _safeCloseDialog();
              await Future.delayed(const Duration(milliseconds: 300));
              await c.confirmPaymentStatus(sale.id, false);
              _ok('ສຳເລັດ', 'ຢືນຢັນເງິນເຂົ້າແລ້ວ');
            },
          ),
          const SizedBox(height: 10),
          OptionTile(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFB71C1C),
            iconBg: Colors.red.shade50,
            title: 'ບັນຊີບໍ່ຕົງກັນ',
            subtitle: 'ບັນທຶກບັນຫາ · ລໍຖ້າກວດສອບ',
            onTap: () async {
              _safeCloseDialog();
              await Future.delayed(const Duration(milliseconds: 300));
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Get.back(),
              child: Text(
                'ຍົກເລີກ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
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
      title: isEdit ? 'ແກ້ໄຂບັນຊີບໍ່ຕົງ' : 'ບັນຊີບໍ່ຕົງກັນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'ປ້ອນເຫດຜົນ...',
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
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      onPressed: () async {
                        _safeCloseDialog();
                        await Future.delayed(
                            const Duration(milliseconds: 300));
                        await c.clearMismatch(sale.id);
                        _ok('ສຳເລັດ', 'ຍົກເລີກສະຖານະແລ້ວ');
                      },
                      child: const Text('ຍົກເລີກ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                      ),
                      onPressed: () async {
                        final t = noteCtrl.text.trim();
                        if (t.isEmpty) {
                          _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                          return;
                        }
                        _safeCloseDialog();
                        await Future.delayed(
                            const Duration(milliseconds: 300));
                        await c.updateMismatchNote(sale.id, t);
                        _ok('ສຳເລັດ', 'ອັບເດດໝາຍເຫດແລ້ວ');
                      },
                      child: const Text(
                        'ບັນທຶກ',
                        style: TextStyle(color: Colors.white),
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
                    backgroundColor: const Color(0xFFB71C1C),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () async {
                    final t = noteCtrl.text.trim();
                    if (t.isEmpty) {
                      _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                      return;
                    }
                    _safeCloseDialog();
                    await Future.delayed(
                        const Duration(milliseconds: 300));
                    await c.markAsMismatch(sale.id, t);
                    _ok('ສຳເລັດ', 'ບັນທຶກບັນຊີບໍ່ຕົງແລ້ວ');
                  },
                  child: const Text(
                    'ຢືນຢັນ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      textCancel: 'ປິດ',
      textConfirm: '',
    );
  }

  void _deleteDialog(SalesController c) {
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              widget.sale.shortSummary,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${NumberFormat('#,###').format(widget.sale.totalAmount)} ກີບ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ຈະລຶບອອກຈາກ Firebase ແລະ Cloudinary ຖາວອນ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey.shade700,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(const Duration(milliseconds: 300));
        await c.deleteSale(widget.sale.id);
        _ok('ສຳເລັດ', 'ລຶບລາຍການຮຽບຮ້ອຍແລ້ວ');
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