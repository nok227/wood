import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/entities/sale_order_entity.dart';
import '../controllers/sales_controller.dart';
import '../widgets/sale_card.dart';
import '../widgets/sales_list_skeleton.dart';
import 'add_payment_page.dart';
import 'sales_summary_page.dart';
import '../../../auth/auth_controller.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage>
    with AutomaticKeepAliveClientMixin {
  bool _isFabOpen = false;

  final ScrollController _scroll = ScrollController();
  static const int _perPage = 10;
  int _displayLimit = _perPage;
  bool _isLoadingMore = false;

  int _cachedRevision = -1;
  DateFilter? _cachedFilter;
  Map<String, List<SaleOrderEntity>> _cachedGroup = const {};
  List<String> _cachedKeys = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _displayLimit += _perPage;
      _isLoadingMore = false;
    });
  }

  Map<String, List<SaleOrderEntity>> _groupCached(
    List<SaleOrderEntity> source,
    DateFilter filter,
    int revision,
  ) {
    if (_cachedRevision == revision && _cachedFilter == filter) {
      return _cachedGroup;
    }
    _cachedRevision = revision;
    _cachedFilter = filter;

    final map = <String, List<SaleOrderEntity>>{};
    for (final sale in source) {
      final d = sale.date;
      final k =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(k, () => []).add(sale);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    _cachedGroup = {for (final k in keys) k: map[k]!};
    _cachedKeys = keys;
    return _cachedGroup;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    const days = [
      'ວັນອາທິດ',
      'ວັນຈັນ',
      'ວັນອັງຄານ',
      'ວັນພຸດ',
      'ວັນພະຫັດ',
      'ວັນສຸກ',
      'ວັນເສົາ',
    ];
    final dayName = days[date.weekday % 7];
    final fmtDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (target == today) return 'ມື້ນີ້ ($dayName, $fmtDate)';
    if (target == yesterday) return 'ມື້ວານນີ້ ($dayName, $fmtDate)';
    return '$dayName, $fmtDate';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<SalesController>();
    final isAdminUser = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: Stack(
        children: [
          Column(
            children: [
              // ══════════════════════════════════════════
              // 🔘 Filter chips
              // ══════════════════════════════════════════
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(
                    () => Row(
                      children: [
                        _filterChip(controller, 'ທັງໝົດ', DateFilter.all),
                        _filterChip(controller, 'ມື້ນີ້', DateFilter.today),
                        _filterChip(controller, 'ອາທິດນີ້', DateFilter.week),
                        _filterChip(controller, 'ເດືອນນີ້', DateFilter.month),
                        _filterChip(controller, 'ປີນີ້', DateFilter.year),
                      ],
                    ),
                  ),
                ),
              ),

              // ══════════════════════════════════════════
              // 📋 List
              // ══════════════════════════════════════════
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.allSalesList.isEmpty) {
                    return const SalesListSkeleton(count: 5);
                  }

                  final rev = controller.salesRevision.value;
                  final sales = controller.filteredSalesList;

                  if (sales.isEmpty) {
                    return RefreshIndicator(
                      color: Colors.brown,
                      onRefresh: () async {
                        setState(() => _displayLimit = _perPage);
                        await controller.fetchSales();
                      },
                      child: ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text('ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້'),
                          ),
                        ],
                      ),
                    );
                  }

                  final grouped = _groupCached(
                    sales,
                    controller.selectedFilter.value,
                    rev,
                  );
                  final groupKeys = _cachedKeys;
                  final displayKeys = groupKeys.take(_displayLimit).toList();
                  final hasMore = groupKeys.length > displayKeys.length;

                  return RefreshIndicator(
                    color: Colors.brown,
                    onRefresh: () async {
                      setState(() => _displayLimit = _perPage);
                      await controller.fetchSales();
                    },
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.only(
                        bottom: 200, // ✅ ເພີ່ມໃຫ້ FAB ບໍ່ທັບ card
                        left: 12,
                        right: 12,
                      ),
                      itemCount: displayKeys.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayKeys.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.brown,
                              ),
                            ),
                          );
                        }

                        final dateKey = displayKeys[index];
                        final salesInGroup = grouped[dateKey]!;
                        final headerTitle = _formatDateHeader(
                          salesInGroup.first.date,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Date header ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  4, 10, 4, 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 13,
                                    color: Colors.brown.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      headerTitle,
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
                                  Text(
                                    '${salesInGroup.length} ອໍເດີ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Sale cards ──
                            ...salesInGroup.map(
                              (sale) => RepaintBoundary(
                                key: ValueKey('rb-${sale.id}'),
                                child: SaleCard(
                                  key: ValueKey('sale-${sale.id}'),
                                  sale: sale,
                                  isAdmin: isAdminUser,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // ══════════════════════════════════════════
          // 🌫️ Backdrop
          // ══════════════════════════════════════════
          _FabBackdrop(
            visible: _isFabOpen,
            onTap: () => setState(() => _isFabOpen = false),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFabGroup(),
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 FAB Group — ອອກແບບໃໝ່: ເປັນປຸ່ມຂະໜາດກາງ ສີເຂັ້ມ
  // ══════════════════════════════════════════════
  Widget _buildFabGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Action buttons ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                ),
                alignment: Alignment.bottomRight,
                child: child,
              ),
            );
          },
          child: _isFabOpen
              ? Column(
                  key: const ValueKey('open'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fabAction(
                      icon: Icons.assessment_outlined,
                      label: 'ສະຫຼຸບການຂາຍ',
                      color: Colors.blueGrey.shade700,
                      onTap: () {
                        setState(() => _isFabOpen = false);
                        Get.to(() => const SalesSummaryPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    _fabAction(
                      icon: Icons.add_shopping_cart_outlined,
                      label: 'ບັນທຶກການຂາຍ',
                      color: Colors.green.shade700,
                      onTap: () {
                        setState(() => _isFabOpen = false);
                        Get.to(() => const AddPaymentPage());
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('closed')),
        ),

        // ── Main FAB ──
        _mainFab(),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 🎯 Main FAB — ວົງມົນ gradient + ເງົາ
  // ══════════════════════════════════════════════
  Widget _mainFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.brown.shade600,
            Colors.brown.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade800.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isFabOpen = !_isFabOpen);
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: AnimatedRotation(
              turns: _isFabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: Icon(
                _isFabOpen ? Icons.close : Icons.add,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 💊 FAB Action — ປຸ່ມຍ່ອຍ ຮູບໝອນສີດຽວ
  // ══════════════════════════════════════════════
  Widget _fabAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: color.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🔘 Filter chip
  // ══════════════════════════════════════════════
  Widget _filterChip(
    SalesController controller,
    String label,
    DateFilter filter,
  ) {
    final isSelected = controller.selectedFilter.value == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(
          Icons.check_circle,
          color: isSelected ? Colors.brown.shade700 : Colors.grey.shade400,
          size: 16,
        ),
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.brown.shade900 : Colors.brown.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.brown.shade100,
        backgroundColor: Colors.brown.shade50,
        onSelected: (selected) {
          if (selected) {
            setState(() => _displayLimit = _perPage);
            controller.applyDateFilter(filter);
          }
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 🌫️ Backdrop
// ══════════════════════════════════════════════
class _FabBackdrop extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _FabBackdrop({
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}