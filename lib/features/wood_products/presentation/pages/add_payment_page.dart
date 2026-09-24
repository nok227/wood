import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/util/cloudinary_service.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';
import '../controllers/sales_controller.dart';
import '../../domain/entities/sale_entity.dart';

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = NumberFormat('#,###').format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({Key? key}) : super(key: key);

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final controller = Get.find<SalesController>();
  final productController = Get.find<WoodProductController>();
  final noteController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController();
  final currencyFormat = NumberFormat('#,###');
  final _picker = ImagePicker();

  String? _selectedWoodName;
  File? _paymentImage;
  File? _billImage;

  int _quantity = 1;
  double _discountPerUnit = 0;
  double _paidAmount = 0;

  /// 📝 ນັບໃບເງິນ (ບັນທຶກເທົ່ານັ້ນ)
  final Map<int, int> _cashBills = {};

  String? _shortfallChoice;
  File? _topUpTransferSlip;
  File? _topUpCashImage;

  final customerNameController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final debtNoteController = TextEditingController();

  static const List<int> _topRow = [500, 1000, 2000, 5000];
  static const List<int> _bottomRow = [10000, 20000, 50000, 100000];

  @override
  void initState() {
    super.initState();
    controller.resetForm();
  }

  @override
  void dispose() {
    noteController.dispose();
    quantityController.dispose();
    discountController.dispose();
    paidController.dispose();
    customerNameController.dispose();
    customerAddressController.dispose();
    customerPhoneController.dispose();
    debtNoteController.dispose();
    super.dispose();
  }

  // ---------- ຄຳນວນ ----------
  double get _unitPrice => controller.selectedProduct.value?.price ?? 0;
  double get _grossTotal => _unitPrice * _quantity;
  double get _discountTotal => _discountPerUnit * _quantity;
  double get _netTotal {
    final v = _grossTotal - _discountTotal;
    return v < 0 ? 0 : v;
  }

  bool get _isCash => controller.paymentType.value == 'cash';

  double get _shortfall {
    final v = _netTotal - _paidAmount;
    return v < 0 ? 0 : v;
  }

  double get _change {
    final v = _paidAmount - _netTotal;
    return v < 0 ? 0 : v;
  }

  bool get _hasShortfall => _shortfall > 0;
  bool get _hasChange => _change > 0;

  double get _billsTotal {
    double t = 0;
    _cashBills.forEach((d, n) => t += d * n);
    return t;
  }

  // ---------- Helpers ----------
  void _toast(String title, String msg) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      msg,
      backgroundColor: Colors.brown.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: Icon(
        title.contains('ສຳເລັດ') ? Icons.check_circle : Icons.info_outline,
        color: Colors.white,
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedWoodName = null;
      _paymentImage = null;
      _billImage = null;
      _topUpTransferSlip = null;
      _topUpCashImage = null;
      _shortfallChoice = null;
      noteController.clear();
      quantityController.text = '1';
      discountController.text = '0';
      paidController.clear();
      customerNameController.clear();
      customerAddressController.clear();
      customerPhoneController.clear();
      debtNoteController.clear();
      _quantity = 1;
      _discountPerUnit = 0;
      _paidAmount = 0;
      _cashBills.clear();
    });
    controller.resetForm();
    _toast('ສຳເລັດ', 'ລ້າງຟອມຮຽບຮ້ອຍແລ້ວ');
  }

  Future<void> _pickImage(
    bool isBill, {
    bool isTopUp = false,
    bool isTopUpSlip = false,
  }) async {
    Future<void> handle(ImageSource source) async {
      Get.back();
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() {
        if (isTopUp && isTopUpSlip) {
          _topUpTransferSlip = File(picked.path);
        } else if (isTopUp) {
          _topUpCashImage = File(picked.path);
        } else if (isBill) {
          _billImage = File(picked.path);
        } else {
          _paymentImage = File(picked.path);
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
              title: const Text('ຖ່າຍຮູບ (Camera)'),
              onTap: () => handle(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.brown),
              title: const Text('ເລືອກຈາກຄັງຮູບ (Gallery)'),
              onTap: () => handle(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('ບັນທຶກການຂາຍ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWoodDropdown(),
              const SizedBox(height: 12),
              _buildQuantityRow(),
              const SizedBox(height: 12),
              _buildDiscountPreview(),
              const SizedBox(height: 12),
              _buildPaymentTypeRow(),
              const SizedBox(height: 12),
              _buildImagePickers(),
              const SizedBox(height: 12),
              _buildPaidInput(),
              // 💵 ນັບໃບ — inline (ສະເພາະ cash)
              _buildCashBillsInline(),
              _buildChangeBanner(),
              _buildShortfallPanel(),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'ໝາຍເຫດ',
                  hintText: 'ເພີ່ມໝາຍເຫດ (ຖ້າມີ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTotalSummary(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 1. Wood dropdown
  // ══════════════════════════════════════════════
  Widget _buildWoodDropdown() {
    return Obx(() {
      if (productController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator(color: Colors.brown)),
        );
      }

      final woodNames = productController.uniqueProductNames;
      if (woodNames.isEmpty) {
        return DropdownButtonFormField<String>(
          value: null,
          decoration: const InputDecoration(
            labelText: 'ເລືອກຊື່ໄມ້ *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.inventory_2, color: Colors.grey),
          ),
          items: const [],
          onChanged: null,
          hint: const Text('ບໍ່ມີລາຍການໄມ້'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedWoodName,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: '1. ເລືອກຊື່ໄມ້ *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category, color: Colors.brown),
            ),
            hint: const Text('ກະລຸນາເລືອກຊື່ໄມ້'),
            items: woodNames
                .map(
                  (n) => DropdownMenuItem(
                    value: n,
                    child: Text(
                      n,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newName) => setState(() {
              _selectedWoodName = newName;
              controller.selectedProduct.value = null;
            }),
          ),
          if (_selectedWoodName != null) ...[
            const SizedBox(height: 12),
            _buildVariantDropdown(_selectedWoodName!),
          ],
        ],
      );
    });
  }

  Widget _buildVariantDropdown(String woodName) {
    final variants = productController.variantsForName(woodName);
    return DropdownButtonFormField<String>(
      value: controller.selectedProduct.value?.id,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '2. ເລືອກຂະໜາດ / ລາຄາ *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.straighten, color: Colors.brown),
      ),
      hint: const Text('ກະລຸນາເລືອກຂະໜາດ'),
      items: variants
          .map(
            (p) => DropdownMenuItem(
              value: p.id,
              child: Text(
                '${p.width}x${p.length}x${p.thickness} ${p.sizeUnit} - ${currencyFormat.format(p.price)} ກີບ',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (id) {
        if (id != null) {
          controller.selectedProduct.value = variants.firstWhere(
            (p) => p.id == id,
          );
          setState(() {});
        }
      },
    );
  }

  // ══════════════════════════════════════════════
  // 2. ຈຳນວນ + ສ່ວນຫຼຸດ
  // ══════════════════════════════════════════════
  Widget _buildQuantityRow() {
    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null) return const SizedBox.shrink();

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: '3. ຈຳນວນ *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers, color: Colors.brown),
                suffixText: product.unit,
              ),
              onChanged: (v) {
                final n = int.tryParse(v) ?? 1;
                setState(() => _quantity = n < 1 ? 1 : n);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ThousandsFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'ລົດ/ຕົວ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.discount, color: Colors.brown, size: 14),
                suffixText: 'ກີບ',
              ),
              onChanged: (v) {
                final d = double.tryParse(v.replaceAll(',', '')) ?? 0;
                setState(() => _discountPerUnit = d < 0 ? 0 : d);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDiscountPreview() {
    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null || _discountPerUnit <= 0) {
        return const SizedBox.shrink();
      }

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
            const SizedBox(height: 6),
            Text(
              '${currencyFormat.format(_unitPrice)} × $_quantity = ${currencyFormat.format(_grossTotal)} ກີບ',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'ລົດ ${currencyFormat.format(_discountPerUnit)} × $_quantity = -${currencyFormat.format(_discountTotal)} ກີບ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const Divider(height: 12),
            Text(
              'ຍອດສຸດທິ: ${currencyFormat.format(_netTotal)} ກີບ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════
  // 3. ວິທີຊຳລະ
  // ══════════════════════════════════════════════
  Widget _buildPaymentTypeRow() {
    Widget chip(String label, String value) {
      return Obx(
        () => ChoiceChip(
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          selected: controller.paymentType.value == value,
          selectedColor: Colors.brown.shade100,
          onSelected: (s) {
            if (s) {
              setState(() {
                controller.paymentType.value = value;
                _shortfallChoice = null;
                _topUpTransferSlip = null;
                _topUpCashImage = null;
                _cashBills.clear();
              });
            }
          },
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: chip('💵 ເງິນສົດ', 'cash')),
        const SizedBox(width: 8),
        Expanded(child: chip('🏦 ເງິນໂອນ', 'transfer')),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 4. ຮູບພາບ
  // ══════════════════════════════════════════════
  Widget _buildImagePickers() {
    return Obx(() {
      final isCash = controller.paymentType.value == 'cash';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _imageTile(
              title: isCash ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບໂອນ',
              file: _paymentImage,
              onTap: () => _pickImage(false),
              onRemove: () => setState(() => _paymentImage = null),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _imageTile(
              title: 'ຮູບໃບບິນ',
              file: _billImage,
              onTap: () => _pickImage(true),
              onRemove: () => setState(() => _billImage = null),
            ),
          ),
        ],
      );
    });
  }

  Widget _imageTile({
    required String title,
    required File? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return InkWell(
      onTap: file == null ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: file != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 32, color: Colors.brown),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 5. 💰 input ຈຳນວນທີ່ລູກຄ້າຈ່າຍມາ
  // ══════════════════════════════════════════════
  Widget _buildPaidInput() {
    return Obx(() {
      final isCash = controller.paymentType.value == 'cash';
      return TextField(
        controller: paidController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _ThousandsFormatter(),
        ],
        decoration: InputDecoration(
          labelText: isCash ? '4. ລູກຄ້າຈ່າຍມາ *' : '4. ຈຳນວນທີ່ໂອນມາ *',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(
            isCash ? Icons.payments_outlined : Icons.account_balance_wallet,
            color: Colors.brown,
          ),
          suffixText: 'ກີບ',
          helperText: _netTotal > 0
              ? 'ຍອດຕ້ອງຈ່າຍ ${currencyFormat.format(_netTotal)} ກີບ'
              : null,
        ),
        onChanged: (v) {
          final amt = double.tryParse(v.replaceAll(',', '')) ?? 0;
          setState(() {
            _paidAmount = amt;
            // ✅ ຖ້ານັບໄວ້ເກີນຍອດໃໝ່ → ລ້າງອັດຕະໂນມັດ
            if (_billsTotal > amt) {
              _cashBills.clear();
            }
            _shortfallChoice = null;
          });
        },
      );
    });
  }

  // ══════════════════════════════════════════════
  // 💵 ນັບໃບ — ສະແດງ inline ພາຍໃຕ້ input
  // ══════════════════════════════════════════════
  Widget _buildCashBillsInline() {
    return Obx(() {
      if (controller.paymentType.value != 'cash') {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    'ນັບແຍກໃບເງິນ (ທາງເລືອກ)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                if (_cashBills.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _cashBills.clear()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
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
            const SizedBox(height: 4),
            Text(
              'ແຕະໃບ = ເພີ່ມ · ແຕະ [−] = ຫຼຸດ',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),

            // ── ແຖວ 1: 500, 1000, 2000, 5000 ──
            Row(
              children: [
                for (int i = 0; i < _topRow.length; i++) ...[
                  Expanded(child: _billCard(_topRow[i])),
                  if (i < _topRow.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // ── ແຖວ 2: 10k, 20k, 50k, 100k ──
            Row(
              children: [
                for (int i = 0; i < _bottomRow.length; i++) ...[
                  Expanded(child: _billCard(_bottomRow[i])),
                  if (i < _bottomRow.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),

            // ── ລວມ ──
            if (_cashBills.isNotEmpty) ...[
              const Divider(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.brown.shade200),
                    ),
                    child: Text(
                      '${_cashBills.values.fold<int>(0, (s, e) => s + e)} ໃບ',
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
                  Text(
                    '${currencyFormat.format(_billsTotal)} ກີບ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _billCard(int denom) {
    final count = _cashBills[denom] ?? 0;
    final active = count > 0;
    final label = currencyFormat.format(
      denom,
    ); // ✅ 500 · 1,000 · 10,000 · 100,000

    return InkWell(
      onTap: () => _addBill(denom),
      onLongPress: () => _removeBill(denom),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: active ? Colors.brown.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? Colors.brown.shade800 : Colors.grey.shade300,
            width: active ? 2 : 1.5,
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
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: active ? Colors.white : Colors.brown.shade800,
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
                      color: active ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: active
                            ? Colors.brown.shade800
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _removeBill(denom),
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

  void _addBill(int denom) {
    final current = _billsTotal;
    final max = _paidAmount;
    if (current + denom > max) {
      final remaining = max - current;
      _toast(
        'ເກີນຍອດ',
        'ເຫຼືອພຽງ ${currencyFormat.format(remaining)} ກີບ ເທົ່ານັ້ນ',
      );
      return;
    }
    setState(() {
      _cashBills[denom] = (_cashBills[denom] ?? 0) + 1;
    });
  }

  void _removeBill(int denom) {
    final count = _cashBills[denom] ?? 0;
    if (count <= 0) return;
    setState(() {
      if (count == 1) {
        _cashBills.remove(denom);
      } else {
        _cashBills[denom] = count - 1;
      }
    });
  }

  // ══════════════════════════════════════════════
  // 6. 💰 banner ທອນ / ຄົບ / ຂາດ
  // ══════════════════════════════════════════════
  Widget _buildChangeBanner() {
    return Obx(() {
      if (_netTotal <= 0 || _paidAmount <= 0) {
        return const SizedBox.shrink();
      }

      // ── ທອນ ──
      if (_hasChange) {
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.shade800,
            borderRadius: BorderRadius.circular(12),
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
                  '${currencyFormat.format(_change)} ກີບ',
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
                'ຮັບມາ ${currencyFormat.format(_paidAmount)} − ຍອດ ${currencyFormat.format(_netTotal)}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        );
      }

      // ── ຄົບພໍດີ ──
      if (_paidAmount == _netTotal) {
        return Container(
          margin: const EdgeInsets.only(top: 10),
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

      // ── ຍັງຂາດ ──
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade400, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 26,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ຍັງຂາດອີກ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '${currencyFormat.format(_shortfall)} ກີບ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════
  // 7. ⚠ ຈ່າຍບໍ່ຄົບ
  // ══════════════════════════════════════════════
  Widget _buildShortfallPanel() {
    return Obx(() {
      final payType = controller.paymentType.value;
      if (_netTotal <= 0 || !_hasShortfall || _paidAmount <= 0) {
        return const SizedBox.shrink();
      }

      final isCashMode = payType == 'cash';

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
                Icon(
                  Icons.help_outline,
                  color: Colors.orange.shade900,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ເລືອກວິທີຈ່າຍສ່ວນທີ່ຂາດ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (isCashMode) ...[
              _bigChoiceButton(
                icon: Icons.account_balance,
                label: 'ໂອນເຕີມ',
                subtitle: 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍການໂອນ',
                color: Colors.blue.shade700,
                selected: _shortfallChoice == 'transfer',
                onTap: () => setState(() {
                  _shortfallChoice = _shortfallChoice == 'transfer'
                      ? null
                      : 'transfer';
                }),
              ),
              const SizedBox(height: 8),
              _bigChoiceButton(
                icon: Icons.receipt_long,
                label: 'ຕິດໜີ້',
                subtitle: 'ຄ້າງໄວ້ ຈະເກັບພາຍຫຼັງ',
                color: Colors.orange.shade800,
                selected: _shortfallChoice == 'debt',
                onTap: () => setState(() {
                  _shortfallChoice = _shortfallChoice == 'debt' ? null : 'debt';
                }),
              ),
            ] else ...[
              _bigChoiceButton(
                icon: Icons.payments,
                label: 'ສົດເຕີມ',
                subtitle: 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍເງິນສົດ',
                color: Colors.green.shade700,
                selected: _shortfallChoice == 'cash',
                onTap: () => setState(() {
                  _shortfallChoice = _shortfallChoice == 'cash' ? null : 'cash';
                }),
              ),
              const SizedBox(height: 8),
              _bigChoiceButton(
                icon: Icons.receipt_long,
                label: 'ຕິດໜີ້',
                subtitle: 'ຄ້າງໄວ້ ຈະເກັບພາຍຫຼັງ',
                color: Colors.orange.shade800,
                selected: _shortfallChoice == 'debt',
                onTap: () => setState(() {
                  _shortfallChoice = _shortfallChoice == 'debt' ? null : 'debt';
                }),
              ),
            ],

            if (_shortfallChoice == 'transfer') ...[
              const SizedBox(height: 12),
              _subImagePicker(
                title: 'ແນບຮູບສະລິບໂອນເຕີມ *',
                file: _topUpTransferSlip,
                icon: Icons.receipt_long_outlined,
                onPick: () =>
                    _pickImage(false, isTopUp: true, isTopUpSlip: true),
                onRemove: () => setState(() => _topUpTransferSlip = null),
              ),
            ] else if (_shortfallChoice == 'cash') ...[
              const SizedBox(height: 12),
              _subImagePicker(
                title: 'ແນບຮູບເງິນສົດທີ່ເຕີມ *',
                file: _topUpCashImage,
                icon: Icons.payments_outlined,
                onPick: () => _pickImage(false, isTopUp: true),
                onRemove: () => setState(() => _topUpCashImage = null),
              ),
            ] else if (_shortfallChoice == 'debt') ...[
              const SizedBox(height: 12),
              const Divider(),
              const Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.brown, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'ຂໍ້ມູນລູກຄ້າຕິດໜີ້:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'ຊື່ລູກຄ້າ *',
                  isDense: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'ເບີໂທ *',
                  isDense: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customerAddressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ທີ່ຢູ່ *',
                  isDense: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: debtNoteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ໝາຍເຫດ (ຖ້າມີ)',
                  isDense: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _bigChoiceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : color,
                size: 24,
              ),
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
                      color: selected ? Colors.white : color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 26)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _subImagePicker({
    required String title,
    required File? file,
    required IconData icon,
    required VoidCallback onPick,
    required VoidCallback onRemove,
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
        const SizedBox(height: 6),
        InkWell(
          onTap: file == null ? onPick : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: file == null ? Colors.grey.shade300 : Colors.green,
                width: file == null ? 1 : 2,
              ),
            ),
            child: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 28, color: Colors.brown),
                      const SizedBox(height: 4),
                      const Text(
                        'ແນບຮູບ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 8. 📊 ສະຫຼຸບລາຄາ
  // ══════════════════════════════════════════════
  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ລາຄາລວມ ($_quantity ຊິ້ນ)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${currencyFormat.format(_grossTotal)} ກີບ',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          if (_discountPerUnit > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ສ່ວນລົດ ($_quantity × ${currencyFormat.format(_discountPerUnit)})',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
                Text(
                  '-${currencyFormat.format(_discountTotal)} ກີບ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ຍອດຂາຍລວມ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${currencyFormat.format(_netTotal)} ກີບ',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 9. 🔘 ປຸ່ມ (ບໍ່ລອຍ)
  // ══════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _clearForm,
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _saveSale,
            icon: const Icon(Icons.save),
            label: const Text(
              'ບັນທຶກ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Save ----------
  Future<String?> _uploadOne(File? file, String folder, String label) async {
    if (file == null) return null;
    try {
      final String? url = await CloudinaryService.uploadImage(
        file,
        folder: folder,
      ).timeout(const Duration(seconds: 60));
      if (url == null || url.isEmpty) {
        throw Exception('ອັບໂຫຼດ$labelບໍ່ສຳເລັດ');
      }
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveSale() async {
    FocusScope.of(context).unfocus();

    if (controller.selectedProduct.value == null) {
      _toast('ເຕືອນ', 'ກະລຸນາເລືອກໄມ້ທີ່ຂາຍກ່ອນ');
      return;
    }
    if (_quantity < 1) {
      _toast('ເຕືອນ', 'ກະລຸນາໃສ່ຈຳນວນຢ່າງໜ້ອຍ 1');
      return;
    }

    final finalTotal = _netTotal;
    if (finalTotal <= 0) {
      _toast('ເຕືອນ', 'ຍອດຕ້ອງຊຳລະຕ້ອງຫຼາຍກວ່າ 0');
      return;
    }

    if (_paidAmount <= 0) {
      _toast('ເຕືອນ', 'ກະລຸນາປ້ອນຈຳນວນທີ່ລູກຄ້າຈ່າຍມາ');
      return;
    }

    final isCash = _isCash;
    double cashPaid = 0;
    double transferPaid = 0;
    double debtAmount = 0;
    String finalPaymentType = controller.paymentType.value;

    if (isCash) {
      cashPaid = _paidAmount > finalTotal ? finalTotal : _paidAmount;
    } else {
      transferPaid = _paidAmount > finalTotal ? finalTotal : _paidAmount;
    }

    if (_hasShortfall) {
      if (_shortfallChoice == null) {
        _toast('ເຕືອນ', 'ຍອດບໍ່ຄົບ ກະລຸນາເລືອກວິທີຈ່າຍສ່ວນທີ່ຂາດ');
        return;
      }

      if (_shortfallChoice == 'transfer') {
        if (_topUpTransferSlip == null) {
          _toast('ເຕືອນ', 'ກະລຸນາແນບຮູບສະລິບໂອນເຕີມ');
          return;
        }
        transferPaid += _shortfall;
        finalPaymentType = 'mixed';
      } else if (_shortfallChoice == 'cash') {
        if (_topUpCashImage == null) {
          _toast('ເຕືອນ', 'ກະລຸນາແນບຮູບເງິນສົດທີ່ເຕີມ');
          return;
        }
        cashPaid += _shortfall;
        finalPaymentType = 'mixed';
      } else if (_shortfallChoice == 'debt') {
        if (customerNameController.text.trim().isEmpty ||
            customerPhoneController.text.trim().isEmpty ||
            customerAddressController.text.trim().isEmpty) {
          _toast('ເຕືອນ', 'ກະລຸນາປ້ອນຊື່, ເບີໂທ ແລະ ທີ່ຢູ່ລູກຄ້າ');
          return;
        }
        debtAmount = _shortfall;
      }
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.brown)),
      barrierDismissible: false,
    );

    try {
      final results = await Future.wait<String?>([
        _uploadOne(
          _paymentImage,
          'sales/payments',
          isCash ? 'ຮູບເງິນສົດ' : 'ຮູບສະລິບ',
        ),
        _uploadOne(_billImage, 'sales/bills', 'ຮູບໃບບິນ'),
        _uploadOne(_topUpTransferSlip, 'sales/topup_transfer', 'ສະລິບເຕີມ'),
        _uploadOne(_topUpCashImage, 'sales/topup_cash', 'ຮູບສົດເຕີມ'),
      ]);
      final paymentUrl = results[0];
      final billUrl = results[1];
      final topUpSlipUrl = results[2];
      final topUpCashUrl = results[3];

      final topUpUrls = <String>[
        if (topUpSlipUrl != null) topUpSlipUrl,
        if (topUpCashUrl != null) topUpCashUrl,
      ];

      // 📝 ບັນທຶກໃບ — ສະເພາະຕອນນັບ
      Map<int, int>? cashDetails;
      if (isCash && _cashBills.isNotEmpty) {
        cashDetails = Map<int, int>.from(_cashBills);
      }

      final newSale = SaleEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: controller.selectedProduct.value!.id,
        productName: controller.selectedProduct.value!.name,
        paymentType: finalPaymentType,
        totalAmount: finalTotal,
        quantity: _quantity,
        discountPerUnit: _discountPerUnit,
        cashPaidAmount: cashPaid,
        transferPaidAmount: transferPaid,
        debtAmount: debtAmount,
        receivedAmount: _paidAmount,
        paymentImageUrls: paymentUrl != null ? [paymentUrl] : const [],
        billImageUrls: billUrl != null ? [billUrl] : const [],
        topUpImageUrls: topUpUrls,
        customerName: debtAmount > 0
            ? customerNameController.text.trim()
            : null,
        customerAddress: debtAmount > 0
            ? customerAddressController.text.trim()
            : null,
        customerPhone: debtAmount > 0
            ? customerPhoneController.text.trim()
            : null,
        debtDate: debtAmount > 0 ? DateTime.now() : null,
        debtNote: debtAmount > 0 && debtNoteController.text.trim().isNotEmpty
            ? debtNoteController.text.trim()
            : null,
        note: noteController.text.trim(),
        date: DateTime.now(),
        isConfirmed: false,
        cashDenominations: cashDetails,
      );

      await controller.repository.addSale(newSale);
      controller.fetchSales();

      Get.back();
      Get.back();

      _toast('ສຳເລັດ', 'ບັນທຶກການຂາຍຮຽບຮ້ອຍແລ້ວ');
    } catch (e) {
      Get.back();
      Get.dialog(
        AlertDialog(
          title: const Text('ບັນທຶກບໍ່ສຳເລັດ'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'ຕົກລົງ',
                style: TextStyle(color: Colors.brown),
              ),
            ),
          ],
        ),
      );
    }
  }
}
