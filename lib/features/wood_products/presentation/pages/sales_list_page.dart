import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/sale_entity.dart';
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

  // ══════════════════════════════════════════════
  // ✅ Cache grouping
  // ══════════════════════════════════════════════
  List<SaleEntity>? _cachedSource;
  DateFilter? _cachedFilter;
  Map<String, List<SaleEntity>> _cachedGroup = const {};
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

  // ══════════════════════════════════════════════
  // ✅ ຈັດກຸ່ມຕາມວັນທີ — cached
  // ══════════════════════════════════════════════
  Map<String, List<SaleEntity>> _groupCached(
    List<SaleEntity> source,
    DateFilter filter,
  ) {
    if (identical(_cachedSource, source) && _cachedFilter == filter) {
      return _cachedGroup;
    }
    _cachedSource = source;
    _cachedFilter = filter;

    final map = <String, List<SaleEntity>>{};
    for (final sale in source) {
      final d = sale.date;
      final k = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(k, () => []).add(sale);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    _cachedGroup = {for (final k in keys) k: map[k]!};
    _cachedKeys = keys;
    return _cachedGroup;
  }

  // ── ດຶງວັນທີ ──
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
      backgroundColor: Colors.brown[50],
      body: Column(
        children: [
          // ═══ ຕົວກອງເວລາ ═══
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
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

          // ═══ ລາຍການ ═══
          Expanded(
            child: Obx(() {
              // 🦴 ກຳລັງໂຫຼດຄັ້ງທຳອິດ
              if (controller.isLoading.value &&
                  controller.allSalesList.isEmpty) {
                return const SalesListSkeleton(count: 5);
              }

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
                      Center(child: Text('ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້')),
                    ],
                  ),
                );
              }

              // ✅ ໃຊ້ cache
              final grouped = _groupCached(sales, controller.selectedFilter.value);
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
                    bottom: 120,
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
                              color: Colors.brown),
                        ),
                      );
                    }

                    final dateKey = displayKeys[index];
                    final salesInGroup = grouped[dateKey]!;
                    final headerTitle =
                        _formatDateHeader(salesInGroup.first.date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── ກາດຫົວວັນທີ ──
                        Card(
                          color: Colors.brown[100],
                          elevation: 1,
                          margin:
                              const EdgeInsets.only(top: 6.0, bottom: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Colors.brown[800],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          headerTitle,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.brown[900],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.brown[800],
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${salesInGroup.length} ລາຍການ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ✅ RepaintBoundary ຕໍ່ SaleCard
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

      // ═══ FAB ═══
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            FloatingActionButton.extended(
              heroTag: 'btnSummary',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Get.to(() => const SalesSummaryPage());
              },
              backgroundColor: Colors.brown[700],
              icon: const Icon(Icons.assessment_outlined,
                  color: Colors.white),
              label: const Text('ສະຫຼຸບການຂາຍ',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: 'btnAddPayment',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Get.to(() => const AddPaymentPage());
              },
              backgroundColor: Colors.brown[700],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('ບັນທຶກການຂາຍ',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: 'btnMainFab',
            backgroundColor: Colors.brown[800],
            onPressed: () {
              setState(() => _isFabOpen = !_isFabOpen);
            },
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
          color: isSelected ? Colors.blue : Colors.grey[400],
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.brown[900] : Colors.brown[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.brown[200],
        backgroundColor: Colors.brown[100],
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