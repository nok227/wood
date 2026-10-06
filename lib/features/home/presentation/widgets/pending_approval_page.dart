import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';
import 'package:wood/features/auth/presentation/pages/profile_view_page.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    return Scaffold(
      backgroundColor: HomeStyle.bg,
      appBar: AppBar(
        title: const Text(HomeStyle.pendingTitle),
        backgroundColor: HomeStyle.primary,
        foregroundColor: HomeStyle.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: HomeStyle.iconProfileSize,
            ),
            tooltip: HomeStyle.profileTooltip,
            onPressed: () => Get.to(() => const ProfileViewPage()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: HomeStyle.iconLogoutSize),
            tooltip: HomeStyle.logoutTooltip,
            onPressed: () => _showLogoutSheet(auth),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: HomeStyle.padPendingPage,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Hero icon ──
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: HomeStyle.heroScale,
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: HomeStyle.heroSize,
                    height: HomeStyle.heroSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          HomeStyle.pendingGradStart,
                          HomeStyle.pendingGradEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: HomeStyle.pendingGlow.withOpacity(
                            HomeStyle.opacityHero,
                          ),
                          blurRadius: HomeStyle.blurHero,
                          spreadRadius: HomeStyle.spreadHero,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: HomeStyle.heroIconSize,
                      color: HomeStyle.warning900,
                    ),
                  ),
                ),
                HomeStyle.gap32,

                // ── Heading ──
                const Text(
                  HomeStyle.pendingHeading,
                  style: HomeStyle.heroTitle,
                  textAlign: TextAlign.center,
                ),
                HomeStyle.gapMd,

                // ── Info card ──
                Container(
                  padding: HomeStyle.padInfoCard,
                  decoration: BoxDecoration(
                    color: HomeStyle.white,
                    borderRadius: HomeStyle.r14,
                    border: Border.all(
                      color: HomeStyle.warning300,
                      width: HomeStyle.borderWarning,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: HomeStyle.warning,
                        size: HomeStyle.iconMdSize,
                      ),
                      HomeStyle.gapSm,
                      const Text(
                        HomeStyle.pendingInfoTitle,
                        style: HomeStyle.infoTitle,
                        textAlign: TextAlign.center,
                      ),
                      HomeStyle.gapSm,
                      const Text(
                        HomeStyle.pendingInfoBody,
                        style: HomeStyle.infoBody,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                HomeStyle.gap24,

                // ── User card ──
                if (user != null)
                  Container(
                    padding: HomeStyle.padUserCard,
                    decoration: BoxDecoration(
                      color: HomeStyle.brown50,
                      borderRadius: HomeStyle.r12,
                      border: Border.all(color: HomeStyle.brown200),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: HomeStyle.avatarRadius,
                          backgroundColor: HomeStyle.brown200,
                          child: Icon(
                            Icons.person,
                            size: HomeStyle.avatarIconSize,
                            color: HomeStyle.brown800,
                          ),
                        ),
                        HomeStyle.gapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ??
                                    user.email?.split('@').first ??
                                    HomeStyle.defaultUserName,
                                style: HomeStyle.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              HomeStyle.gap2,
                              Text(
                                user.email ?? HomeStyle.dash,
                                style: HomeStyle.userEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                HomeStyle.gap24,

                // ── Refresh button ──
                OutlinedButton.icon(
                  onPressed: () {
                    AppSnackbar.info(
                      HomeStyle.pendingRefreshToastTitle,
                      HomeStyle.pendingRefreshToastMsg,
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: HomeStyle.iconRefreshSize,
                  ),
                  label: const Text(HomeStyle.pendingRefreshBtn),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeStyle.primary,
                    side: const BorderSide(color: HomeStyle.brown300),
                    padding: HomeStyle.padRefreshBtn,
                    shape: const RoundedRectangleBorder(
                      borderRadius: HomeStyle.r12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 🚪 Logout bottom sheet
  // ══════════════════════════════════════════════
  void _showLogoutSheet(AuthController auth) {
    var isLoggingOut = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: HomeStyle.padLogoutSheet,
            decoration: const BoxDecoration(
              color: HomeStyle.white,
              borderRadius: HomeStyle.topR24,
            ),
            child: SafeArea(
              top: false,
              child: AnimatedSize(
                duration: HomeStyle.sheetAnim,
                curve: Curves.easeOutCubic,
                child: isLoggingOut
                    ? _loadingContent()
                    : _confirmContent(
                        onCancel: () => Get.back(),
                        onConfirm: () async {
                          setSheetState(() => isLoggingOut = true);
                          try {
                            await auth.logout();
                          } catch (_) {}
                          Get.back();
                          Get.offAll(() => const RegisterPage());
                        },
                      ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: HomeStyle.transparent,
      barrierColor: HomeStyle.textPrimary.withOpacity(HomeStyle.opacityBarrier),
    );
  }

  Widget _confirmContent({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Handle ──
        Container(
          width: HomeStyle.handleBarW,
          height: HomeStyle.handleBarH,
          decoration: BoxDecoration(
            color: HomeStyle.grey300,
            borderRadius: HomeStyle.r4,
          ),
        ),
        HomeStyle.gap20,

        // ── Logout icon circle ──
        Container(
          width: HomeStyle.logoutIconCircle,
          height: HomeStyle.logoutIconCircle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [HomeStyle.logoutGradStart, HomeStyle.logoutGradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: HomeStyle.errorRed.withOpacity(
                  HomeStyle.opacityLogoutGlow,
                ),
                blurRadius: HomeStyle.blurLogout,
                offset: const Offset(0, HomeStyle.offsetLogoutY),
              ),
            ],
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: HomeStyle.white,
            size: HomeStyle.logoutIconSize,
          ),
        ),
        HomeStyle.gapLg,

        // ── Title ──
        const Text(HomeStyle.logoutTitle, style: HomeStyle.logoutTitleStyle),
        HomeStyle.gap6,
        const Text(
          HomeStyle.logoutMsg,
          style: HomeStyle.logoutMsgStyle,
          textAlign: TextAlign.center,
        ),
        HomeStyle.gap24,

        // ── Buttons ──
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: HomeStyle.btnHeight,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeStyle.grey700,
                    side: const BorderSide(
                      color: HomeStyle.grey300,
                      width: HomeStyle.borderCancel,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: HomeStyle.r12,
                    ),
                  ),
                  child: const Text(
                    HomeStyle.cancel,
                    style: HomeStyle.cancelBtnText,
                  ),
                ),
              ),
            ),
            HomeStyle.gapMd,
            Expanded(
              flex: 2,
              child: SizedBox(
                height: HomeStyle.btnHeight,
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeStyle.error600,
                    foregroundColor: HomeStyle.white,
                    elevation: 0,
                    shadowColor: HomeStyle.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: HomeStyle.r12,
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: HomeStyle.iconLogoutBtnSize,
                  ),
                  label: const Text(
                    HomeStyle.logoutBtn,
                    style: HomeStyle.logoutBtnText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: HomeStyle.handleBarW,
          height: HomeStyle.handleBarH,
          decoration: BoxDecoration(
            color: HomeStyle.grey300,
            borderRadius: HomeStyle.r4,
          ),
        ),
        HomeStyle.gap32,
        const SizedBox(
          width: HomeStyle.loadingIndicator,
          height: HomeStyle.loadingIndicator,
          child: CircularProgressIndicator(
            color: HomeStyle.primary,
            strokeWidth: HomeStyle.loadingStrokeWidth,
          ),
        ),
        HomeStyle.gap24,
        const Text(HomeStyle.loggingOut, style: HomeStyle.logoutLoadingText),
        HomeStyle.gap6,
        const Text(HomeStyle.logoutWait, style: HomeStyle.logoutLoadingHint),
        HomeStyle.gap32,
      ],
    );
  }
}
