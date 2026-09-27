import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import '../controllers/wood_product_controller.dart';
import '../../data/models/wood_product_model.dart';
import '../widgets/sale_image_viewer.dart';
import 'debt_payment_page.dart';
import 'sale_image_edit_page.dart';
import '../../../auth/auth_controller.dart';

enum _Alert { success, error, warning, info }

class SaleDetailPage extends StatefulWidget {
  final SaleEntity sale;
  const SaleDetailPage({super.key, required this.sale});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  bool _saving = false;

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

  SaleEntity get _liveSale {
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

  // ✅ ດຶງ product ຈາກ productId ເພື່ອສະແດງຂະໜາດ
  WoodProductModel? _findProduct(String productId) {
    try {
      final products = Get.find<WoodProductController>().products;
      for (final p in products) {
        if (p.id == productId) return p;
      }
    } catch (_) {}
    return null;
  }

  // ✅ ຈັດຮູບແບບຕົວເລກ — ຕັດ .0 ອອກ
  String _fmtDim(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  // ✅ ສ້າງ string ຂະໜາດ
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
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
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

      // ✅ ດຶງ product ເພື່ອສະແດງຂະໜາດ
      final product = _findProduct(sale.productId);
      final dimText = _dimensionText(product);

      final payTitle =
          sale.paymentType == 'cash' ? 'ຮູບເງິນສົດ' : 'ຮູບເງິນໂອນ';
      final String? payUrl = _first(sale.paymentImageUrls);
      final String? topUpUrl = _first(sale.topUpImageUrls);
      final String? billUrl = _first(sale.billImageUrls);

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
      ];

      final hasTopUp = sale.topUpImageUrls.any((u) => u.isNotEmpty);

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('ລາຍລະອຽດການຂາຍ'),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          actions: [
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.photo_library_outlined,
                    color: Colors.white),
                tooltip: 'ແກ້ໄຂຮູບ',
                onPressed: () => _openImageEditor(ctrl),
              ),
            if (isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _deleteDialog(ctrl);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('ລຶບ',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ═══ ຮູບ ═══
            if (hasTopUp)
              Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _imageBlock(
                        title: payTitle,
                        url: payUrl,
                        fallback: Icons.payments_outlined,
                        onTap: payUrl == null
                            ? null
                            : () => Get.to(() => SaleImageViewer(
                                  images: allImages,
                                  initialIndex: 0,
                                )),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _imageBlock(
                        title: 'ຮູບເງິນເຕີມ',
                        url: topUpUrl,
                        fallback: Icons.add_card,
                        onTap: topUpUrl == null
                            ? null
                            : () => Get.to(() => SaleImageViewer(
                                  images: allImages,
                                  initialIndex: sale.paymentImageUrls
                                      .where((u) => u.isNotEmpty)
                                      .length,
                                )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _imageBlock(
                  title: 'ຮູບໃບບິນ',
                  url: billUrl,
                  fallback: Icons.receipt_long_outlined,
                  onTap: billUrl == null
                      ? null
                      : () => Get.to(() => SaleImageViewer(
                            images: allImages,
                            initialIndex: sale.paymentImageUrls
                                    .where((u) => u.isNotEmpty)
                                    .length +
                                sale.topUpImageUrls
                                    .where((u) => u.isNotEmpty)
                                    .length,
                          )),
                ),
              ])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _imageBlock(
                      title: payTitle,
                      url: payUrl,
                      fallback: Icons.payments_outlined,
                      onTap: payUrl == null
                          ? null
                          : () => Get.to(() => SaleImageViewer(
                                images: allImages,
                                initialIndex: 0,
                              )),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _imageBlock(
                      title: 'ຮູບໃບບິນ',
                      url: billUrl,
                      fallback: Icons.receipt_long_outlined,
                      onTap: billUrl == null
                          ? null
                          : () => Get.to(() => SaleImageViewer(
                                images: allImages,
                                initialIndex: sale.paymentImageUrls
                                    .where((u) => u.isNotEmpty)
                                    .length,
                              )),
                    ),
                  ),
                ],
              ),

            if (isAdmin) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _openImageEditor(ctrl),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('ແກ້ໄຂຮູບພາບ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  side: const BorderSide(color: Colors.brown),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ═══ ຂໍ້ມູນການຂາຍ ═══
            _section(
              title: 'ຂໍ້ມູນການຂາຍ',
              icon: Icons.inventory_2_outlined,
              children: [
                _row('ສິນຄ້າ',
                    sale.productName.isNotEmpty
                        ? sale.productName
                        : 'ລາຍການໄມ້'),

                // ✅ ສະແດງຂະໜາດ
                if (dimText != null)
                  _row('ຂະໜາດ', dimText),

                // ✅ ສະແດງຊະນິດໄມ້
                if (product != null && product.woodType.trim().isNotEmpty)
                  _row('ຊະນິດໄມ້', product.woodType),

                if (sale.quantity > 0)
                  _row('ຈຳນວນ',
                      '${sale.quantity} ${product?.unit ?? "ຊິ້ນ"}'),

                if (sale.discountPerUnit > 0) ...[
                  _row('ສ່ວນລົດ/ຫົວໜ່ວຍ',
                      '${fmt.format(sale.discountPerUnit)} ກີບ'),
                  _row('ລວມສ່ວນລົດ',
                      '${fmt.format(sale.discountPerUnit * sale.quantity)} ກີບ',
                      color: Colors.red.shade700),
                ],
                const Divider(height: 16),
                _row(
                  'ລວມທັງໝົດ',
                  '${fmt.format(sale.totalAmount)} ກີບ',
                  bold: true,
                  color: Colors.brown,
                  big: true,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ═══ ການຊຳລະ ═══
            _section(
              title: 'ການຊຳລະ',
              icon: Icons.payments_outlined,
              children: [
                _row(
                  'ວິທີ',
                  sale.paymentType == 'cash'
                      ? 'ເງິນສົດ'
                      : sale.paymentType == 'transfer'
                          ? 'ເງິນໂອນ'
                          : 'ປະສົມ',
                ),
                if (sale.cashPaidAmount > 0)
                  _row('ຈ່າຍສົດ',
                      '${fmt.format(sale.cashPaidAmount)} ກີບ',
                      color: Colors.green.shade700),
                if (sale.transferPaidAmount > 0)
                  _row('ຈ່າຍໂອນ',
                      '${fmt.format(sale.transferPaidAmount)} ກີບ',
                      color: Colors.blue.shade700),
                if (sale.receivedAmount > 0 &&
                    sale.paymentType == 'cash')
                  _row('ຮັບມາ',
                      '${fmt.format(sale.receivedAmount)} ກີບ'),
                if (sale.changeAmount > 0)
                  _row('ເງິນທອນ',
                      '${fmt.format(sale.changeAmount)} ກີບ',
                      color: Colors.blue.shade700,
                      bold: true),
                if (sale.hasDebt)
                  _row('ຍອດຕິດໜີ້',
                      '${fmt.format(sale.debtAmount)} ກີບ',
                      color: Colors.orange.shade800,
                      bold: true),
                _row('ວັນທີ', ctrl.formatLaoDate(sale.date)),
              ],
            ),

            // ═══ ຂໍ້ມູນລູກຄ້າຕິດໜີ້ ═══
            if (sale.hasDebt) ...[
              const SizedBox(height: 14),
              _section(
                title: 'ຂໍ້ມູນລູກຄ້າຕິດໜີ້',
                icon: Icons.person_outline,
                iconColor: Colors.orange.shade800,
                bgColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade300,
                children: [
                  if ((sale.customerName ?? '').trim().isNotEmpty)
                    _row('ຊື່', _wPrefix(sale.customerName, 'ຊື່')),
                  if ((sale.customerPhone ?? '').trim().isNotEmpty)
                    _row('ເບີໂທ', sale.customerPhone!),
                  if ((sale.customerAddress ?? '').trim().isNotEmpty)
                    _row('ທີ່ຢູ່',
                        _wPrefix(sale.customerAddress, 'ບ້ານ')),
                  if (sale.debtDate != null)
                    _row('ວັນທີຕິດໜີ້',
                        ctrl.formatLaoDate(sale.debtDate!)),
                  if ((sale.debtNote ?? '').trim().isNotEmpty)
                    _row('ໝາຍເຫດການຕິດໜີ້', sale.debtNote!),
                ],
              ),
            ],

            // ═══ ໝາຍເຫດ ═══
            if ((sale.note ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _section(
                title: 'ໝາຍເຫດ',
                icon: Icons.sticky_note_2_outlined,
                children: [
                  Text(sale.note!,
                      style:
                          const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ],

            // ═══ ເຫດຜົນບັນຊີບໍ່ຕົງ ═══
            if (sale.isMismatch &&
                (sale.mismatchNote ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _section(
                title: 'ເຫດຜົນບັນຊີບໍ່ຕົງ',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFB71C1C),
                bgColor: Colors.red.shade50,
                borderColor: const Color(0xFFB71C1C),
                children: [
                  Text(sale.mismatchNote!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      )),
                ],
              ),
            ],

            const SizedBox(height: 24),
            _statusBanner(ctrl, isAdmin, sale),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }

  Widget _imageBlock({
    required String title,
    required String? url,
    required IconData fallback,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, p) {
                          if (p == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(fallback,
                              size: 40, color: Colors.grey.shade400),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.zoom_in,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ])
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(fallback,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text('ບໍ່ມີຮູບ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade200,
          width: borderColor != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: iconColor ?? Colors.brown),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? Colors.brown)),
          ]),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool big = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontSize: big ? 15 : 13,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.w600,
                  color: color ?? Colors.black87,
                )),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(
      SalesController ctrl, bool isAdmin, SaleEntity sale) {
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
      txt = 'ກວດສອບ · ແຕະຢືນຢັນຮັບເງິນ';
      icon = null;
    } else {
      c = Colors.amber.shade800;
      txt = 'ກວດສອບ · ແຕະຈັດການ';
      icon = null;
    }

    final clickable = isAdmin && !sale.isConfirmed;

    final banner = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon, color: c, size: 26) : _spinIcon(c),
          const SizedBox(width: 10),
          Flexible(
            child: Text(txt,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: c),
                overflow: TextOverflow.ellipsis),
          ),
          if (clickable) ...[
            const SizedBox(width: 8),
            Icon(Icons.touch_app, color: c, size: 18),
          ],
        ],
      ),
    );

    if (!clickable) return banner;

    return InkWell(
      onTap: () => _onStatusTap(ctrl, sale),
      borderRadius: BorderRadius.circular(12),
      child: banner,
    );
  }

  Widget _spinIcon(Color c) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _spinCtrl,
            child: Icon(Icons.hourglass_bottom, color: c, size: 22),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          ),
        ],
      ),
    );
  }

  void _onStatusTap(SalesController ctrl, SaleEntity sale) {
    if (sale.isMismatch) {
      _mismatchDialog(ctrl, isEdit: true, sale: sale);
    } else if (sale.hasDebt) {
      _confirmReceiveDebt(ctrl, sale);
    } else {
      _pendingDialog(ctrl, sale);
    }
  }

  void _confirmReceiveDebt(SalesController c, SaleEntity sale) {
    final name = _wPrefix(sale.customerName, 'ຊື່');
    final addr = _wPrefix(sale.customerAddress, 'ບ້ານ');

    Get.defaultDialog(
      title: 'ຢືນຢັນການຮັບເງິນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [
          Icon(Icons.receipt_long,
              size: 48, color: Colors.green.shade600),
          const SizedBox(height: 8),
          if (name.isNotEmpty && name != '-')
            Text('ລູກຄ້າ: $name',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          if ((sale.customerPhone ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('ເບີໂທ: ${sale.customerPhone}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade700)),
          ],
          if (addr.isNotEmpty && addr != '-') ...[
            const SizedBox(height: 2),
            Text('ທີ່ຢູ່: $addr',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade700)),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(children: [
              Icon(Icons.help_outline,
                  color: Colors.amber.shade900, size: 20),
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
            ]),
          ),
        ]),
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

  void _pendingDialog(SalesController c, SaleEntity sale) {
    Get.defaultDialog(
      title: 'ຈັດການສະຖານະ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(44),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('ຢືນຢັນເງິນເຂົ້າ',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              _safeCloseDialog();
              await Future.delayed(const Duration(milliseconds: 300));
              await c.confirmPaymentStatus(sale.id, false);
              _ok('ສຳເລັດ', 'ຢືນຢັນເງິນເຂົ້າແລ້ວ');
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              minimumSize: const Size.fromHeight(44),
            ),
            icon: const Icon(Icons.warning_amber_rounded,
                color: Colors.white),
            label: const Text('ບັນຊີບໍ່ຕົງກັນ',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
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
        ]),
      ),
      textCancel: 'ຍົກເລີກ',
      textConfirm: '',
    );
  }

  void _mismatchDialog(
    SalesController c, {
    required bool isEdit,
    required SaleEntity sale,
  }) {
    final noteCtrl = TextEditingController(
      text: isEdit ? (sale.mismatchNote ?? '') : '',
    );

    Get.defaultDialog(
      title: isEdit ? 'ແກ້ໄຂບັນຊີບໍ່ຕົງ' : 'ບັນຊີບໍ່ຕົງກັນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [
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
            Row(children: [
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
                  child: const Text('ບັນທຶກ',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ])
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
                child: const Text('ຢືນຢັນ',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
        ]),
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
        child: Column(children: [
          Icon(Icons.warning_amber_rounded,
              size: 48, color: Colors.red.shade600),
          const SizedBox(height: 8),
          Text(
            widget.sale.productName.isNotEmpty
                ? widget.sale.productName
                : 'ລາຍການໄມ້',
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
                color: Colors.brown),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline,
                  color: Colors.red.shade700, size: 18),
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
            ]),
          ),
        ]),
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

  Future<void> _onSave(SalesController ctrl) async {
    setState(() => _saving = true);
    try {
      await ctrl.fetchSales();
      _ok('ສຳເລັດ', 'ຂໍ້ມູນອັບເດດແລ້ວ');
    } catch (e) {
      _err('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _first(List<String> urls) {
    for (final u in urls) {
      if (u.isNotEmpty) return u;
    }
    return null;
  }
}