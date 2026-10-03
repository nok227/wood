import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/widgets/skeletons/skeletons.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
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

    if (offset < 20) {
      if (!_bannerVisible.value) _bannerVisible.value = true;
      return;
    }

    if (delta > 5 && _bannerVisible.value) {
      _bannerVisible.value = false;
    } else if (delta < -5 && !_bannerVisible.value) {
      _bannerVisible.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: Column(
        children: [
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceBanner(controller: controller),
                ActionButtons(onTap: _openForm),
              ],
            ),
          ),
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
                controller: _scrollController,
                padding: const EdgeInsets.only(
                    bottom: 100, left: 12, right: 12, top: 4),
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
      backgroundColor: Colors.transparent,
    );
  }

  void _deleteDialog(AccountTransaction t) {
    if (Get.isDialogOpen ?? false) return;
    final names = t.items.map((i) => i.name).join(', ');
    Get.defaultDialog(
      title: 'ຢືນຢັນການລຶບ',
      middleText:
          'ລຶບ "${names.isNotEmpty ? names : "ລາຍການ"}" ${_fmt(t.totalAmount)} ກີບ?',
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

  String _fmt(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}