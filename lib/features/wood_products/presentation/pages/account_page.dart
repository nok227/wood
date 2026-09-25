import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/features/wood_products/presentation/widgets/animated_number.dart';
import 'package:wood/features/wood_products/presentation/widgets/skeletons.dart';

import '../../domain/entities/account_transaction.dart';
import '../controllers/account_controller.dart';
import '../../../auth/auth_controller.dart';

// ══════════════════════════════════════════════
// 🧩 Formatter
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

  String _day(DateTime d) {
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
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Column(
        children: [
          _balanceBanner(),
          _actionButtons(),
          Expanded(
            child: Obx(() {
              // ✅ Skeleton ແທນ spinner
              if (controller.isLoading.value &&
                  controller.allTransactions.isEmpty) {
                return const AccountPageSkeleton();
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
                    bottom: 100, left: 10, right: 10, top: 4),
                itemCount: groups.length,
                itemBuilder: (_, i) => _sessionSection(groups[i], isAdmin),
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
  Widget _balanceBanner() {
    return Obx(() {
      final bal = controller.balance;
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.white70, size: 13),
                SizedBox(width: 4),
                Text('ຍອດຄົງເຫຼືອ',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedNumber(
                value: bal,
                suffix: ' ກີບ',
                duration: 1200,
                style: TextStyle(
                  color: bal < 0 ? Colors.red.shade200 : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _balTile(Icons.payments_outlined, 'ສົດ',
                      controller.cashBalance, Colors.amber.shade200),
                ),
                Container(width: 1, height: 20, color: Colors.white24),
                Expanded(
                  child: _balTile(Icons.account_balance, 'ໂອນ',
                      controller.transferBalance, Colors.lightBlue.shade200),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _balTile(IconData i, String l, double v, Color c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(i, color: c, size: 11),
        const SizedBox(width: 3),
        Text(l, style: TextStyle(color: c, fontSize: 10)),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedNumber(
              value: v,
              suffix: ' ກີບ',
              duration: 1100,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 2 ປຸ່ມ
  // ══════════════════════════════════════════════
  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: Row(
        children: [
          Expanded(
            child: _bigBtn(Icons.arrow_downward, 'ຮັບເງິນ', 'ເງິນເຂົ້າ',
                Colors.green.shade700, () => _openForm('in')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _bigBtn(Icons.arrow_upward, 'ຈ່າຍເງິນ', 'ເບີກໄປໃຊ້',
                Colors.red.shade700, () => _openForm('out')),
          ),
        ],
      ),
    );
  }

  Widget _bigBtn(IconData i, String t, String s, Color c, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: c.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle),
              child: Icon(i, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(s,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 📅 Session section
  // ══════════════════════════════════════════════
  Widget _sessionSection(SessionGroup g, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.brown[100],
          elevation: 1,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade800,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_day(g.date),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                          Text(_dateShort(g.date),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(g.icon,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Text(g.label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown[900])),
                            ],
                          ),
                          Text('ເວລາ ${g.range}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.brown.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.brown[800],
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${g.transactions.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: _stat(Icons.arrow_downward, 'ຮັບ',
                            g.income, Colors.green.shade700)),
                    Expanded(
                        child: _stat(Icons.arrow_upward, 'ຈ່າຍ',
                            g.expense, Colors.red.shade700)),
                    Expanded(
                        child: _stat(Icons.savings_outlined, 'ຄົງເຫຼືອ',
                            g.endingBalance, Colors.brown.shade800,
                            bold: true)),
                  ],
                ),
              ],
            ),
          ),
        ),
        ...g.transactions.map((t) => _txCard(t, isAdmin)),
      ],
    );
  }

  Widget _stat(IconData i, String l, double v, Color c,
      {bool bold = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: c, size: 10),
            const SizedBox(width: 2),
            Text(l,
                style: TextStyle(
                    color: c, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: v,
            duration: 1100,
            style: TextStyle(
              fontSize: bold ? 12 : 11,
              fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
              color: c,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 📝 ກາດລາຍການ
  // ══════════════════════════════════════════════
  Widget _txCard(AccountTransaction t, bool isAdmin) {
    final isIn = t.isIncome;
    final c = isIn ? Colors.green.shade700 : Colors.red.shade700;
    final bg = isIn ? Colors.green.shade50 : Colors.red.shade50;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(color: c.withOpacity(0.3), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.withOpacity(0.5))),
              child: Icon(
                  isIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: c,
                  size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...t.items.map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(i.name,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isIn
                                          ? FontWeight.bold
                                          : FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (!isIn)
                              Text('${fmt.format(i.price)}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700)),
                          ],
                        ),
                      )),
                  if (t.items.length > 1 && !isIn)
                    const Divider(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: t.isCash
                              ? Colors.amber.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                t.isCash
                                    ? Icons.payments_outlined
                                    : Icons.account_balance,
                                size: 8,
                                color: t.isCash
                                    ? Colors.amber.shade900
                                    : Colors.blue.shade900),
                            const SizedBox(width: 2),
                            Text(t.isCash ? 'ສົດ' : 'ໂອນ',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: t.isCash
                                        ? Colors.amber.shade900
                                        : Colors.blue.shade900)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.access_time,
                          size: 9, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Text(controller.formatTime(t.date),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedNumber(
                  value: t.totalAmount,
                  prefix: isIn ? '+' : '-',
                  duration: 1000,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: c),
                ),
                if (isAdmin)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: const Icon(Icons.more_vert,
                          color: Colors.black54),
                      onSelected: (v) {
                        if (v == 'delete') _deleteDialog(t);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('ລຶບ',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(String type) {
    Get.bottomSheet(
      _FormSheet(initialType: type, onSubmit: controller.addTransaction),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _deleteDialog(AccountTransaction t) {
    if (Get.isDialogOpen ?? false) return;
    final names = t.items.map((i) => i.name).join(', ');
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      middleText:
          'ລຶບ "${names.isNotEmpty ? names : "ລາຍການ"}" ${fmt.format(t.totalAmount)} ກີບ?',
      textConfirm: 'ລຶບ',
      textCancel: 'ຍົກເລີກ',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 200));
        await controller.deleteTransaction(t.id);
      },
    );
  }
}

// ══════════════════════════════════════════════
// 🎯 ຟອມ
// ══════════════════════════════════════════════
class _FormSheet extends StatefulWidget {
  final String initialType;
  final Future<void> Function(AccountTransaction) onSubmit;

  const _FormSheet({required this.initialType, required this.onSubmit});

  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  final fmt = NumberFormat('#,###');

  late String type;
  String payType = 'cash';

  final recvC = TextEditingController();
  final noteC = TextEditingController();
  late List<Map<String, TextEditingController>> rows;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    rows = [
      {'name': TextEditingController(), 'price': TextEditingController()},
    ];
  }

  @override
  void dispose() {
    recvC.dispose();
    noteC.dispose();
    for (final r in rows) {
      r['name']!.dispose();
      r['price']!.dispose();
    }
    super.dispose();
  }

  double get _payTotal {
    double t = 0;
    for (final r in rows) {
      t += double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
    }
    return t;
  }

  bool get _isIn => type == 'in';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      constraints: BoxConstraints(maxHeight: Get.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
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
                      size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_isIn ? 'ຮັບເງິນ' : 'ຈ່າຍເງິນ',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isIn
                              ? Colors.green.shade700
                              : Colors.red.shade700)),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                    child: _tBtn('ຮັບເຂົ້າ', Icons.arrow_downward,
                        Colors.green.shade700, _isIn,
                        () => setState(() => type = 'in'))),
                const SizedBox(width: 6),
                Expanded(
                    child: _tBtn('ຈ່າຍອອກ', Icons.arrow_upward,
                        Colors.red.shade700, !_isIn,
                        () => setState(() => type = 'out'))),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isIn) _recvContent() else _payContent(),
                    const SizedBox(height: 10),
                    const Text('ປະເພດເງິນ *',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                            child: _tBtn('ເງິນສົດ',
                                Icons.payments_outlined,
                                Colors.amber.shade800,
                                payType == 'cash',
                                () => setState(() => payType = 'cash'))),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _tBtn('ເງິນໂອນ',
                                Icons.account_balance,
                                Colors.blue.shade700,
                                payType == 'transfer',
                                () => setState(() => payType = 'transfer'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteC,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ໝາຍເຫດ (ຖ້າມີ)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.sticky_note_2_outlined,
                            color: Colors.brown, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isIn ? Colors.green.shade700 : Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _onSave,
              icon: const Icon(Icons.save, size: 20),
              label: Text(_isIn ? 'ບັນທຶກຮັບເງິນ' : 'ບັນທຶກຈ່າຍເງິນ',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recvContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ຈຳນວນເງິນທີ່ຮັບ *',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 4),
        TextField(
          controller: recvC,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _NumFmt(),
          ],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _payContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('ລາຍການທີ່ຈ່າຍ *',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 4),
        ...rows.asMap().entries.map((e) {
          final idx = e.key;
          final r = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: r['name'],
                    decoration: InputDecoration(
                      labelText: 'ລາຍການ ${idx + 1}',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: r['price'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _NumFmt(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'ລາຄາ',
                      suffixText: 'ກີບ',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (rows.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        r['name']!.dispose();
                        r['price']!.dispose();
                        rows.removeAt(idx);
                      });
                    },
                    icon: Icon(Icons.remove_circle,
                        color: Colors.red.shade600, size: 20),
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown,
            side: const BorderSide(color: Colors.brown),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => setState(() {
            rows.add({
              'name': TextEditingController(),
              'price': TextEditingController()
            });
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('ເພີ່ມລາຍການ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize, color: Colors.red, size: 16),
              const SizedBox(width: 5),
              const Expanded(
                child: Text('ລວມທັງໝົດ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${fmt.format(_payTotal)} ກີບ',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tBtn(String l, IconData i, Color c, bool sel, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: sel ? c : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? c : Colors.grey.shade300,
              width: sel ? 2 : 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: sel ? Colors.white : c, size: 16),
            const SizedBox(width: 4),
            Text(l,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: sel ? Colors.white : c)),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final items = <AccountItem>[];

    if (_isIn) {
      final amount =
          double.tryParse(recvC.text.replaceAll(',', '')) ?? 0;
      if (amount <= 0) {
        Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຈຳນວນເງິນ');
        return;
      }
      items.add(AccountItem(
        name: payType == 'cash' ? 'ຮັບເງິນສົດ' : 'ຮັບເງິນໂອນ',
        price: amount,
      ));
    } else {
      for (final r in rows) {
        final n = r['name']!.text.trim();
        final p = double.tryParse(r['price']!.text.replaceAll(',', '')) ?? 0;
        if (n.isEmpty || p <= 0) continue;
        items.add(AccountItem(name: n, price: p));
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
      note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
      date: DateTime.now(),
    );

    Get.back();
    await widget.onSubmit(tx);
  }
}