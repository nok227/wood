import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/animated_number.dart';
import '../widgets/skeletons.dart';

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

  /// true = ສະແດງ appbar ສະຫຼຸບ (ຍອດລວມ/ເງິນສົດ/ເງິນໂອນ/ລາຍຮັບ/ລາຍຈ່າຍ)
  /// false = ເຊື່ອງ (ເມື່ອເລື່ອນລາຍການຂຶ້ນ). Shell ຟັງຄ່ານີ້ເພື່ອເຊື່ອງ/ສະແດງ appbar.
  static final ValueNotifier<bool> headerVisible = ValueNotifier<bool>(true);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountController controller;
  final fmt = NumberFormat('#,###');

  // ✅ ScrollController ແທນ NotificationListener ເກົ່າ
  final ScrollController _scrollController = ScrollController();
  double _lastOffset = 0;

  // ✅ ຕົວບອກວ່າ banner + ປຸ່ມ ຄວນສະແດງ ຫຼື ບໍ່
  final ValueNotifier<bool> _bannerVisible = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AccountController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bannerVisible.dispose();

    // ຄືນຄ່າ appbar ໃຫ້ສະແດງ ເມື່ອອອກຈາກໜ້ານີ້
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccountPage.headerVisible.value = true;
    });
    super.dispose();
  }

  // ══════════════════════════════════════════════
  // ✅ Scroll listener — ເຊື່ອງ/ສະແດງ banner + ປຸ່ມ
  //    ເລື່ອນລົງ (swipe ຂຶ້ນ) → ເຊື່ອງ
  //    ເລື່ອນຂຶ້ນ (swipe ລົງ) → ສະແດງ
  // ══════════════════════════════════════════════
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final delta = offset - _lastOffset;
    _lastOffset = offset;

    // ຢູ່ເທິງສຸດ → ສະແດງສະເໝີ
    if (offset < 20) {
      if (!_bannerVisible.value) _bannerVisible.value = true;
      return;
    }

    // ເລື່ອນລົງ → ເຊື່ອງ
    if (delta > 5 && _bannerVisible.value) {
      _bannerVisible.value = false;
    }
    // ເລື່ອນຂຶ້ນ → ສະແດງ
    else if (delta < -5 && !_bannerVisible.value) {
      _bannerVisible.value = true;
    }
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
      backgroundColor: const Color(0xFFF5F0EA),
      body: Column(
        children: [
          // ══════════════════════════════════════════════
          // ✅ Banner + ປຸ່ມ ຮັບ/ຈ່າຍ ເງິນ
          //    ເຊື່ອງ/ສະແດງໄດ້ຕາມການເລື່ອນພ້ອມກັນ
          // ══════════════════════════════════════════════
          ValueListenableBuilder<bool>(
            valueListenable: _bannerVisible,
            builder: (context, visible, child) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: visible ? 1 : 0,
                  child: visible
                      ? child
                      : const SizedBox(width: double.infinity),
                ),
              );
            },
            // ✅ ໃສ່ທັງ banner + ປຸ່ມ ເຂົ້າ Column ດຽວກັນ
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _balanceBanner(),
                _actionButtons(),
              ],
            ),
          ),

          // ══════════════════════════════════════════════
          // ✅ ລາຍການ — ໃຊ້ _scrollController
          // ══════════════════════════════════════════════
          Expanded(
            child: Obx(() {
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
                controller: _scrollController,   // ✅ ຜູກ controller
                padding: const EdgeInsets.only(
                    bottom: 100, left: 12, right: 12, top: 4),
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
  // 💰 ຍອດຄົງເຫຼືອ — Hero card
  // ══════════════════════════════════════════════
  Widget _balanceBanner() {
    return Obx(() {
      final bal = controller.balance;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade700, Colors.brown.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.white70, size: 12),
                SizedBox(width: 4),
                Text('ຍອດຄົງເຫຼືອ',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── ສົດ / ໂອນ ──
            Row(
              children: [
                Expanded(
                  child: _balTile(
                    Icons.payments_outlined,
                    'ສົດ',
                    controller.cashBalance,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _balTile(
                    Icons.account_balance,
                    'ໂອນ',
                    controller.transferBalance,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _balTile(IconData i, String l, double v) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: Colors.white70, size: 11),
            const SizedBox(width: 3),
            Text(l,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: v,
            suffix: ' ກີບ',
            duration: 1100,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 2 ປຸ່ມ — ບາງໆ ໃຊ້ gradient
  // ══════════════════════════════════════════════
  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _bigBtn(
              Icons.arrow_downward_rounded,
              'ຮັບເງິນ',
              'ເງິນເຂົ້າ',
              Colors.green.shade600,
              Colors.green.shade700,
              () => _openForm('in'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _bigBtn(
              Icons.arrow_upward_rounded,
              'ຈ່າຍເງິນ',
              'ເບີກໄປໃຊ້',
              Colors.red.shade600,
              Colors.red.shade700,
              () => _openForm('out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigBtn(
    IconData i,
    String t,
    String s,
    Color c1,
    Color c2,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c1, c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: c2.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(i, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2)),
                    const SizedBox(height: 1),
                    Text(s,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 📅 Session section — ສະອາດ
  // ══════════════════════════════════════════════
  Widget _sessionSection(SessionGroup g, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13, color: Colors.brown.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_day(g.date)}, ${_dateShort(g.date)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.brown.shade800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // ── Session badge ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(g.icon,
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(g.label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.brown.shade800)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${g.transactions.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade500,
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Text('ເວລາ ${g.range}',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          _dashedDivider(),

          // ── Stats row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                Expanded(
                    child: _stat(
                        Icons.arrow_downward_rounded,
                        'ຮັບ',
                        g.income,
                        Colors.green.shade700)),
                Expanded(
                    child: _stat(
                        Icons.arrow_upward_rounded,
                        'ຈ່າຍ',
                        g.expense,
                        Colors.red.shade700)),
                Expanded(
                    child: _stat(
                        Icons.savings_outlined,
                        'ຄົງເຫຼືອ',
                        g.endingBalance,
                        Colors.brown.shade800,
                        bold: true)),
              ],
            ),
          ),

          _dashedDivider(),

          // ── Transactions ──
          ...g.transactions.map((t) => _txTile(t, isAdmin, g)),
        ],
      ),
    );
  }

  // ── Dashed divider ──
  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
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

  Widget _stat(IconData i, String l, double v, Color c,
      {bool bold = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: c, size: 11),
            const SizedBox(width: 3),
            Text(l,
                style: TextStyle(
                    color: c,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2)),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(
            value: v,
            duration: 1100,
            style: TextStyle(
              fontSize: bold ? 13 : 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
              color: c,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 📝 Transaction tile — ບໍ່ມີ border ໃຊ້ເສັ້ນປະ
  // ══════════════════════════════════════════════
  Widget _txTile(AccountTransaction t, bool isAdmin, SessionGroup g) {
    final isIn = t.isIncome;
    final c = isIn ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      children: [
        // ── Dashed separator (ບໍ່ມີຢູ່ອັນທຳອິດ) ──
        if (t.id != g.transactions.first.id) _dashedDivider(),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIn
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: c,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Items ──
                    ...t.items.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  i.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isIn
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isIn)
                                Text(
                                  '${fmt.format(i.price)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 4),

                    // ── Meta row (ສົດ/ໂອນ + ເວລາ) ──
                    Row(
                      children: [
                        Icon(
                          t.isCash
                              ? Icons.payments_outlined
                              : Icons.account_balance,
                          size: 11,
                          color: t.isCash
                              ? Colors.amber.shade800
                              : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          t.isCash ? 'ສົດ' : 'ໂອນ',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: t.isCash
                                ? Colors.amber.shade800
                                : Colors.blue.shade700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time,
                            size: 10, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          controller.formatTime(t.date),
                          style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600),
                        ),
                        if ((t.note ?? '').trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '· ${t.note}',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Amount + menu ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedNumber(
                    value: t.totalAmount,
                    prefix: isIn ? '+' : '-',
                    duration: 1000,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: c,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (isAdmin)
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(Icons.more_vert,
                            color: Colors.grey.shade400, size: 16),
                        onSelected: (v) {
                          if (v == 'delete') _deleteDialog(t);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    color: Color(0xFFB71C1C), size: 18),
                                SizedBox(width: 8),
                                Text('ລຶບ',
                                    style: TextStyle(
                                        color: Color(0xFFB71C1C),
                                        fontWeight: FontWeight.w700,
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
      ],
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
// 🎯 ຟອມ — ສະອາດ
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
      padding: const EdgeInsets.all(16),
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
            // ── Handle ──
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header ──
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
                    _isIn
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
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
                      fontWeight: FontWeight.w900,
                      color: _isIn
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.grey.shade600, size: 22),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Type toggle ──
            Row(
              children: [
                Expanded(
                    child: _tBtn('ຮັບເຂົ້າ', Icons.arrow_downward_rounded,
                        Colors.green.shade700, _isIn,
                        () => setState(() => type = 'in'))),
                const SizedBox(width: 8),
                Expanded(
                    child: _tBtn('ຈ່າຍອອກ', Icons.arrow_upward_rounded,
                        Colors.red.shade700, !_isIn,
                        () => setState(() => type = 'out'))),
              ],
            ),
            const SizedBox(height: 14),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isIn) _recvContent() else _payContent(),
                    const SizedBox(height: 14),

                    const Text('ປະເພດເງິນ *',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _tBtn('ເງິນສົດ',
                                Icons.payments_outlined,
                                Colors.amber.shade800,
                                payType == 'cash',
                                () => setState(() => payType = 'cash'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _tBtn('ເງິນໂອນ',
                                Icons.account_balance,
                                Colors.blue.shade700,
                                payType == 'transfer',
                                () => setState(() => payType = 'transfer'))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: noteC,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'ໝາຍເຫດ (ຖ້າມີ)',
                        labelStyle: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.brown.shade400, width: 1.5),
                        ),
                        isDense: true,
                        prefixIcon: Icon(Icons.sticky_note_2_outlined,
                            color: Colors.brown.shade400, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ── Save button ──
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIn
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: Text(
                    _isIn ? 'ບັນທຶກຮັບເງິນ' : 'ບັນທຶກຈ່າຍເງິນ',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900)),
              ),
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
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: recvC,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _NumFmt(),
          ],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.green.shade400, width: 2),
            ),
            prefixIcon:
                Icon(Icons.numbers, color: Colors.green.shade600),
            suffixText: 'ກີບ',
            suffixStyle: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade600),
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
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        ...rows.asMap().entries.map((e) {
          final idx = e.key;
          final r = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: r['name'],
                    decoration: InputDecoration(
                      labelText: 'ລາຍການ ${idx + 1}',
                      labelStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: r['price'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _NumFmt(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'ລາຄາ',
                      labelStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                      suffixText: 'ກີບ',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
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
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.red.shade600, size: 22),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown.shade700,
            side: BorderSide(color: Colors.brown.shade300),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => setState(() {
            rows.add({
              'name': TextEditingController(),
              'price': TextEditingController()
            });
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('ເພີ່ມລາຍການ',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        const SizedBox(height: 10),

        // ── Total (ແບບບາງໆ ໃຊ້ພື້ນສີອ່ອນ) ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.summarize_outlined,
                  color: Colors.red.shade700, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text('ລວມທັງໝົດ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade700)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${fmt.format(_payTotal)} ກີບ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade700,
                        letterSpacing: 0.2)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tBtn(String l, IconData i, Color c, bool sel, VoidCallback tap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? c : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? c : Colors.grey.shade300,
              width: sel ? 0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: sel ? Colors.white : c, size: 16),
              const SizedBox(width: 5),
              Text(l,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : c,
                      letterSpacing: 0.2)),
            ],
          ),
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