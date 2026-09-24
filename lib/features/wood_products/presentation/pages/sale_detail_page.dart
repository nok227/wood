import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import '../widgets/sale_image_viewer.dart';
import '../../../auth/auth_controller.dart';
// ⬆️ ປັບ path ຕາມໂຄງສ້າງຕົວຈິງຂອງເຈົ້າ

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

  SaleEntity get sale => widget.sale;

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    final fmt = NumberFormat('#,###');

    final String payTitle =
        sale.paymentType == 'cash' ? 'ຮູບເງິນສົດ' : 'ຮູບເງິນໂອນ';
    final String? payUrl = _first(sale.paymentImageUrls);   // ✅ ແກ້ເປັນ String?
    final String? billUrl = _first(sale.billImageUrls);     // ✅

    final List<SaleImageItem> allImages = [
      ...sale.paymentImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => SaleImageItem(u, payTitle)),
      ...sale.billImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => SaleImageItem(u, 'ຮູບໃບບິນ')),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ລາຍລະອຽດການຂາຍ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          // ✅ ປຸ່ມບັນທຶກ ມຸມຂວາເທິງ (Admin ເທົ່ານັ້ນ)
          Obx(() {
            final auth = Get.find<AuthController>();
            if (!auth.isAdmin) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: _saving ? null : () => _onSave(controller),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white, size: 20),
              label: Text(
                _saving ? 'ກຳລັງບັນທຶກ...' : 'ບັນທຶກ',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ═══ ຮູບ 2 ອັນ ═══
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
          const SizedBox(height: 20),

          // ═══ ຂໍ້ມູນການຂາຍ ═══
          _cardSection(
            title: 'ຂໍ້ມູນການຂາຍ',
            icon: Icons.inventory_2_outlined,
            children: [
              _row('ສິນຄ້າ',
                  sale.productName.isNotEmpty ? sale.productName : 'ລາຍການໄມ້'),
              _row('ຈຳນວນ', '${sale.quantity} ຊິ້ນ'),
              if (sale.discountPerUnit > 0)
                _row('ສ່ວນຫຼຸດ/ຫົວໜ່ວຍ',
                    '${fmt.format(sale.discountPerUnit)} ກີບ'),
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
          _cardSection(
            title: 'ການຊຳລະ',
            icon: Icons.payments_outlined,
            children: [
              _row('ວິທີ', sale.paymentType == 'cash' ? 'ເງິນສົດ' : 'ເງິນໂອນ'),
              if (sale.paymentType == 'cash') ...[
                _row('ຮັບມາ', '${fmt.format(sale.receivedAmount)} ກີບ'),
                _row('ທອນ', '${fmt.format(sale.changeAmount)} ກີບ',
                    color: Colors.green.shade800),
              ],
              _row('ວັນທີ', controller.formatLaoDate(sale.date)),
            ],
          ),

          // ═══ ໝາຍເຫດ ═══
          if (sale.note?.isNotEmpty ?? false) ...[
            const SizedBox(height: 14),
            _cardSection(
              title: 'ໝາຍເຫດ',
              icon: Icons.sticky_note_2_outlined,
              children: [
                Text(
                  sale.note!,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ],

          // ═══ ເຫດຜົນບັນຊີບໍ່ຕົງ ═══
          if (sale.isMismatch &&
              (sale.mismatchNote?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 14),
            _cardSection(
              title: 'ເຫດຜົນບັນຊີບໍ່ຕົງ',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFB71C1C),
              bgColor: Colors.red.shade50,
              borderColor: const Color(0xFFB71C1C),
              children: [
                Text(
                  sale.mismatchNote!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // ═══ ສະຖານະ (ຢູ່ລຸ່ມສຸດ) ═══
          _statusBanner(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  ກ່ອງຮູບ + title
  // ══════════════════════════════════════════════
  Widget _imageBlock({
    required String title,
    required String? url,
    required IconData fallback,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
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
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(fallback,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text(
                            'ບໍ່ມີຮູບ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  Card section
  // ══════════════════════════════════════════════
  Widget _cardSection({
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
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? Colors.brown),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: iconColor ?? Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  ແຖວ label : value
  // ══════════════════════════════════════════════
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
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: big ? 15 : 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Banner ສະຖານະ (ພ້ອມ animation ໝຸນ)
  // ══════════════════════════════════════════════
  Widget _statusBanner() {
    final Color c;
    final String txt;

    if (sale.isMismatch) {
      c = const Color(0xFFB71C1C);
      txt = 'ບັນຊີບໍ່ຕົງກັນ';
    } else if (sale.isConfirmed) {
      c = const Color(0xFF2E7D32);
      txt = 'ເງິນເຂົ້າແລ້ວ';
    } else {
      c = Colors.amber.shade800;
      txt = 'ລໍຖ້າກວດສອບ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _statusIcon(c),
          const SizedBox(width: 10),
          Text(
            txt,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  // ── ໄອຄອນສະຖານະ: ລໍຖ້າ = ໝຸນ, ອື່ນ = ຄົງທີ່ ──
  Widget _statusIcon(Color c) {
    // ⏳ ລໍຖ້າ — ໝຸນ
    if (!sale.isConfirmed && !sale.isMismatch) {
      return SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _spinCtrl,
              child: Icon(
                Icons.hourglass_bottom,
                color: c,
                size: 22,
              ),
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

    // ⚠ ບັນຊີບໍ່ຕົງ
    if (sale.isMismatch) {
      return Icon(Icons.warning_amber_rounded, color: c, size: 28);
    }

    // ✓ ຢືນຢັນແລ້ວ — ສະແດງ check ມີ pop animation
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Icon(Icons.check_circle, color: c, size: 28),
    );
  }

  // ══════════════════════════════════════════════
  //  ກົດບັນທຶກ
  // ══════════════════════════════════════════════
  Future<void> _onSave(SalesController controller) async {
    setState(() => _saving = true);
    try {
      await controller.fetchSales();
      Get.snackbar(
        'ສຳເລັດ',
        'ຂໍ້ມູນອັບເດດແລ້ວ',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກໄດ້: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── ດຶງ URL ທຳອິດ ──
  String? _first(List<String> urls) {
    for (final u in urls) {
      if (u.isNotEmpty) return u;
    }
    return null;
  }
}