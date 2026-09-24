import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import '../pages/sale_detail_page.dart';
import 'sale_image_viewer.dart';

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final bool isAdmin;

  const SaleCard({
    Key? key,
    required this.sale,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    final fmt = NumberFormat('#,###');

    final payLabel =
        sale.paymentType == 'cash' ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບໂອນ';
    final images = <SaleImageItem>[
      ...sale.paymentImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => SaleImageItem(u, payLabel)),
      ...sale.topUpImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => SaleImageItem(u, 'ຮູບເງິນເຕີມ')),
      ...sale.billImageUrls
          .where((u) => u.isNotEmpty)
          .map((u) => SaleImageItem(u, 'ຮູບໃບບິນ')),
    ];
    final openViewer = images.isEmpty
        ? null
        : () => Get.to(() => SaleImageViewer(images: images));

    final borderColor = sale.isMismatch
        ? const Color(0xFFB71C1C)
        : sale.hasDebt
            ? Colors.orange.shade800
            : (sale.isConfirmed ? Colors.green : Colors.amber);

    return Card(
      // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => SaleDetailPage(sale: sale)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ 2 ຮູບຊ້ອນກັນ ═══
              Column(
                children: [
                  _thumb(_first(sale.paymentImageUrls),
                      Icons.payments_outlined, openViewer),
                  const SizedBox(height: 8),
                  _thumb(_first(sale.billImageUrls),
                      Icons.receipt_long_outlined, openViewer),
                ],
              ),
              const SizedBox(width: 12),

              // ═══ ຂໍ້ມູນ + ສະຖານະ ═══
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.productName.isNotEmpty
                          ? sale.productName
                          : 'ລາຍການໄມ້',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fmt.format(sale.totalAmount)} ກີບ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'ວິທີຊຳລະ: ${sale.paymentType == 'cash' ? 'ເງິນສົດ' : sale.paymentType == 'transfer' ? 'ເງິນໂອນ' : 'ປະສົມ'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      controller.formatLaoDate(sale.date),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),

                    // ✅ ປ້າຍສະຖານະການຈ່າຍ
                    _paymentBadge(controller, fmt),

                    const SizedBox(height: 8),
                    const Text(
                      'ສະຖານະ:',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    _statusButton(controller),
                  ],
                ),
              ),

              if (isAdmin)
                _FloatingDeleteButton(
                  onDelete: () => _deleteDialog(controller),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ✅ ປ້າຍບອກສະຖານະການຈ່າຍ + ປຸ່ມປິດໜີ້
  // ══════════════════════════════════════════════
  Widget _paymentBadge(SalesController controller, NumberFormat fmt) {
    // ─── ຕິດໜີ້ ───
    if (sale.hasDebt) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _badge(
            icon: Icons.warning_amber_rounded,
            text: 'ຕິດໜີ້ ${fmt.format(sale.debtAmount)} ກີບ',
            color: Colors.orange.shade800,
            bgColor: Colors.orange.shade50,
          ),
          if ((sale.customerName ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 12, color: Colors.orange.shade800),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    sale.customerName!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if ((sale.customerPhone ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 12, color: Colors.orange.shade800),
                const SizedBox(width: 3),
                Text(sale.customerPhone!,
                    style: TextStyle(
                        fontSize: 11, color: Colors.orange.shade800)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          // ✅ ປຸ່ມ "ຮັບເງິນແລ້ວ · ປິດໜີ້"
          if (isAdmin)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side:
                      BorderSide(color: Colors.green.shade600, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: () => _confirmReceiveDebt(controller),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('ຮັບເງິນແລ້ວ · ປິດໜີ້',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      );
    }

    // ─── ຈ່າຍປະສົມ (ສົດ + ໂອນ) ───
    if (sale.isMixed) {
      return _badge(
        icon: Icons.call_split,
        text:
            'ສົດ ${fmt.format(sale.cashPaidAmount)} · ໂອນ ${fmt.format(sale.transferPaidAmount)}',
        color: Colors.indigo.shade700,
        bgColor: Colors.indigo.shade50,
      );
    }

    // ─── ຈ່າຍເຕັມ ───
    return _badge(
      icon: Icons.verified_outlined,
      text: 'ຈ່າຍເຕັມຈຳນວນແລ້ວ',
      color: Colors.green.shade700,
      bgColor: Colors.green.shade50,
    );
  }

  Widget _badge({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String? _first(List<String> urls) {
    for (final u in urls) {
      if (u.isNotEmpty) return u;
    }
    return null;
  }

  Widget _thumb(String? url, IconData fallback, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade100,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(fallback, color: Colors.grey.shade400, size: 30),
                )
              : Icon(fallback, color: Colors.grey.shade400, size: 30),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 3 ສະຖານະ: ເຫຼືອງ / ຂຽວ / ແດງ
  // ══════════════════════════════════════════════
  Widget _statusButton(SalesController controller) {
    if (sale.isMismatch) {
      return InkWell(
        onTap: isAdmin ? () => _mismatchDialog(controller, isEdit: true) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB71C1C), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFB71C1C), size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isAdmin
                      ? '⚠ ບັນຊີບໍ່ຕົງ · ແຕະເພື່ອແກ້ໄຂ'
                      : '⚠ ບັນຊີບໍ່ຕົງກັນ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Checkmark(size: 18),
            SizedBox(width: 8),
            Text(
              '✓ ເງິນເຂົ້າແລ້ວ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: isAdmin ? () => _pendingDialog(controller) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade700, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _Waiting(size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isAdmin ? 'ລໍຖ້າ · ແຕະເພື່ອຈັດການ' : 'ລໍຖ້າກວດສອບ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🆕 Dialog: ຢືນຢັນຮັບເງິນ + ປິດໜີ້
  // ══════════════════════════════════════════════
  void _confirmReceiveDebt(SalesController c) {
    Get.defaultDialog(
      title: 'ຢືນຢັນຮັບເງິນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Icon(Icons.receipt_long,
                size: 48, color: Colors.green.shade600),
            const SizedBox(height: 8),
            Text(
              'ລູກຄ້າ: ${sale.customerName ?? "-"}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if ((sale.customerPhone ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'ເບີໂທ: ${sale.customerPhone}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'ຍອດຕິດໜີ້: ${NumberFormat('#,###').format(sale.debtAmount)} ກີບ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ຢືນຢັນວ່າໄດ້ຮັບເງິນຄົບແລ້ວ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      textConfirm: 'ຮັບເງິນແລ້ວ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green.shade700,
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        Get.back();
        await c.markDebtAsPaid(sale.id);
      },
    );
  }

  void _pendingDialog(SalesController c) {
    Get.defaultDialog(
      title: 'ຈັດການສະຖານະ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('ຢືນຢັນເງິນເຂົ້າ',
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Get.back();
                await Future.delayed(const Duration(milliseconds: 200));
                await c.confirmPaymentStatus(sale.id, false);
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
                Get.back();
                await Future.delayed(const Duration(milliseconds: 250));
                while (Get.isDialogOpen ?? false) {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 120));
                }
                _mismatchDialog(c, isEdit: false);
              },
            ),
          ],
        ),
      ),
      textCancel: 'ຍົກເລີກ',
      textConfirm: '',
    );
  }

  void _mismatchDialog(SalesController c, {required bool isEdit}) {
    final noteCtrl = TextEditingController(
      text: isEdit ? (sale.mismatchNote ?? '') : '',
    );

    Get.defaultDialog(
      title: isEdit ? 'ແກ້ໄຂບັນຊີບໍ່ຕົງ' : 'ບັນຊີບໍ່ຕົງກັນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
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
                        Get.back();
                        await Future.delayed(
                            const Duration(milliseconds: 200));
                        await c.clearMismatch(sale.id);
                      },
                      child: const Text('ຍົກເລີກສະຖານະ'),
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
                          Get.snackbar('ຜິດພາດ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                          return;
                        }
                        Get.back();
                        await Future.delayed(
                            const Duration(milliseconds: 200));
                        await c.updateMismatchNote(sale.id, t);
                      },
                      child: const Text('ບັນທຶກ',
                          style: TextStyle(color: Colors.white)),
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
                      Get.snackbar('ຜິດພາດ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                      return;
                    }
                    Get.back();
                    await Future.delayed(
                        const Duration(milliseconds: 200));
                    await c.markAsMismatch(sale.id, t);
                  },
                  child: const Text('ຢືນຢັນ',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
      textCancel: 'ປິດ',
      textConfirm: '',
    );
  }

  void _deleteDialog(SalesController c) => Get.defaultDialog(
        title: 'ຢືນຢັນການລຶບ',
        middleText:
            'ລຶບລາຍການນີ້ພ້ອມຮູບພາບທັງໝົດອອກຈາກ Firebase ແລະ Cloudinary?',
        textConfirm: 'ລຶບ',
        textCancel: 'ຍົກເລີກ',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          c.deleteSale(sale.id);
          Get.back();
        },
      );
}

