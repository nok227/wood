import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/sale_style.dart';

import '../../controllers/sales_list_controller.dart';
import '../../pages/add_payment/add_payment_page.dart';
import '../../pages/summary/sales_summary_page.dart';

class SalesListFab extends StatelessWidget {
  final SalesListController controller;

  const SalesListFab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
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
            child: controller.isFabOpen.value
                ? Column(
                    key: const ValueKey('open'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _action(
                        icon: Icons.assessment_outlined,
                        label: SaleStyle.summaryBtn,
                        color: SaleStyle.blueGrey700,
                        onTap: () {
                          controller.closeFab();
                          Get.to(() => const SalesSummaryPage());
                        },
                      ),
                      SaleStyle.gap10,
                      _action(
                        icon: Icons.add_shopping_cart_outlined,
                        label: SaleStyle.addSaleBtn,
                        color: SaleStyle.green700,
                        onTap: () {
                          controller.closeFab();
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
      ),
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
                .withValues(alpha: SaleStyle.fabGlowOpacity),
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
            controller.toggleFab();
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: AnimatedRotation(
              turns: controller.isFabOpen.value ? 0.125 : 0,
              duration: SaleStyle.fabAnim,
              curve: Curves.easeOutCubic,
              child: Icon(
                controller.isFabOpen.value ? Icons.close : Icons.add,
                color: SaleStyle.white,
                size: SaleStyle.fabMainIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: SaleStyle.r28,
      elevation: 4,
      shadowColor: color.withValues(alpha: SaleStyle.fabShadowOpacity),
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
}

class SalesFabBackdrop extends StatelessWidget {
  final SalesListController controller;
  const SalesFabBackdrop({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.isFabOpen.value ? 1 : 0,
        duration: SaleStyle.pageAnim,
        child: IgnorePointer(
          ignoring: !controller.isFabOpen.value,
          child: GestureDetector(
            onTap: controller.closeFab,
            child: Container(
              color:
                  SaleStyle.black.withValues(alpha: SaleStyle.overlayOpacity),
            ),
          ),
        ),
      ),
    );
  }
}