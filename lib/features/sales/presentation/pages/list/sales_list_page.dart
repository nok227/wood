import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wood/core/constants/specific/sale_style.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import '../../../domain/entities/sale_order_entity.dart';
import '../../controllers/sales_controller.dart';
import '../../widgets/sale_card.dart';
import '../../widgets/sales_list_skeleton.dart';
import '../add_payment/add_payment_page.dart';
import '../summary/sales_summary_page.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage>
    with AutomaticKeepAliveClientMixin {
  bool _isFabOpen = false;

  final ScrollController _scroll = ScrollController();
  int _displayLimit = SaleStyle.perPage;
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
    if (pos.pixels >= pos.maxScrollExtent - SaleStyle.scrollLoadMoreThreshold &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(SaleStyle.debounce);
    if (!mounted) return;
    setState(() {
      _displayLimit += SaleStyle.perPage;
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
      backgroundColor: SaleStyle.bg,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Filter chips ──
              Container(
                color: SaleStyle.white,
                padding: SaleStyle.padFilterRow,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: SaleStyle.padH8,
                  child: Obx(
                    () => Row(
                      children: [
                        _filterChip(controller, SaleStyle.filterAll,
                            DateFilter.all),
                        _filterChip(controller, SaleStyle.filterToday,
                            DateFilter.today),
                        _filterChip(controller, SaleStyle.filterWeek,
                            DateFilter.week),
                        _filterChip(controller, SaleStyle.filterMonth,
                            DateFilter.month),
                        _filterChip(controller, SaleStyle.filterYear,
                            DateFilter.year),
                      ],
                    ),
                  ),
                ),
              ),

              // ── List ──
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
                      color: SaleStyle.primary,
                      onRefresh: () async {
                        setState(() => _displayLimit = SaleStyle.perPage);
                        await controller.fetchSales();
                      },
                      child: ListView(
                        children: const [
                          SaleStyle.gap120,
                          Center(
                            child: Text(
                              SaleStyle.noSales,
                              style: SaleStyle.textEmptyList,
                            ),
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
                  final displayKeys =
                      groupKeys.take(_displayLimit).toList();
                  final hasMore = groupKeys.length > displayKeys.length;

                  return RefreshIndicator(
                    color: SaleStyle.primary,
                    onRefresh: () async {
                      setState(() => _displayLimit = SaleStyle.perPage);
                      await controller.fetchSales();
                    },
                    child: ListView.builder(
                      controller: _scroll,
                      padding: SaleStyle.padListFAB,
                      itemCount: displayKeys.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayKeys.length) {
                          return const Padding(
                            padding: SaleStyle.padLoadMore,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: SaleStyle.primary,
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
                            Padding(
                              padding: SaleStyle.padDateHeader,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: SaleStyle.iconCalendar,
                                    color: SaleStyle.brown700,
                                  ),
                                  SaleStyle.gap6,
                                  Expanded(
                                    child: Text(
                                      headerTitle,
                                      style: SaleStyle.dateHeader,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${salesInGroup.length} ${SaleStyle.summaryOrderUnit}',
                                    style: SaleStyle.dateHeaderGrey,
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildFabGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: SaleStyle.fabAnim,
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
                      label: SaleStyle.summaryBtn,
                      color: SaleStyle.blueGrey700,
                      onTap: () {
                        setState(() => _isFabOpen = false);
                        Get.to(() => const SalesSummaryPage());
                      },
                    ),
                    SaleStyle.gap10,
                    _fabAction(
                      icon: Icons.add_shopping_cart_outlined,
                      label: SaleStyle.addSaleBtn,
                      color: SaleStyle.green700,
                      onTap: () {
                        setState(() => _isFabOpen = false);
                        Get.to(() => const AddPaymentPage());
                      },
                    ),
                    SaleStyle.gap12,
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('closed')),
        ),
        _mainFab(),
      ],
    );
  }

  Widget _mainFab() {
    return Container(
      width: SaleStyle.fabMain,
      height: SaleStyle.fabMain,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [SaleStyle.brown600, SaleStyle.brown800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: SaleStyle.brown800
                .withOpacity(SaleStyle.fabGlowOpacity),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: SaleStyle.transparent,
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
              duration: SaleStyle.fabAnim,
              curve: Curves.easeOutCubic,
              child: Icon(
                _isFabOpen ? Icons.close : Icons.add,
                color: SaleStyle.white,
                size: SaleStyle.fabMainIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fabAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: SaleStyle.r28,
      elevation: 4,
      shadowColor: color.withOpacity(SaleStyle.fabShadowOpacity),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: SaleStyle.r28,
        child: Padding(
          padding: SaleStyle.padFabAction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: SaleStyle.white, size: SaleStyle.iconMenuSmall),
              SaleStyle.gapSm,
              Text(label, style: SaleStyle.textFabAction),
            ],
          ),
        ),
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
      padding: SaleStyle.padFilterChip,
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(
          Icons.check_circle,
          color: isSelected ? SaleStyle.brown700 : SaleStyle.grey400,
          size: SaleStyle.iconCheckSm,
        ),
        label: Text(
          label,
          style: (isSelected
                  ? SaleStyle.textFilterChipSelected
                  : SaleStyle.textFilterChip)
              .copyWith(
            color: isSelected ? SaleStyle.brown900 : SaleStyle.brown700,
          ),
        ),
        selected: isSelected,
        selectedColor: SaleStyle.brown100,
        backgroundColor: SaleStyle.brown50,
        onSelected: (selected) {
          if (selected) {
            setState(() => _displayLimit = SaleStyle.perPage);
            controller.applyDateFilter(filter);
          }
        },
      ),
    );
  }
}

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
      duration: SaleStyle.pageAnim,
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: SaleStyle.black.withOpacity(SaleStyle.overlayOpacity),
          ),
        ),
      ),
    );
  }
}