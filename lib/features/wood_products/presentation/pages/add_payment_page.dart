import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import 'package:wood/features/wood_products/data/models/wood_product_model.dart';
import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';
import '../controllers/sales_controller.dart';
import '../../domain/entities/sale_entity.dart';

// ══════════════════════════════════════════════
// 🧩 Helpers
// ══════════════════════════════════════════════
class _NumFmt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(',', '');
    if (d.isEmpty) return const TextEditingValue(text: '');
    if (!RegExp(r'^\d+$').hasMatch(d)) return o;
    final x = int.tryParse(d);
    if (x == null) return o;
    final f = NumberFormat('#,###').format(x);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

enum _A { success, error, warning }

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({Key? key}) : super(key: key);
  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final c = Get.find<SalesController>();
  final pc = Get.find<WoodProductController>();
  final fmt = NumberFormat('#,###');
  final picker = ImagePicker();

  // controllers
  final noteC = TextEditingController();
  final qtyC = TextEditingController(text: '1');
  final discC = TextEditingController(text: '0');
  final paidC = TextEditingController();
  final nameC = TextEditingController();
  final addrC = TextEditingController();
  final phoneC = TextEditingController();
  final debtNoteC = TextEditingController();
  final debtPaidC = TextEditingController();

  // state
  String? _wood, _type;
  int _qty = 1;
  double _disc = 0, _paid = 0, _debtPaid = 0;
  String? _choice;
  String _debtType = 'none';
  File? _payImg, _billImg, _topUpSlip, _topUpCash, _debtImg;
  DateTime? _apptDate;
  TimeOfDay? _apptTime;
  final Map<int, int> _bills = {};

  static const _r1 = [500, 1000, 2000, 5000];
  static const _r2 = [10000, 20000, 50000, 100000];

  // calc
  double get _unit => c.selectedProduct.value?.price ?? 0;
  double get _gross => _unit * _qty;
  double get _discTot => _disc * _qty;
  double get _net => (_gross - _discTot).clamp(0, double.infinity);
  double get _short => (_net - _paid).clamp(0, double.infinity);
  double get _change => (_paid - _net).clamp(0, double.infinity);
  double get _debtReal => (_net - _debtPaid).clamp(0, double.infinity);
  double get _billsTot => _bills.entries.fold(0, (s, e) => s + e.key * e.value);

  bool get _isCash => c.paymentType.value == 'cash';
  bool get _isDebt => c.paymentType.value == 'debt';
  bool get _noPay => _paid <= 0;
  bool get _hasShort => _short > 0;
  bool get _hasChange => _change > 0;
  bool get _missDebt =>
      nameC.text.trim().isEmpty ||
      phoneC.text.trim().isEmpty ||
      addrC.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    c.resetForm();
  }

  @override
  void dispose() {
    for (final x in [
      noteC,
      qtyC,
      discC,
      paidC,
      nameC,
      addrC,
      phoneC,
      debtNoteC,
      debtPaidC,
    ]) {
      x.dispose();
    }
    super.dispose();
  }

  // ══════════════════════════════════════════════
  // 🎨 Alert
  // ══════════════════════════════════════════════
  void _snack(String t, String m, _A type) {
    Get.closeAllSnackbars();
    final bg = type == _A.success
        ? Colors.green.shade700
        : type == _A.error
        ? Colors.red.shade700
        : Colors.orange.shade800;
    final ic = type == _A.success
        ? Icons.check_circle
        : type == _A.error
        ? Icons.error_outline
        : Icons.warning_amber_rounded;
    Get.snackbar(
      t,
      m,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(ic, color: Colors.white, size: 26),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: type == _A.error ? 3 : 2),
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

  void _ok(String t, String m) => _snack(t, m, _A.success);
  void _err(String t, String m) => _snack(t, m, _A.error);
  void _warn(String t, String m) => _snack(t, m, _A.warning);

  // ══════════════════════════════════════════════
  // ລ້າງຟອມ
  // ══════════════════════════════════════════════
  void _clear() {
    setState(() {
      _wood = _type = _choice = null;
      _payImg = _billImg = _topUpSlip = _topUpCash = _debtImg = null;
      _qty = 1;
      _disc = _paid = _debtPaid = 0;
      _debtType = 'none';
      _apptDate = null;
      _apptTime = null;
      _bills.clear();
      c.paymentType.value = 'cash';
      for (final x in [
        noteC,
        qtyC,
        discC,
        paidC,
        nameC,
        addrC,
        phoneC,
        debtNoteC,
        debtPaidC,
      ]) {
        x.clear();
      }
      qtyC.text = '1';
      discC.text = '0';
    });
    c.resetForm();
    _ok('ສຳເລັດ', 'ລ້າງຟອມຮຽບຮ້ອຍແລ້ວ');
  }

  // ══════════════════════════════════════════════
  // ຮູບ
  // ══════════════════════════════════════════════
  Future<void> _pick({String which = 'pay'}) async {
    Future<void> h(ImageSource s) async {
      Get.back();
      final p = await picker.pickImage(
        source: s,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (p == null) return;
      setState(() {
        final f = File(p.path);
        switch (which) {
          case 'bill':
            _billImg = f;
            break;
          case 'topSlip':
            _topUpSlip = f;
            break;
          case 'topCash':
            _topUpCash = f;
            break;
          case 'debt':
            _debtImg = f;
            break;
          default:
            _payImg = f;
        }
      });
    }

    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.brown),
              title: const Text('ຖ່າຍຮູບ'),
              onTap: () => h(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.brown),
              title: const Text('ຄັງຮູບ'),
              onTap: () => h(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ນັດວັນ
  // ══════════════════════════════════════════════
  Future<void> _pickAppt() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _apptDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'ເລືອກວັນນັດ',
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: _apptTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'ເລືອກເວລາ',
    );
    setState(() {
      _apptDate = d;
      _apptTime = t ?? const TimeOfDay(hour: 9, minute: 0);
    });
  }

  String get _apptTxt {
    if (_apptDate == null) return 'ເລືອກວັນ/ເວລານັດ';
    final d = _apptDate!;
    final t = _apptTime!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _addBill(int d) {
    if (d > _paid - _billsTot) {
      _warn('ເກີນຍອດ', 'ເຫຼືອ ${fmt.format(_paid - _billsTot)} ກີບ');
      return;
    }
    setState(() => _bills[d] = (_bills[d] ?? 0) + 1);
  }

  void _delBill(int d) {
    final n = _bills[d] ?? 0;
    if (n <= 0) return;
    setState(() => n == 1 ? _bills.remove(d) : _bills[d] = n - 1);
  }

  // ══════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ບັນທຶກການຂາຍ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════
              // ① ເລືອກສິນຄ້າ
              // ═══════════════════════════════════════
              _section(
                number: '1',
                title: 'ເລືອກສິນຄ້າໄມ້',
                icon: Icons.inventory_2_outlined,
                color: Colors.brown,
                child: _woodPicker(),
              ),
              const SizedBox(height: 16),

              // ── ສ່ວນທີ່ຕ້ອງມີໄມ້ກ່ອນ ──
              Obx(() {
                final hasProduct = c.selectedProduct.value != null;
                if (!hasProduct) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ═══════════════════════════════════════
                    // ② ຈຳນວນ + ສ່ວນລົດ
                    // ═══════════════════════════════════════
                    _section(
                      number: '2',
                      title: 'ຈຳນວນ ແລະ ສ່ວນລົດ',
                      icon: Icons.straighten,
                      color: Colors.brown,
                      child: Column(
                        children: [
                          _qtyRow(),
                          if (_disc > 0) ...[
                            const SizedBox(height: 12),
                            _discView(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // ③ ປະເພດການຊຳລະ
                    // ═══════════════════════════════════════
                    _section(
                      number: '3',
                      title: 'ປະເພດການຊຳລະ',
                      icon: Icons.payments_outlined,
                      color: Colors.brown,
                      child: _payTypeRow(),
                    ),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // ④ ຮູບພາບ (ສົດ/ໂອນ)
                    // ═══════════════════════════════════════
                    Obx(() {
                      if (_isDebt) return const SizedBox.shrink();
                      return Column(
                        children: [
                          _section(
                            number: '4',
                            title: 'ຮູບພາບຢືນຢັນ',
                            icon: Icons.photo_library_outlined,
                            color: Colors.brown,
                            child: _imgPickers(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // ═══════════════════════════════════════
                    // ⑤ ການຈ່າຍເງິນ
                    // ═══════════════════════════════════════
                    Obx(() {
                      if (_isDebt) {
                        return _section(
                          number: '4',
                          title: 'ຂໍ້ມູນການຕິດໜີ້',
                          icon: Icons.receipt_long_outlined,
                          color: Colors.orange.shade800,
                          child: _debtForm(),
                        );
                      }
                      return _section(
                        number: '5',
                        title: 'ການຈ່າຍເງິນ',
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.brown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _paidInput(),
                            _billsPanel(),
                            _changeBanner(),
                            _shortPanel(),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // ⑥ ໝາຍເຫດ
                    // ═══════════════════════════════════════
                    _section(
                      number: _isDebt ? '5' : '6',
                      title: 'ໝາຍເຫດ',
                      icon: Icons.sticky_note_2_outlined,
                      color: Colors.brown,
                      child: TextField(
                        controller: noteC,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'ໝາຍເຫດເພີ່ມເຕີມ (ຖ້າມີ)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // ⑦ ສະຫຼຸບ
                    // ═══════════════════════════════════════
                    _summary(),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // ⑧ ປຸ່ມ
                    // ═══════════════════════════════════════
                    _buttons(),
                  ],
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🎴 Section wrapper — ກາດມີຫົວຂໍ້ + ເລກ
  // ══════════════════════════════════════════════
  Widget _section({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                // ເລກ
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Wood picker (3 ຂັ້ນ)
  // ══════════════════════════════════════════════
  Widget _woodPicker() {
    return Obx(() {
      if (pc.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator(color: Colors.brown)),
        );
      }
      final names = pc.uniqueProductNames;
      if (names.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: Colors.grey.shade500, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ຍັງບໍ່ມີລາຍການໄມ້ໃນຄັງ',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final List<String> types = _wood == null
          ? <String>[]
          : pc
              .variantsForName(_wood!)
              .map(
                (p) => p.woodType.trim().isEmpty ? 'ບໍ່ລະບຸ' : p.woodType,
              )
              .toSet()
              .toList()
        ..sort();

      final List<WoodProductModel> list = (_wood == null || _type == null)
          ? <WoodProductModel>[]
          : pc.variantsForName(_wood!).where((p) {
              final t = p.woodType.trim().isEmpty ? 'ບໍ່ລະບຸ' : p.woodType;
              return t == _type;
            }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. ຊື່ໄມ້ ──
          DropdownButtonFormField<String>(
            value: _wood,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ຊື່ໄມ້ *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category, color: Colors.brown),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            hint: const Text('ເລືອກຊື່ໄມ້'),
            items: names
                .map(
                  (n) => DropdownMenuItem<String>(
                    value: n,
                    child: Text(
                      n,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() {
              _wood = v;
              _type = null;
              c.selectedProduct.value = null;
            }),
          ),
          if (_wood != null) ...[
            const SizedBox(height: 12),
            // ── 2. ຊະນິດໄມ້ ──
            DropdownButtonFormField<String>(
              value: _type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ຊະນິດໄມ້ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist, color: Colors.brown),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              hint: const Text('ເລືອກຊະນິດ'),
              items: types
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _type = v;
                c.selectedProduct.value = null;
              }),
            ),
          ],
          if (_type != null && list.isNotEmpty) ...[
            const SizedBox(height: 12),
            // ── 3. ຂະໜາດ / ລາຄາ ──
            DropdownButtonFormField<String>(
              value: c.selectedProduct.value?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ຂະໜາດ / ລາຄາ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten, color: Colors.brown),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              hint: const Text('ເລືອກຂະໜາດ'),
              items: list
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ${fmt.format(p.price)} ກີບ',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                c.selectedProduct.value = list.firstWhere((p) => p.id == id);
                setState(() {});
              },
            ),
          ],
          // ── Preview ສິນຄ້າທີ່ເລືອກ ──
          if (c.selectedProduct.value != null) ...[
            const SizedBox(height: 12),
            _selectedProductPreview(c.selectedProduct.value!),
          ],
        ],
      );
    });
  }

  // ── Preview ສິນຄ້າ ──
  Widget _selectedProductPreview(WoodProductModel p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade50, Colors.brown.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.brown.shade700,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} · ຄົງເຫຼືອ ${p.quantity} ${p.unit}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedNumber(
            value: p.price,
            suffix: ' ກີບ',
            duration: 900,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Qty + Discount
  // ══════════════════════════════════════════════
  Widget _qtyRow() {
    return Obx(() {
      final p = c.selectedProduct.value;
      if (p == null) return const SizedBox.shrink();
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'ຈຳນວນ *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers, color: Colors.brown),
                suffixText: p.unit,
                isDense: true,
              ),
              onChanged: (v) =>
                  setState(() => _qty = (int.tryParse(v) ?? 1).clamp(1, 99999)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: discC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _NumFmt(),
              ],
              decoration: const InputDecoration(
                labelText: 'ລົດ/ຕົວ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.discount, color: Colors.brown, size: 18),
                suffixText: 'ກີບ',
                isDense: true,
              ),
              onChanged: (v) => setState(
                () => _disc = (double.tryParse(v.replaceAll(',', '')) ?? 0)
                    .clamp(0, double.infinity),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _discView() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount, color: Colors.red.shade700, size: 18),
              const SizedBox(width: 6),
              Text(
                'ສ່ວນລົດ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _discRow(
            '${fmt.format(_unit)} × $_qty',
            '${fmt.format(_gross)} ກີບ',
            Colors.black87,
          ),
          const SizedBox(height: 4),
          _discRow(
            'ລົດ ${fmt.format(_disc)} × $_qty',
            '-${fmt.format(_discTot)} ກີບ',
            Colors.red.shade700,
            bold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ຍອດສຸດທິ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              AnimatedNumber(
                value: _net,
                suffix: ' ກີບ',
                duration: 900,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _discRow(String label, String value, Color color, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // Payment type
  // ══════════════════════════════════════════════
  Widget _payTypeRow() {
    Widget chip(String l, IconData icon, String v, Color active) => Obx(() {
          final sel = c.paymentType.value == v;
          return InkWell(
            onTap: () {
              setState(() {
                c.paymentType.value = v;
                _choice = null;
                _topUpSlip = _topUpCash = null;
                _bills.clear();
                if (v == 'debt') {
                  _paid = 0;
                  paidC.clear();
                }
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: sel ? active : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? active : Colors.grey.shade300,
                  width: sel ? 2 : 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: sel ? Colors.white : active,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: sel ? Colors.white : active,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        });

    return Row(
      children: [
        Expanded(
          child: chip('ສົດ', Icons.payments_outlined, 'cash',
              Colors.brown.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: chip('ໂອນ', Icons.account_balance, 'transfer',
              Colors.brown.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: chip('ຕິດໜີ້', Icons.receipt_long_outlined, 'debt',
              Colors.orange.shade800),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // Image pickers
  // ══════════════════════════════════════════════
  Widget _imgPickers() {
    return Obx(() {
      if (_isDebt) return const SizedBox.shrink();
      return Row(
        children: [
          Expanded(
            child: _imgTile(
              _isCash ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບໂອນ',
              _payImg,
              () => _pick(which: 'pay'),
              () => setState(() => _payImg = null),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _imgTile(
              'ຮູບໃບບິນ',
              _billImg,
              () => _pick(which: 'bill'),
              () => setState(() => _billImg = null),
            ),
          ),
        ],
      );
    });
  }

  Widget _imgTile(
    String title,
    File? f,
    VoidCallback onTap,
    VoidCallback onRm, {
    double h = 110,
  }) {
    return InkWell(
      onTap: f == null ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: f == null ? Colors.grey.shade300 : Colors.green,
            width: f == null ? 1.2 : 2,
          ),
        ),
        child: f != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      f,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRm,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: Colors.brown.shade400,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Paid input
  // ══════════════════════════════════════════════
  Widget _paidInput() {
    return TextField(
      controller: paidC,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _NumFmt()],
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: _isCash ? 'ລູກຄ້າຈ່າຍມາ *' : 'ຈຳນວນທີ່ໂອນມາ *',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          _isCash ? Icons.payments_outlined : Icons.account_balance_wallet,
          color: Colors.brown,
        ),
        suffixText: 'ກີບ',
        helperText: _net > 0 ? 'ຍອດຕ້ອງຈ່າຍ ${fmt.format(_net)} ກີບ' : null,
        helperStyle: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.bold,
        ),
      ),
      onChanged: (v) => setState(() {
        _paid = double.tryParse(v.replaceAll(',', '')) ?? 0;
        if (_billsTot > _paid) _bills.clear();
        _choice = null;
      }),
    );
  }

  // ══════════════════════════════════════════════
  // Cash bills
  // ══════════════════════════════════════════════
  Widget _billsPanel() {
    if (!_isCash) return const SizedBox.shrink();
    final totalBills = _bills.values.fold<int>(0, (s, e) => s + e);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: Colors.brown, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'ນັບແຍກໃບເງິນ (ບັງຄັບ)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              if (_bills.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _bills.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'ລ້າງ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final row in [_r1, _r2]) ...[
            Row(
              children: [
                for (int i = 0; i < row.length; i++) ...[
                  Expanded(child: _billCard(row[i])),
                  if (i < row.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
            if (row != _r2) const SizedBox(height: 6),
          ],
          if (_bills.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown.shade300),
                  ),
                  child: Text(
                    '$totalBills ໃບ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ນັບໄດ້: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                AnimatedNumber(
                  value: _billsTot,
                  suffix: ' ກີບ',
                  duration: 800,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _billsTot == _paid && _paid > 0
                        ? Colors.green.shade700
                        : Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _billCard(int d) {
    final n = _bills[d] ?? 0;
    final on = n > 0;
    return InkWell(
      onTap: () => _addBill(d),
      onLongPress: () => _delBill(d),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: on ? Colors.brown.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? Colors.brown.shade800 : Colors.grey.shade300,
            width: on ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      fmt.format(d),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: on ? Colors.white : Colors.brown.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: on ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×$n',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: on
                            ? Colors.brown.shade800
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (on)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _delBill(d),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Change banner
  // ══════════════════════════════════════════════
  Widget _changeBanner() {
    if (_net <= 0 || _paid <= 0 || _hasShort) {
      return const SizedBox.shrink();
    }

    if (_hasChange) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade800, Colors.brown.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.redeem, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'ເງິນທອນລູກຄ້າ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedNumber(
                value: _change,
                suffix: ' ກີບ',
                duration: 1000,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ຮັບມາ ${fmt.format(_paid)} − ຍອດ ${fmt.format(_net)}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_paid == _net) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ຈ່າຍຄົບພໍດີ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ══════════════════════════════════════════════
  // Shortfall panel
  // ══════════════════════════════════════════════
  Widget _shortPanel() {
    if (_net <= 0 || (!_hasShort && !_noPay)) {
      return const SizedBox.shrink();
    }
    final debtOnly = _noPay;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade400, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.orange.shade900, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  debtOnly
                      ? 'ລູກຄ້າຍັງບໍ່ຈ່າຍ — ຕ້ອງການຕິດໜີ້ບໍ?'
                      : _isCash
                      ? 'ຍອດບໍ່ຄົບ — ຕ້ອງການໂອນເຕີມບໍ?'
                      : 'ຍອດບໍ່ຄົບ — ຕ້ອງການສົດເຕີມບໍ?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (debtOnly)
            _choiceBtn(
              Icons.receipt_long,
              'ຕິດໜີ້',
              'ບັນທຶກເປັນໜີ້ · ຈະເກັບພາຍຫຼັງ',
              Colors.orange.shade800,
              'debt',
            )
          else ...[
            _choiceBtn(
              _isCash ? Icons.account_balance : Icons.payments,
              _isCash ? 'ໂອນເຕີມ' : 'ສົດເຕີມ',
              _isCash
                  ? 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍການໂອນ'
                  : 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍເງິນສົດ',
              _isCash ? Colors.blue.shade700 : Colors.green.shade700,
              _isCash ? 'transfer' : 'cash',
            ),
            const SizedBox(height: 8),
            _choiceBtn(
              Icons.receipt_long,
              'ຕິດໜີ້',
              'ຄ້າງໄວ້ · ຈະເກັບພາຍຫຼັງ',
              Colors.orange.shade800,
              'debt',
            ),
          ],
          if (_choice == 'transfer') ...[
            const SizedBox(height: 12),
            _subImg(
              'ແນບຮູບສະລິບໂອນເຕີມ *',
              _topUpSlip,
              Icons.receipt_long_outlined,
              () => _pick(which: 'topSlip'),
              () => setState(() => _topUpSlip = null),
            ),
          ] else if (_choice == 'cash') ...[
            const SizedBox(height: 12),
            _subImg(
              'ແນບຮູບເງິນສົດທີ່ເຕີມ *',
              _topUpCash,
              Icons.payments_outlined,
              () => _pick(which: 'topCash'),
              () => setState(() => _topUpCash = null),
            ),
          ] else if (_choice == 'debt') ...[
            const SizedBox(height: 12),
            _debtForm(),
          ],
        ],
      ),
    );
  }

  Widget _choiceBtn(
    IconData icon,
    String label,
    String sub,
    Color color,
    String val,
  ) {
    final sel = _choice == val;
    return InkWell(
      onTap: () => setState(() => _choice = sel ? null : val),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? color : Colors.grey.shade300,
            width: sel ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: sel
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: sel ? Colors.white : color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: sel ? Colors.white : color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      color: sel
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              sel ? Icons.check_circle : Icons.radio_button_unchecked,
              color: sel ? Colors.white : Colors.grey.shade400,
              size: sel ? 26 : 24,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Debt form
  // ══════════════════════════════════════════════
  Widget _debtForm() {
    final canPay = _debtType == 'cash' || _debtType == 'transfer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RowLabel(Icons.payments_outlined, 'ລູກຄ້າຈ່າຍກ່ອນຫຼືບໍ່?'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _dChip('ສົດ', Icons.payments_outlined, 'cash')),
            const SizedBox(width: 8),
            Expanded(child: _dChip('ໂອນ', Icons.account_balance, 'transfer')),
            const SizedBox(width: 8),
            Expanded(child: _dChip('ຍັງບໍ່ຈ່າຍ', Icons.schedule, 'none')),
          ],
        ),
        if (canPay) ...[
          const SizedBox(height: 16),
          const _RowLabel(Icons.numbers, 'ຈຳນວນທີ່ຈ່າຍກ່ອນ *'),
          const SizedBox(height: 8),
          TextField(
            controller: debtPaidC,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _NumFmt(),
            ],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.payments, color: Colors.brown),
              suffixText: 'ກີບ',
              helperText:
                  'ຍອດ ${fmt.format(_net)} · ເຫຼືອ ${fmt.format(_debtReal)}',
              helperStyle: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onChanged: (v) {
              final n = double.tryParse(v.replaceAll(',', '')) ?? 0;
              setState(() => _debtPaid = n.clamp(0, _net).toDouble());
            },
          ),
          const SizedBox(height: 16),
          const _RowLabel(
            Icons.photo_camera_outlined,
            'ຮູບເງິນທີ່ຈ່າຍກ່ອນ (ຖ້າມີ)',
          ),
          const SizedBox(height: 8),
          _subImg(
            _debtType == 'cash' ? 'ແນບຮູບເງິນສົດ' : 'ແນບຮູບສະລິບ',
            _debtImg,
            _debtType == 'cash'
                ? Icons.payments_outlined
                : Icons.receipt_long_outlined,
            () => _pick(which: 'debt'),
            () => setState(() => _debtImg = null),
          ),
        ],
        const SizedBox(height: 16),
        _RowLabel(
          Icons.event_available,
          canPay ? 'ນັດວັນຈ່າຍທີ່ເຫຼືອ' : 'ນັດວັນຈ່າຍ',
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickAppt,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _apptDate == null
                    ? Colors.grey.shade300
                    : Colors.orange.shade400,
                width: _apptDate == null ? 1.2 : 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _apptDate == null
                      ? Icons.calendar_today_outlined
                      : Icons.calendar_today,
                  color: _apptDate == null
                      ? Colors.grey.shade600
                      : Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _apptTxt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _apptDate == null
                          ? Colors.grey.shade600
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
                if (_apptDate != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      _apptDate = null;
                      _apptTime = null;
                    }),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _RowLabel(
          Icons.person_outline,
          canPay ? 'ຂໍ້ມູນລູກຄ້າ' : 'ຂໍ້ມູນລູກຄ້າ',
        ),
        const SizedBox(height: 8),
        _tf(nameC, 'ຊື່ລູກຄ້າ *', Icons.person_outline),
        const SizedBox(height: 8),
        _tf(phoneC, 'ເບີໂທ *', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 8),
        _tf(addrC, 'ທີ່ຢູ່ *', Icons.home_outlined, lines: 2),
        const SizedBox(height: 8),
        _tf(
          debtNoteC,
          'ໝາຍເຫດໜີ້ (ຖ້າມີ)',
          Icons.sticky_note_2_outlined,
          lines: 2,
        ),
        const SizedBox(height: 16),
        // ── ສະຫຼຸບໜີ້ ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade100, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade400, width: 1.5),
          ),
          child: Column(
            children: [
              _sumRow('ຍອດຂາຍທັງໝົດ', '${fmt.format(_net)} ກີບ'),
              if (_debtPaid > 0) ...[
                const SizedBox(height: 4),
                _sumRow(
                  'ຈ່າຍກ່ອນ',
                  '-${fmt.format(_debtPaid)} ກີບ',
                  color: Colors.green.shade700,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Colors.orange),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ຍອດຕິດໜີ້ຕົວຈິງ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedNumber(
                      value: _debtReal,
                      suffix: ' ກີບ',
                      duration: 1000,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dChip(String label, IconData icon, String value) {
    final sel = _debtType == value;
    return InkWell(
      onTap: () => setState(() {
        _debtType = value;
        if (value == 'none') {
          debtPaidC.clear();
          _debtPaid = 0;
          _debtImg = null;
        }
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: sel ? Colors.orange.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? Colors.orange.shade800 : Colors.grey.shade300,
            width: sel ? 2 : 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: sel ? Colors.white : Colors.brown.shade700,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : Colors.brown.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
    int lines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.brown),
      ),
    );
  }

  Widget _subImg(
    String title,
    File? f,
    IconData icon,
    VoidCallback onPick,
    VoidCallback onRm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 8),
        _imgTile('', f, onPick, onRm, h: 120),
      ],
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      );

  // ══════════════════════════════════════════════
  // Summary
  // ══════════════════════════════════════════════
  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.receipt_long,
                      color: Colors.white, size: 15),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ສະຫຼຸບຍອດຂາຍ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _sumRow(
            'ລາຄາລວມ ($_qty ຊິ້ນ)',
            '${fmt.format(_gross)} ກີບ',
          ),
          if (_disc > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ສ່ວນລົດ ($_qty × ${fmt.format(_disc)})',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
                Text(
                  '-${fmt.format(_discTot)} ກີບ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.green),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ຍອດຂາຍລວມ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedNumber(
                  value: _net,
                  suffix: ' ກີບ',
                  duration: 1200,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _clear,
            icon: const Icon(Icons.clear_all),
            label: const Text(
              'ລ້າງຟອມ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text(
              'ບັນທຶກການຂາຍ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════
  Future<String?> _upload(File? f, String folder, String label) async {
    if (f == null) return null;
    final url = await CloudinaryService.uploadImage(
      f,
      folder: folder,
    ).timeout(const Duration(seconds: 60));
    if (url == null || url.isEmpty) {
      throw Exception('ອັບໂຫຼດ$labelບໍ່ສຳເລັດ');
    }
    return url;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (c.selectedProduct.value == null) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາເລືອກໄມ້ · ຊະນິດ · ຂະໜາດ');
      return;
    }
    if (_qty < 1 || _net <= 0) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາກວດສອບຂໍ້ມູນ');
      return;
    }

    if (_isDebt) {
      if (_missDebt) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາປ້ອນ ຊື່ · ເບີໂທ · ທີ່ຢູ່');
        return;
      }
      final canPay = _debtType == 'cash' || _debtType == 'transfer';
      if (canPay && _debtPaid <= 0) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາໃສ່ ຈຳນວນທີ່ຈ່າຍກ່ອນ');
        return;
      }
      if (_debtPaid > _net) {
        _warn('ຜິດພາດ', 'ຈ່າຍກ່ອນ ຕ້ອງບໍ່ເກີນ ${fmt.format(_net)} ກີບ');
        return;
      }
      await _doSave(
        payType: _debtType == 'none' ? 'cash' : _debtType,
        cash: _debtType == 'cash' ? _debtPaid : 0,
        trans: _debtType == 'transfer' ? _debtPaid : 0,
        debt: _debtReal,
        received: _debtPaid,
      );
      return;
    }

    if (_noPay && _choice != 'debt') {
      _warn('ຍັງບໍ່ຈ່າຍ', 'ກະລຸນາເລືອກ "ຕິດໜີ້"');
      return;
    }
    if (_paid > 0 && _hasShort && _choice == null) {
      _warn('ຍອດບໍ່ຄົບ', 'ເລືອກວິທີຈ່າຍສ່ວນທີ່ຂາດ');
      return;
    }
    if (_isCash && _paid > 0) {
      if (_bills.isEmpty) {
        _warn('ຕ້ອງນັບໃບ', 'ກະລຸນານັບແຍກໃບເງິນ');
        return;
      }
      if (_billsTot != _paid) {
        _err(
          'ນັບບໍ່ຕົງ',
          'ນັບໄດ້ ${fmt.format(_billsTot)} · ຕ້ອງຕົງກັບ ${fmt.format(_paid)}',
        );
        return;
      }
    }

    final isCash = _isCash;
    final total = _net;
    double cash = isCash ? (total < _paid ? total : _paid) : 0;
    double trans = isCash ? 0 : (total < _paid ? total : _paid);
    double debt = 0;
    String payType = c.paymentType.value;

    if (_paid > 0 && _hasShort) {
      if (_choice == 'transfer') {
        if (_topUpSlip == null) {
          _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາແນບຮູບສະລິບ');
          return;
        }
        trans += _short;
        payType = 'mixed';
      } else if (_choice == 'cash') {
        if (_topUpCash == null) {
          _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາແນບຮູບເງິນສົດ');
          return;
        }
        cash += _short;
        payType = 'mixed';
      } else if (_choice == 'debt') {
        if (_missDebt) {
          _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາປ້ອນຂໍ້ມູນລູກຄ້າ');
          return;
        }
        debt = _short;
      }
    }

    if (_noPay && _choice == 'debt') {
      if (_missDebt) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາປ້ອນຂໍ້ມູນລູກຄ້າ');
        return;
      }
      debt = total;
    }

    await _doSave(
      payType: payType,
      cash: cash,
      trans: trans,
      debt: debt,
      received: _paid,
    );
  }

  Future<void> _doSave({
    required String payType,
    required double cash,
    required double trans,
    required double debt,
    required double received,
  }) async {
    final isCash = c.paymentType.value == 'cash';
    final total = _net;
    final isDebt = c.paymentType.value == 'debt';

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.brown)),
      barrierDismissible: false,
    );

    try {
      final res = await Future.wait<String?>([
        _upload(_payImg, 'sales/payments', isCash ? 'ຮູບສົດ' : 'ຮູບສະລິບ'),
        _upload(_billImg, 'sales/bills', 'ຮູບໃບບິນ'),
        _upload(_topUpSlip, 'sales/topup_transfer', 'ສະລິບເຕີມ'),
        _upload(_topUpCash, 'sales/topup_cash', 'ຮູບສົດເຕີມ'),
        _upload(_debtImg, 'sales/debt_payments', 'ຮູບຈ່າຍກ່ອນ'),
      ]);

      final topUp = <String>[
        if (res[2] != null) res[2]!,
        if (res[3] != null) res[3]!,
      ];
      final payImgs = <String>[
        if (res[0] != null) res[0]!,
        if (res[4] != null) res[4]!,
      ];

      Map<int, int>? bills;
      if (isCash && _bills.isNotEmpty) {
        bills = Map<int, int>.from(_bills);
      }

      final note = StringBuffer();
      if (noteC.text.trim().isNotEmpty) {
        note.write(noteC.text.trim());
      }
      if (isDebt && _apptDate != null) {
        if (note.isNotEmpty) note.write(' | ');
        final t = _apptTime ?? const TimeOfDay(hour: 9, minute: 0);
        note.write(
          'ນັດຈ່າຍ: ${_apptDate!.day}/${_apptDate!.month}/${_apptDate!.year} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        );
      }

      final newSale = SaleEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: c.selectedProduct.value!.id,
        productName: c.selectedProduct.value!.name,
        paymentType: payType,
        totalAmount: total,
        quantity: _qty,
        discountPerUnit: _disc,
        cashPaidAmount: cash,
        transferPaidAmount: trans,
        debtAmount: debt,
        receivedAmount: received,
        paymentImageUrls: payImgs,
        billImageUrls: res[1] != null ? [res[1]!] : const [],
        topUpImageUrls: topUp,
        customerName: debt > 0 ? nameC.text.trim() : null,
        customerAddress: debt > 0 ? addrC.text.trim() : null,
        customerPhone: debt > 0 ? phoneC.text.trim() : null,
        debtDate: debt > 0 ? DateTime.now() : null,
        debtNote: debt > 0 && debtNoteC.text.trim().isNotEmpty
            ? debtNoteC.text.trim()
            : null,
        appointmentDate: isDebt ? _apptDate : null,
        note: note.toString().trim(),
        date: DateTime.now(),
        isConfirmed: false,
        cashDenominations: bills,
      );

      await c.repository.addSale(newSale);
      c.fetchSales();
      Get.back();
      Get.back();
      _ok('ສຳເລັດ', 'ບັນທຶກການຂາຍຮຽບຮ້ອຍແລ້ວ');

      c.notifyNewSale(newSale);
    } catch (e) {
      Get.back();
      _err('ບັນທຶກບໍ່ສຳເລັດ', '$e');
    }
  }
}

// ══════════════════════════════════════════════
// 📏 Row Label
// ══════════════════════════════════════════════
class _RowLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RowLabel(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: Colors.brown, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      );
}