// ══════════════════════════════════════════════
// ⋮ → 🗑 (Admin)
// ══════════════════════════════════════════════
class _FloatingDeleteButton extends StatefulWidget {
  final VoidCallback onDelete;
  const _FloatingDeleteButton({required this.onDelete});

  @override
  State<_FloatingDeleteButton> createState() => _FloatingDeleteButtonState();
}

class _FloatingDeleteButtonState extends State<_FloatingDeleteButton>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward(from: 0) : _ctrl.reverse();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.more_vert,
                  color: Colors.black54, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: _toggle,
            ),
          ),
          Positioned(
            right: 0,
            top: 60,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => IgnorePointer(
                ignoring: !_open,
                child: Opacity(
                  opacity: _ctrl.value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - _ctrl.value)),
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * _ctrl.value,
                      child: child,
                    ),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _close();
                  widget.onDelete();
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.delete,
                      color: Color(0xFFB71C1C), size: 26),
                ),
              ),
            ),
          ),
          if (_open)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Animations
// ══════════════════════════════════════════════
class _Waiting extends StatefulWidget {
  final double size;
  const _Waiting({this.size = 18});
  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
              ),
            ),
            RotationTransition(
              turns: _c,
              child: Icon(Icons.hourglass_bottom,
                  size: widget.size * 0.55, color: Colors.amber.shade800),
            ),
          ],
        ),
      );
}

class _Checkmark extends StatelessWidget {
  final double size;
  const _Checkmark({this.size = 18});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: size * 0.7),
        ),
      );
}