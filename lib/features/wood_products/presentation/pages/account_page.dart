import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/account_transaction.dart';
import '../controllers/account_controller.dart';

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final f = NumberFormat('#,###').format(n);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountController controller;
  final fmt = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    controller = Get.find<AccountController>();
  }

  // ══════════════════════════════════════════════
  // 🆕 Helper ວັນອາທິດ
  // ══════════════════════════════════════════════
  String _dayName(DateTime d) {
    const days = [
      'ວັນຈັນ',
      'ວັນອັງຄານ',
      'ວັນພຸດ',
      'ວັນພະຫັດ',
      'ວັນສຸກ',
      'ວັນເສົາ',
      'ວັນອາທິດ',
    ];
    return days[d.weekday - 1];
  }

  String _dateShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Column(
        children: [
          _buildBalanceBanner(),
          _buildActionButtons(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                );
              }
              final groups = controller.sessionGroups;
              if (groups.isEmpty) {
                return const Center(
                  child: Text('ບໍ່ມີລາຍການ',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: 100, left: 12, right: 12, top: 6),
                itemCount: groups.length,
                itemBuilder: (_, i) => _sessionSection(groups[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 💰 ຍອດຄົງເຫຼືອ
  // ══════════════════════════════════════════════
  Widget _buildBalanceBanner() {
    return Obx(() {
      final bal = controller.balance;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade800, Colors.brown.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text('ຍອດຄົງເຫຼືອທັງໝົດ',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${fmt.format(bal)} ກີບ',
                style: TextStyle(
                  color: bal < 0 ? Colors.red.shade200 : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _balTile(
                    icon: Icons.payments_outlined,
                    label: 'ສົດ',
                    value: controller.cashBalance,
                    color: Colors.amber.shade200,
                  ),
                ),
                Container(width: 1, height: 26, color: Colors.white24),
                Expanded(
                  child: _balTile(
                    icon: Icons.account_balance,
                    label: 'ໂອນ',
                    value: controller.transferBalance,
                    color: Colors.lightBlue.shade200,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _balTile({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${fmt.format(value)} ກີບ',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 2 ປຸ່ມ: ຮັບເງິນ / ຈ່າຍເງິນ
  // ══════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _bigBtn(
              icon: Icons.arrow_downward,
              title: 'ຮັບເງິນ',
              subtitle: 'ເງິນເຂົ້າ',
              color: Colors.green.shade700,
              onTap: () => _openFormSheet(initialType: 'in'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _bigBtn(
              icon: Icons.arrow_upward,
              title: 'ຈ່າຍເງິນ',
              subtitle: 'ເບີກໄປໃຊ້',
              color: Colors.red.shade700,
              onTap: () => _openFormSheet(initialType: 'out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigBtn({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 📅 ກາດ ວັນ + session — ວັນອາທິດເດັ່ນ
  // ══════════════════════════════════════════════
  Widget _sessionSection(SessionGroup g) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.brown[100],
          elevation: 1,
          margin: const EdgeInsets.only(top: 12, bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    // ✅ ກາດ ວັນອາທິດ — ເດັ່ນ ສີນ້ຳຕານ ຕົວໜາ
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade800,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dayName(g.date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _dateShort(g.date),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ✅ ກາງ — session
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(g.icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                g.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ເວລາ ${g.range}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.brown.shade600),
                          ),
                        ],
                      ),
                    ),

                    // ✅ ຈຳນວນລາຍການ
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.brown[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${g.transactions.length} ລາຍການ',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _sessionStat(
                        icon: Icons.arrow_downward,
                        label: 'ຮັບ',
                        value: g.income,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Expanded(
                      child: _sessionStat(
                        icon: Icons.arrow_upward,
                        label: 'ຈ່າຍ',
                        value: g.expense,
                        color: Colors.red.shade700,
                      ),
                    ),
                    Expanded(
                      child: _sessionStat(
                        icon: Icons.savings_outlined,
                        label: 'ຄົງເຫຼືອ',
                        value: g.endingBalance,
                        color: Colors.brown.shade800,
                        bold: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ...g.transactions.map(_transactionCard),
      ],
    );
  }

  Widget _sessionStat({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    bool bold = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 2),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            fmt.format(value),
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 📝 ກາດລາຍການ
  // ══════════════════════════════════════════════
  Widget _transactionCard(AccountTransaction t) {
    final isIn = t.isIncome;
    final color = isIn ? Colors.green.shade700 : Colors.red.shade700;
    final bgColor = isIn ? Colors.green.shade50 : Colors.red.shade50;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Icon(
                isIn ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...t.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isIn
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!isIn)
                              Text(
                                '${fmt.format(item.price)} ກີບ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700),
                              ),
                          ],
                        ),
                      )),
                  if (t.items.length > 1 && !isIn)
                    const Divider(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: t.isCash
                              ? Colors.amber.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              t.isCash
                                  ? Icons.payments_outlined
                                  : Icons.account_balance,
                              size: 9,
                              color: t.isCash
                                  ? Colors.amber.shade900
                                  : Colors.blue.shade900,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              t.isCash ? 'ສົດ' : 'ໂອນ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: t.isCash
                                    ? Colors.amber.shade900
                                    : Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.access_time,
                          size: 11, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Text(
                        controller.formatTime(t.date),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIn ? '+' : '-'}${fmt.format(t.totalAmount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const Text('ກີບ',
                    style: TextStyle(fontSize: 9, color: Colors.grey)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _deleteDialog(t),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Icon(Icons.delete_outline,
                        size: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 ເປີດຟອມ
  // ══════════════════════════════════════════════
  void _openFormSheet({required String initialType}) {
    Get.bottomSheet(
      _AccountFormSheet(
        initialType: initialType,
        onSubmit: controller.addTransaction,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ══════════════════════════════════════════════
  // 🗑 ລຶບ
  // ══════════════════════════════════════════════
  void _deleteDialog(AccountTransaction t) {
    final itemNames = t.items.map((i) => i.name).join(', ');
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      middleText:
          'ລຶບ "${itemNames.isNotEmpty ? itemNames : "ລາຍການ"}" ${fmt.format(t.totalAmount)} ກີບ?',
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteTransaction(t.id);
      },
    );
  }
}

// ══════════════════════════════════════════════
// 🎯 ຟອມ — StatefulWidget ແຍກຕ່າງຫາກ
// ══════════════════════════════════════════════
class _AccountFormSheet extends StatefulWidget {
  final String initialType;
  final Future<void> Function(AccountTransaction) onSubmit;

  const _AccountFormSheet({
    required this.initialType,
    required this.onSubmit,
  });

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  final fmt = NumberFormat('#,###');

  late String type;
  String payType = 'cash';

  final receiveAmountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  late List<Map<String, TextEditingController>> payRows;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    payRows = [
      {
        'name': TextEditingController(),
        'price': TextEditingController(),
      },
    ];
  }

  @override
  void dispose() {
    receiveAmountCtrl.dispose();
    noteCtrl.dispose();
    for (final r in payRows) {
      r['name']!.dispose();
      r['price']!.dispose();
    }
    super.dispose();
  }

  double get _payTotal {
    double t = 0;
    for (final r in payRows) {
      t += double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
    }
    return t;
  }

  bool get _isIn => type == 'in';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: Get.height * 0.92),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isIn
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isIn ? Icons.arrow_downward : Icons.arrow_upward,
                    color: _isIn
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isIn ? 'ຮັບເງິນ' : 'ຈ່າຍເງິນ',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _isIn
                            ? Colors.green.shade700
                            : Colors.red.shade700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Toggle
            Row(
              children: [
                Expanded(
                  child: _typeBtn(
                    label: 'ຮັບເຂົ້າ',
                    icon: Icons.arrow_downward,
                    color: Colors.green.shade700,
                    selected: _isIn,
                    onTap: () => setState(() => type = 'in'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _typeBtn(
                    label: 'ຈ່າຍອອກ',
                    icon: Icons.arrow_upward,
                    color: Colors.red.shade700,
                    selected: !_isIn,
                    onTap: () => setState(() => type = 'out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isIn)
                      _buildReceiveContent()
                    else
                      _buildPayContent(),
                    const SizedBox(height: 14),

                    const Text('ປະເພດເງິນ *',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _typeBtn(
                            label: 'ເງິນສົດ',
                            icon: Icons.payments_outlined,
                            color: Colors.amber.shade800,
                            selected: payType == 'cash',
                            onTap: () =>
                                setState(() => payType = 'cash'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _typeBtn(
                            label: 'ເງິນໂອນ',
                            icon: Icons.account_balance,
                            color: Colors.blue.shade700,
                            selected: payType == 'transfer',
                            onTap: () =>
                                setState(() => payType = 'transfer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ໝາຍເຫດ (ຖ້າມີ)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sticky_note_2_outlined,
                            color: Colors.brown),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isIn ? Colors.green.shade700 : Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _onSave,
              icon: const Icon(Icons.save),
              label: Text(
                _isIn ? 'ບັນທຶກຮັບເງິນ' : 'ບັນທຶກຈ່າຍເງິນ',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiveContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ຈຳນວນເງິນທີ່ຮັບ *',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: receiveAmountCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsFormatter(),
          ],
          style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: '0',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers, color: Colors.brown),
            suffixText: 'ກີບ',
          ),
        ),
      ],
    );
  }

  Widget _buildPayContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ລາຍການທີ່ຈ່າຍ *',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 6),
        ...payRows.asMap().entries.map((e) {
          final idx = e.key;
          final row = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: row['name'],
                    decoration: InputDecoration(
                      labelText: 'ລາຍການ ${idx + 1}',
                      hintText: 'ຊື່ສິ່ງຂອງ...',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: row['price'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'ລາຄາ',
                      suffixText: 'ກີບ',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (payRows.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        payRows[idx]['name']!.dispose();
                        payRows[idx]['price']!.dispose();
                        payRows.removeAt(idx);
                      });
                    },
                    icon: Icon(Icons.remove_circle,
                        color: Colors.red.shade600),
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown,
            side: const BorderSide(color: Colors.brown),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: () {
            setState(() {
              payRows.add({
                'name': TextEditingController(),
                'price': TextEditingController(),
              });
            });
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('ເພີ່ມລາຍການ',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('ລວມທັງໝົດ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${fmt.format(_payTotal)} ກີບ',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeBtn({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : color, size: 18),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : color,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final items = <AccountItem>[];

    if (_isIn) {
      final amount =
          double.tryParse(receiveAmountCtrl.text.replaceAll(',', '')) ?? 0;
      if (amount <= 0) {
        Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຈຳນວນເງິນ');
        return;
      }
      items.add(AccountItem(
        name: payType == 'cash' ? 'ຮັບເງິນສົດ' : 'ຮັບເງິນໂອນ',
        price: amount,
      ));
    } else {
      for (final r in payRows) {
        final name = r['name']!.text.trim();
        final p =
            double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
        if (name.isEmpty || p <= 0) continue;
        items.add(AccountItem(name: name, price: p));
      }
      if (items.isEmpty) {
        Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຢ່າງໜ້ອຍ 1 ລາຍການ');
        return;
      }
    }

    final tx = AccountTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      paymentType: payType,
      items: items,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      date: DateTime.now(),
    );

    Get.back();
    await widget.onSubmit(tx);
  }
}