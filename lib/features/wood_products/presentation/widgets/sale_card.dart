import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';

import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import '../pages/debt_payment_page.dart';
import '../pages/sale_detail_page.dart';
import 'sale_image_viewer.dart';

// ✅ Global: ມີພຽງ 1 ອັນທີ່ເປີດຢູ່
final ValueNotifier<String?> _openMenuId = ValueNotifier<String?>(null);

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final bool isAdmin;

  const SaleCard({
    Key? key,
    required this.sale,
    required this.isAdmin,
  }) : super(key: key);

  static String _wPrefix(String? raw, String prefix) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    return v.startsWith(prefix) ? v : '$prefix$v';
  }

  // ✅ ປິດ dialog ຢ່າງປອດໄພ — root navigator
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
      margin: const EdgeInsets.symmetric(vertical: 6),
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
              Column(children: [
                _thumb(_first(sale.paymentImageUrls),
                    Icons.payments_outlined, openViewer),
                const SizedBox(height: 8),
                _thumb(_first(sale.billImageUrls),
                    Icons.receipt_long_outlined, openViewer),
              ]),
              const SizedBox(width: 12),

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
                    if (sale.quantity > 0) ...[
                      const SizedBox(height: 1),
                      Row(children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 11, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Text('${sale.quantity} ຊິ້ນ',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700)),
                      ]),
                    ],
                    const SizedBox(height: 2),
                    AnimatedNumber(
                      value: sale.totalAmount,
                      suffix: ' ກີບ',
                      duration: 1200,
                      replayOnRouteChange: true,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'ວິທີ: ${sale.paymentType == 'cash' ? 'ເງິນສົດ' : sale.paymentType == 'transfer' ? 'ເງິນໂອນ' : 'ປະສົມ'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      ctrl.formatLaoDate(sale.date),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                    if (sale.discountPerUnit > 0) ...[
                      const SizedBox(height: 4),
                      _miniChip(
                        icon: Icons.discount,
                        text:
                            'ສ່ວນລົດ ${fmt.format(sale.discountPerUnit * sale.quantity)} ກີບ',
                        color: Colors.red.shade700,
                        bgColor: Colors.red.shade50,
                      ),
                    ],
                    if (sale.changeAmount > 0) ...[
                      const SizedBox(height: 4),
                      _miniChip(
                        icon: Icons.swap_horiz,
                        text: 'ເງິນທອນ ${fmt.format(sale.changeAmount)} ກີບ',
                        color: Colors.blue.shade700,
                        bgColor: Colors.blue.shade50,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _paymentBadge(fmt),
                    if ((sale.note ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _miniChip(
                        icon: Icons.sticky_note_2_outlined,
                        text: sale.note!,
                        color: Colors.brown.shade700,
                        bgColor: Colors.brown.shade50,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _statusButton(ctrl),
                  ],
                ),
              ),

              // ✅ ປຸ່ມ ⋮ → 🗑 ລຶບ (ເອົາ ✏️ ແກ້ໄຂ ອອກແລ້ວ)
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
            text: 'ຕິດໜີ້ ${fmt.format(sale.debtAmount)} ກີບ',
            color: Colors.orange.shade800,
            bgColor: Colors.orange.shade50,
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 3),
            _infoRow(Icons.person_outline, name),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            _infoRow(Icons.phone_outlined, phone),
          ],
          if (addr.isNotEmpty) ...[
            const SizedBox(height: 2),
            _infoRow(Icons.home_outlined, addr),
          ],
          if ((sale.debtNote ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            _infoRow(Icons.sticky_note_2_outlined, sale.debtNote!),
          ],
        ],
      );
    }

    if (sale.isMixed) {
      return _badge(
        icon: Icons.call_split,
        text:
            'ສົດ ${fmt.format(sale.cashPaidAmount)} · ໂອນ ${fmt.format(sale.transferPaidAmount)}',
        color: Colors.indigo.shade700,
        bgColor: Colors.indigo.shade50,
      );
    }

    return _badge(
      icon: Icons.verified_outlined,
      text: 'ຈ່າຍແລ້ວ',
      color: Colors.green.shade700,
      bgColor: Colors.green.shade50,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.orange.shade800),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
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
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _miniChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 76,
          height: 76,
          color: Colors.grey.shade100,
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: 168,
                  placeholder: (c, u) =>
                      Container(color: Colors.grey.shade100),
                  errorWidget: (_, __, ___) =>
                      Icon(fallback, color: Colors.grey.shade400, size: 32),
                )
              : Icon(fallback, color: Colors.grey.shade400, size: 32),
        ),
      ),
    );
  }

  Widget _statusButton(SalesController c) {
    if (sale.isMismatch) {
      return InkWell(
        onTap: isAdmin ? () => _mismatchDialog(c, isEdit: true) : null,
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
                  color: Color(0xFFB71C1C), size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isAdmin ? 'ບັນຊີບໍ່ຕົງ · ແຕະແກ້ໄຂ' : 'ບັນຊີບໍ່ຕົງ',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C)),
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
            _Checkmark(size: 16),
            SizedBox(width: 6),
            Text('ເງິນເຂົ້າແລ້ວ',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
          ],
        ),
      );
    }

    if (sale.hasDebt) {
      return InkWell(
        onTap: isAdmin ? () => _confirmReceiveDebt(c) : null,
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
              const _Waiting(size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isAdmin ? 'ກວດສອບ · ແຕະຢືນຢັນຮັບເງິນ' : 'ກວດສອບ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900),
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
            const _Waiting(size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                isAdmin ? 'ກວດສອບ · ແຕະຈັດການ' : 'ກວດສອບ',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900),
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
      title: 'ຢືນຢັນການຮັບເງິນ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Icon(Icons.receipt_long,
                size: 48, color: Colors.green.shade600),
            const SizedBox(height: 8),
            if (name.isNotEmpty)
              Text('ລູກຄ້າ: $name',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            if ((sale.customerPhone ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('ເບີໂທ: ${sale.customerPhone}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700)),
            ],
            if (addr.isNotEmpty) ...[
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
              child: Row(
                children: [
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
        Get.to(() => DebtPaymentPage(sale: sale));
      },
    );
  }

  void _pendingDialog(SalesController c) {
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
              _mismatchDialog(c, isEdit: false);
            },
          ),
        ]),
      ),
      textCancel: 'ຍົກເລີກ',
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
                    await Future.delayed(const Duration(milliseconds: 300));
                    await c.clearMismatch(sale.id);
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
                      Get.snackbar('ຜິດພາດ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                      return;
                    }
                    _safeCloseDialog();
                    await Future.delayed(const Duration(milliseconds: 300));
                    await c.updateMismatchNote(sale.id, t);
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
                    Get.snackbar('ຜິດພາດ', 'ກະລຸນາປ້ອນເຫດຜົນ');
                    return;
                  }
                  _safeCloseDialog();
                  await Future.delayed(const Duration(milliseconds: 300));
                  await c.markAsMismatch(sale.id, t);
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
    if (Get.isDialogOpen ?? false) return;

    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [
          Icon(Icons.warning_amber_rounded,
              size: 48, color: Colors.red.shade600),
          const SizedBox(height: 8),
          Text(
            sale.productName.isNotEmpty
                ? sale.productName
                : 'ລາຍການໄມ້',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '${NumberFormat('#,###').format(sale.totalAmount)} ກີບ',
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
          const SizedBox(height: 10),
          const Text('ຢືນຢັນການລຶບ?',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
      ),
      barrierDismissible: true,
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey.shade700,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        _safeCloseDialog();
        await Future.delayed(const Duration(milliseconds: 300));
        await c.deleteSale(sale.id);
      },
    );
  }
}

// ══════════════════════════════════════════════
// ⋮ → 🗑 (ເອົາ ✏️ ອອກແລ້ວ)
// ══════════════════════════════════════════════
class _FloatingActionsButton extends StatefulWidget {
  final String saleId;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _FloatingActionsButton({
    Key? key,
    required this.saleId,
    required this.isAdmin,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_FloatingActionsButton> createState() =>
      _FloatingActionsButtonState();
}

class _FloatingActionsButtonState extends State<_FloatingActionsButton>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
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
    // ✅ ເຫຼືອພຽງ 🗑 ລຶບ (admin ເທົ່ານັ້ນ)
    if (!widget.isAdmin) return const SizedBox.shrink();

    final actions = <_ActionItem>[
      _ActionItem(
        icon: Icons.delete,
        color: const Color(0xFFB71C1C),
        shadow: Colors.red.shade200,
        onTap: () {
          _close();
          Future.delayed(const Duration(milliseconds: 200), () {
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
                color: _open ? Colors.brown : Colors.black54,
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: actions[i].shadow.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(actions[i].icon,
                        color: actions[i].color, size: 24),
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
        color: Colors.amber.shade800,
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