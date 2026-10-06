import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wood/core/widgets/global/skeletons/skeletons.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/core/constants/specific/account_style.dart';

import '../../domain/entities/account_transaction.dart';
import '../controllers/account_controller.dart';
import '../widgets/account_form_sheet.dart';
import '../widgets/account_skeleton.dart';
import '../widgets/action_buttons.dart';
import '../widgets/balance_banner.dart';
import '../widgets/session_section.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  static final ValueNotifier<bool> headerVisible = ValueNotifier<bool>(true);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountController controller;
  final ScrollController _scrollController = ScrollController();
  final _fmt = NumberFormat('#,###');
  double _lastOffset = 0;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccountPage.headerVisible.value = true;
    });
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final delta = offset - _lastOffset;
    _lastOffset = offset;

    if (offset < AccountStyle.scrollThreshold) {
      if (!_bannerVisible.value) _bannerVisible.value = true;
      return;
    }

    if (delta > AccountStyle.scrollDelta && _bannerVisible.value) {
      _bannerVisible.value = false;
    } else if (delta < -AccountStyle.scrollDelta && !_bannerVisible.value) {
      _bannerVisible.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: AccountStyle.bg,
      body: Column(
        children: [
          // ── Banner + Buttons (hide/show) ──
          ValueListenableBuilder<bool>(
            valueListenable: _bannerVisible,
            builder: (context, visible, child) {
              return AnimatedSize(
                duration: AccountStyle.normal,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  duration: AccountStyle.fast,
                  opacity: visible ? 1 : 0,
                  child: visible
                      ? child
                      : const SizedBox(width: double.infinity),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceBanner(controller: controller),
                ActionButtons(onTap: _openForm),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.allTransactions.isEmpty) {
                return const AccountPageSkeleton();
              }
              final groups = controller.sessionGroups;
              if (groups.isEmpty) {
                return const Center(
                  child: Text(
                    AccountStyle.noTransactions,
                    style: TextStyle(color: AccountStyle.textHint),
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: AccountStyle.padList,
                itemCount: groups.length,
                itemBuilder: (_, i) => SessionSection(
                  group: groups[i],
                  isAdmin: isAdmin,
                  controller: controller,
                  onDelete: _deleteDialog,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openForm(String type) {
    Get.bottomSheet(
      AccountFormSheet(initialType: type, onSubmit: controller.addTransaction),
      isScrollControlled: true,
      backgroundColor: AccountStyle.transparent,
    );
  }

  void _deleteDialog(AccountTransaction t) {
    if (Get.isDialogOpen ?? false) return;
    final names = t.items.map((i) => i.name).join(', ');
    Get.defaultDialog(
      title: AccountStyle.confirmDelete,
      middleText:
          '${AccountStyle.deletePrefix}${names.isNotEmpty ? names : AccountStyle.fallbackItemName}${AccountStyle.deleteMid}${_fmt.format(t.totalAmount)}${AccountStyle.deleteSuffix}',
      textConfirm: AccountStyle.delete,
      textCancel: AccountStyle.cancel,
      confirmTextColor: AccountStyle.white,
      buttonColor: AccountStyle.error800,
      onConfirm: () async {
        Get.back();
        await Future.delayed(AccountStyle.fast);
        await controller.deleteTransaction(t.id);
      },
    );
  }
}