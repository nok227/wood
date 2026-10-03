import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/utils/cloudinary_service.dart';
import 'package:wood/core/widgets/section_wrapper.dart';
import 'package:wood/core/widgets/number_formatter.dart';
import 'package:wood/features/sales/domain/entities/sale_item_entity.dart';
import 'package:wood/features/sales/domain/entities/sale_order_entity.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/add_payment_bills_panel.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/add_payment_debt_form.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/add_payment_items_panel.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/add_payment_summary.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/add_payment_wood_picker.dart';
import 'package:wood/features/sales/presentation/widgets/add_payment/full_image_viewer.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import 'package:wood/features/sales/presentation/widgets/sale_order_preview_card.dart';

import '../../controllers/sales_controller.dart';

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

  final noteC = TextEditingController();
  final qtyC = TextEditingController(text: '1');
  final discC = TextEditingController(text: '0');
  final paidC = TextEditingController();
  final nameC = TextEditingController();
  final addrC = TextEditingController();
  final phoneC = TextEditingController();
  final debtNoteC = TextEditingController();
  final debtPaidC = TextEditingController();

  final List<SaleItemEntity> _items = [];

  String? _wood, _type;
  String _unitFilter = 'ທັງໝົດ';
  int _qty = 1;
  double _disc = 0, _paid = 0, _debtPaid = 0;
  String? _choice;
  String _debtType = 'none';
  File? _payImg, _billImg, _topUpSlip, _topUpCash, _debtImg, _debtBillImg;
  DateTime? _apptDate;
  TimeOfDay? _apptTime;
  final Map<int, int> _bills = {};

  // ─── ຄຳນວນຈາກ list ───
  double get _gross => _items.fold(0.0, (s, e) => s + e.grossAmount);
  double get _discTot => _items.fold(0.0, (s, e) => s + e.discountAmount);
  double get _net => _items.fold(0.0, (s, e) => s + e.totalAmount);
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
  bool get _missDebtBill => _debtBillImg == null;

  bool get _previewReady {
    if (_items.isEmpty) return false;
    if (_isDebt) return _doneDebt;
    return _donePay;
  }

  bool get _done1 => _items.isNotEmpty;
  bool get _done2 => _items.isNotEmpty;
  bool get _done3 => _payImg != null || _billImg != null;
  bool get _doneDebt =>
      nameC.text.trim().isNotEmpty &&
      phoneC.text.trim().isNotEmpty &&
      addrC.text.trim().isNotEmpty &&
      _debtBillImg != null;
  bool get _donePay {
    if (_paid <= 0) return false;
    if (_isCash) {
      return _bills.isNotEmpty && _billsTot == _paid;
    }
    return true;
  }

  bool get _doneNote => noteC.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    c.resetForm();

    noteC.addListener(_onTextChanged);
    nameC.addListener(_onTextChanged);
    phoneC.addListener(_onTextChanged);
    addrC.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    noteC.removeListener(_onTextChanged);
    nameC.removeListener(_onTextChanged);
    phoneC.removeListener(_onTextChanged);
    addrC.removeListener(_onTextChanged);

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

  void _addCurrentItem() {
    if (c.selectedProduct.value == null) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາເລືອກໄມ້ · ຊະນິດ · ຂະໜາດ');
      return;
    }
    final p = c.selectedProduct.value!;
    if (_qty < 1) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ຈຳນວນຕ້ອງ ≥ 1');
      return;
    }
    if (_disc > p.price) {
      _warn('ຜິດພາດ', 'ສ່ວນລົດຕ້ອງບໍ່ເກີນລາຄາ');
      return;
    }

    setState(() {
      _items.add(
        SaleItemEntity(
          itemId: 'i_${DateTime.now().microsecondsSinceEpoch}',
          productId: p.id,
          productName: p.name,
          woodType: p.woodType,
          productWidth: p.width,
          productLength: p.length,
          productThickness: p.thickness,
          productSizeUnit: p.sizeUnit,
          unitPrice: p.price,
          quantity: _qty,
          unit: p.unit,
          discountPerUnit: _disc,
        ),
      );

      c.selectedProduct.value = null;
      _wood = null;
      _type = null;
      _qty = 1;
      _disc = 0;
      qtyC.text = '1';
      discC.text = '0';
    });

    _ok('ເພີ່ມແລ້ວ', 'ລາຍການທີ ${_items.length}');
  }

  void _removeItem(int idx) {
    setState(() => _items.removeAt(idx));
  }

  void _editItem(int idx) {
    final item = _items[idx];
    final products = pc.products;
    final p = products.firstWhereOrNull((x) => x.id == item.productId);
    if (p == null) {
      _warn('ຜິດພາດ', 'ບໍ່ພົບສິນຄ້າໃນຄັງ');
      return;
    }
    setState(() {
      c.selectedProduct.value = p;
      _wood = p.name;
      _type = p.woodType.trim().isEmpty ? 'ບໍ່ລະບຸ' : p.woodType;
      _qty = item.quantity;
      _disc = item.discountPerUnit;
      qtyC.text = _qty.toString();
      discC.text = _disc.toString();
      _items.removeAt(idx);
    });
  }

  void _clear() {
    setState(() {
      _items.clear();
      _wood = _type = _choice = null;
      _unitFilter = 'ທັງໝົດ';
      _payImg = _billImg = _topUpSlip = _topUpCash = _debtImg = null;
      _debtBillImg = null;
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
          case 'debtBill':
            _debtBillImg = f;
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

  // 🆕 ເພີ່ມຫຼາຍໃບພ້ອມກັນ
  void _addBillBy(int d, int count) {
    final remaining = _paid - _billsTot;
    if (remaining < d) {
      _warn('ເກີນຍອດ', 'ເຫຼືອ ${fmt.format(remaining)} ກີບ');
      return;
    }
    final allowed = (remaining / d).floor();
    final add = count > allowed ? allowed : count;
    if (add <= 0) return;
    setState(() => _bills[d] = (_bills[d] ?? 0) + add);
  }

  // 🆕 ຕັ້ງຈຳນວນໃບຕົງໆ
  void _setBillCount(int d, int count) {
    if (count <= 0) {
      setState(() => _bills.remove(d));
      return;
    }
    final othersTotal = _billsTot - (d * (_bills[d] ?? 0));
    final maxAllowed = ((_paid - othersTotal) / d).floor();
    if (maxAllowed <= 0) {
      _warn('ເກີນຍອດ', 'ຍອດເງິນບໍ່ພໍ');
      return;
    }
    final set = count > maxAllowed ? maxAllowed : count;
    setState(() {
      if (set <= 0) {
        _bills.remove(d);
      } else {
        _bills[d] = set;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'ບັນທຶກການຂາຍ${_items.isNotEmpty ? " (${_items.length})" : ""}',
        ),
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
              SectionWrapper(
                number: '1',
                title: 'ເລືອກສິນຄ້າໄມ້',
                icon: Icons.inventory_2_outlined,
                color: Colors.brown,
                done: _done1,
                child: AddPaymentWoodPicker(
                  c: c,
                  pc: pc,
                  fmt: fmt,
                  wood: _wood,
                  type: _type,
                  unitFilter: _unitFilter,
                  qty: _qty,
                  disc: _disc,
                  qtyC: qtyC,
                  discC: discC,
                  onWoodChanged: (v) => setState(() {
                    _wood = v;
                    _type = null;
                    c.selectedProduct.value = null;
                  }),
                  onTypeChanged: (v) => setState(() {
                    _type = v;
                    c.selectedProduct.value = null;
                  }),
                  onUnitFilterChanged: (v) => setState(() {
                    _unitFilter = v;
                    _wood = null;
                    _type = null;
                    c.selectedProduct.value = null;
                  }),
                  onQtyChanged: (v) => setState(() => _qty = v),
                  onDiscChanged: (v) => setState(() => _disc = v),
                  onAddItem: _addCurrentItem,
                ),
              ),

              if (_items.isNotEmpty) ...[
                const SizedBox(height: 16),
                AddPaymentItemsPanel(
                  items: _items,
                  fmt: fmt,
                  net: _net,
                  onEdit: _editItem,
                  onRemove: _removeItem,
                ),
              ],

              if (_items.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionWrapper(
                  number: '2',
                  title: 'ປະເພດການຊຳລະ',
                  icon: Icons.payments_outlined,
                  color: Colors.brown,
                  done: _done2,
                  child: _payTypeRow(),
                ),
                const SizedBox(height: 16),

                Obx(() {
                  if (_isDebt) return const SizedBox.shrink();
                  return Column(
                    children: [
                      SectionWrapper(
                        number: '3',
                        title: 'ຮູບພາບຢືນຢັນ',
                        icon: Icons.photo_library_outlined,
                        color: Colors.brown,
                        done: _done3,
                        child: _imgPickers(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                Obx(() {
                  if (_isDebt) {
                    return SectionWrapper(
                      number: '3',
                      title: 'ຂໍ້ມູນການຕິດໜີ້',
                      icon: Icons.receipt_long_outlined,
                      color: Colors.orange.shade800,
                      done: _doneDebt,
                      child: AddPaymentDebtForm(
                        nameC: nameC,
                        phoneC: phoneC,
                        addrC: addrC,
                        debtNoteC: debtNoteC,
                        debtPaidC: debtPaidC,
                        debtType: _debtType,
                        debtPaid: _debtPaid,
                        net: _net,
                        debtReal: _debtReal,
                        apptDate: _apptDate,
                        apptTime: _apptTime,
                        debtImg: _debtImg,
                        debtBillImg: _debtBillImg,
                        onDebtTypeChanged: (v) => setState(() {
                          _debtType = v;
                          if (v == 'none') {
                            debtPaidC.clear();
                            _debtPaid = 0;
                            _debtImg = null;
                          }
                        }),
                        onDebtPaidChanged: (v) => setState(() => _debtPaid = v),
                        onPickAppt: _pickAppt,
                        onPickDebtImg: () => _pick(which: 'debt'),
                        onClearDebtImg: () => setState(() => _debtImg = null),
                        onPickDebtBill: () => _pick(which: 'debtBill'),
                        onClearDebtBill: () =>
                            setState(() => _debtBillImg = null),
                        onClearAppt: () => setState(() {
                          _apptDate = null;
                          _apptTime = null;
                        }),
                      ),
                    );
                  }
                  return SectionWrapper(
                    number: '4',
                    title: 'ການຈ່າຍເງິນ',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.brown,
                    done: _donePay,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _paidInput(),
                        AddPaymentBillsPanel(
                          bills: _bills,
                          isCash: _isCash,
                          paid: _paid,
                          billsTot: _billsTot,
                          fmt: fmt,
                          onAdd: _addBill,
                          onAddBy5: (d) => _addBillBy(d, 5),
                          onDelete: _delBill,
                          onReset: (d) => setState(() => _bills.remove(d)),
                          onSetCount: _setBillCount,
                          onClear: () => setState(() => _bills.clear()),
                        ),
                        _changeBanner(),
                        _shortPanel(),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                SectionWrapper(
                  number: _isDebt ? '4' : '5',
                  title: 'ໝາຍເຫດ',
                  icon: Icons.sticky_note_2_outlined,
                  color: Colors.brown,
                  done: _doneNote,
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

                AddPaymentSummary(
                  items: _items,
                  discTot: _discTot,
                  net: _net,
                  fmt: fmt,
                ),

                if (_previewReady) ...[
                  const SizedBox(height: 16),
                  SaleOrderPreviewCard(
                    items: List<SaleItemEntity>.from(_items),
                    paymentType: c.paymentType.value,
                    cashPaid: _isDebt
                        ? (_debtType == 'cash' ? _debtPaid : 0)
                        : (_isCash ? (_net < _paid ? _net : _paid) : 0),
                    transferPaid: _isDebt
                        ? (_debtType == 'transfer' ? _debtPaid : 0)
                        : (_isCash ? 0 : (_net < _paid ? _net : _paid)),
                    debt: _isDebt ? _debtReal : 0,
                    received: _isDebt ? _debtPaid : _paid,
                    bills: _isCash ? Map<int, int>.from(_bills) : {},
                    customerName: _isDebt ? nameC.text.trim() : null,
                    customerPhone: _isDebt ? phoneC.text.trim() : null,
                    customerAddress: _isDebt ? addrC.text.trim() : null,
                    debtNote: _isDebt && debtNoteC.text.trim().isNotEmpty
                        ? debtNoteC.text.trim()
                        : null,
                    appointmentDate: _isDebt ? _apptDate : null,
                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                    payImgCount:
                        (_payImg != null ? 1 : 0) + (_debtImg != null ? 1 : 0),
                    billImgCount:
                        (_billImg != null ? 1 : 0) +
                        (_debtBillImg != null ? 1 : 0),
                    topUpImgCount:
                        (_topUpSlip != null ? 1 : 0) +
                        (_topUpCash != null ? 1 : 0),
                    debtPayImgCount: _debtImg != null ? 1 : 0,
                    debtBillCount: _debtBillImg != null ? 1 : 0,
                  ),
                ],

                const SizedBox(height: 16),
                _buttons(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
              Icon(icon, color: sel ? Colors.white : active, size: 22),
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
          child: chip(
            'ສົດ',
            Icons.payments_outlined,
            'cash',
            Colors.brown.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: chip(
            'ໂອນ',
            Icons.account_balance,
            'transfer',
            Colors.brown.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: chip(
            'ຕິດໜີ້',
            Icons.receipt_long_outlined,
            'debt',
            Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

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
    BoxFit fit = BoxFit.cover,
    VoidCallback? onView,
  }) {
    return InkWell(
      onTap: f == null ? onTap : onView,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: fit == BoxFit.contain && f != null
              ? Colors.grey.shade100
              : Colors.grey.shade50,
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
                      fit: fit,
                      alignment: Alignment.center,
                    ),
                  ),
                  if (onView != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_out_map,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ກົດເພື່ອຂະຫຍາຍ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
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
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: title.isEmpty ? 56 : 38,
                      color: Colors.brown.shade400,
                    ),
                    if (title.isNotEmpty) ...[
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget _paidInput() {
    return TextField(
      controller: paidC,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberFormatter(),
      ],
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
              child: Text(
                '${fmt.format(_change)} ກີບ',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Text(
                'ປ້ອນຂໍ້ມູນລູກຄ້າຕິດໜີ້ຢູ່ຂ້າງລຸ່ມ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
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

  Widget _subImg(
    String title,
    File? f,
    IconData icon,
    VoidCallback onPick,
    VoidCallback onRm, {
    bool big = false,
  }) {
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
        _imgTile(
          '',
          f,
          onPick,
          onRm,
          h: (big && f != null) ? 320 : 120,
          fit: big ? BoxFit.contain : BoxFit.cover,
          onView: (big && f != null) ? () => _viewFull(f) : null,
        ),
      ],
    );
  }

  void _viewFull(File f) {
    Get.dialog(
      FullImageViewer(file: f),
      barrierColor: Colors.transparent,
      useSafeArea: false,
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

    if (_items.isEmpty) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ກະລຸນາເພີ່ມລາຍການຢ່າງໜ້ອຍ 1');
      return;
    }
    if (_net <= 0) {
      _warn('ຕ້ອງການຂໍ້ມູນ', 'ຍອດລວມຕ້ອງ > 0');
      return;
    }

    if (_isDebt) {
      if (_missDebt) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາປ້ອນ ຊື່ · ເບີໂທ · ທີ່ຢູ່');
        return;
      }
      if (_missDebtBill) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາແນບຮູບໃບບິນໜີ້ *');
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
        if (_missDebtBill) {
          _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາແນບຮູບໃບບິນໜີ້ *');
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
      if (_missDebtBill) {
        _warn('ຂາດຂໍ້ມູນ', 'ກະລຸນາແນບຮູບໃບບິນໜີ້ *');
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
        _upload(_debtBillImg, 'sales/debt_bills', 'ຮູບໃບບິນໜີ້'),
      ]);

      final topUp = <String>[
        if (res[2] != null) res[2]!,
        if (res[3] != null) res[3]!,
      ];
      final payImgs = <String>[
        if (res[0] != null) res[0]!,
        if (res[4] != null) res[4]!,
      ];
      final billImgs = <String>[
        if (res[1] != null) res[1]!,
        if (res[5] != null) res[5]!,
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
          'ນັດຈ່າຍ: ${_apptDate!.day}/${_apptDate!.month}/${_apptDate!.year} '
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        );
      }

      final newOrder = SaleOrderEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List<SaleItemEntity>.from(_items),
        paymentType: payType,
        cashPaidAmount: cash,
        transferPaidAmount: trans,
        debtAmount: debt,
        receivedAmount: received,
        paymentImageUrls: payImgs,
        billImageUrls: billImgs,
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

      await c.addOrder(newOrder);
      Get.back();
      Get.back();
      _ok('ສຳເລັດ', 'ບັນທຶກການຂາຍ ${_items.length} ລາຍການ');

      c.notifyNewSale(newOrder);
    } catch (e) {
      Get.back();
      _err('ບັນທຶກບໍ່ສຳເລັດ', '$e');
    }
  }
}
