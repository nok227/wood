import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';

import '../controllers/account_controller.dart';
import '../controllers/account_form_controller.dart';
import '../controllers/account_header_controller.dart';
import '../widgets/account_action_buttons.dart';
import '../widgets/account_balance_banner.dart';
import '../widgets/account_delete_dialog.dart';
import '../widgets/account_form_sheet.dart';
import '../widgets/account_session_list.dart';
import '../widgets/account_skeleton.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountController>();
    final header = Get.find<AccountHeaderController>();
    final isAdmin = Get.find<AuthController>().isAdmin;

    return Scaffold(
      backgroundColor: AccountStyle.bg,
      body: Column(
        children: [
          // ── Banner + Buttons (hide/show) ──
          Obx(() => AnimatedSize(
                duration: AccountStyle.normal,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  duration: AccountStyle.fast,
                  opacity: header.bannerVisible.value ? 1 : 0,
                  child: header.bannerVisible.value
                      ? Obx(() => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AccountBalanceBanner(
                                balance: controller.balance,
                                cashBalance: controller.cashBalance,
                                transferBalance: controller.transferBalance,
                              ),
                              AccountActionButtons(
                                onTap: (t) => _openForm(t),
                              ),
                            ],
                          ))
                      : const SizedBox(width: double.infinity),
                ),
              )),

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
              return AccountSessionList(
                groups: groups,
                isAdmin: isAdmin,
                scrollCtrl: header.scrollCtrl,
                formatTime: controller.formatTime,
                onDelete: (t) => showAccountDeleteDialog(
                  transaction: t,
                  onConfirm: () => controller.deleteTransaction(t.id),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openForm(String type) {
    // ล้าง form controller เก่า ป้องกัน state ค้าง
    Get.delete<AccountFormController>(tag: 'account_form', force: true);

    Get.bottomSheet(
      AccountFormSheet(initialType: type),
      isScrollControlled: true,
      backgroundColor: AccountStyle.transparent,
    );
  }
}