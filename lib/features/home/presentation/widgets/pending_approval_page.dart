import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';
import 'package:wood/features/auth/presentation/pages/profile_view_page.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage>
    with TickerProviderStateMixin {
  // ── Animations ──
  late final AnimationController _enterCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _borderCW; // ⭐ วิ่งตามเข็ม
  late final AnimationController _borderCCW; // ⭐ วิ่งทวนเข็ม

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _borderCW = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _borderCCW = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _borderCW.dispose();
    _borderCCW.dispose();
    super.dispose();
  }

  Animation<double> _iv(double b, double e) => CurvedAnimation(
    parent: _enterCtrl,
    curve: Interval(b, e, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    return Scaffold(
      backgroundColor: HomeStyle.bg,
      appBar: _appBar(auth),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter, // ⭐ ชิดบน
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              // ⭐ padding ซ้าย-ขวาเท่ากัน
              horizontal: 24,
              vertical: 20, // เว้นจากด้านบน 20px
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // ⭐ เริ่มจากบน
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ⭐ Video + animated border
                _FadeSlide(
                  a: _iv(0.0, 0.5),
                  dy: 30,
                  child: Center(child: _lottieBlock()),
                ),

                const SizedBox(height: 28),

                _FadeSlide(a: _iv(0.15, 0.6), dy: 20, child: _titleBlock()),

                const SizedBox(height: 22),

                _FadeSlide(a: _iv(0.3, 0.75), dy: 24, child: _infoCard()),

                const SizedBox(height: 14),

                if (user != null)
                  _FadeSlide(
                    a: _iv(0.45, 0.85),
                    dy: 24,
                    child: _userCard(user),
                  ),

                const SizedBox(height: 26),

                _FadeSlide(
                  a: _iv(0.6, 1.0),
                  dy: 20,
                  child: Center(child: _refreshButton()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // Title Block
  // ══════════════════════════════════════════
  Widget _titleBlock() {
    return Column(
      children: [
        Text(
          HomeStyle.pendingHeading,
          style: HomeStyle.heroTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        // ⭐ เส้นประ + จุดตรงกลาง
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(left: 40),
                color: HomeStyle.brown200,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(3, (i) {
              final opacities = [0.35, 0.7, 0.35];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 1 ? 8 : 6,
                height: i == 1 ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeStyle.warning.withValues(alpha: opacities[i]),
                ),
              );
            }),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(right: 40),
                color: HomeStyle.brown200,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // Lottie + Animated Border
  // ══════════════════════════════════════════
  Widget _lottieBlock() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _borderCW, _borderCCW]),
      builder: (context, _) {
        final glow =
            0.25 + (math.sin(_pulseCtrl.value * 2 * math.pi) + 1) * 0.15;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _AnimatedBorder(
              radius: 16,
              borderWidth: 3,
              cwAngle: _borderCW.value,
              ccwAngle: _borderCCW.value,
              child: _lottieContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _lottieContent() {
    return Lottie.asset(
      'assets/lottie/pending.json',
      fit: BoxFit.cover,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Lottie error: $error');
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [HomeStyle.pendingGradStart, HomeStyle.pendingGradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 60,
              color: HomeStyle.warning900,
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════
  // AppBar
  // ══════════════════════════════════════════
  PreferredSizeWidget _appBar(AuthController auth) {
    return AppBar(
      title: const Text(HomeStyle.pendingTitle),
      backgroundColor: HomeStyle.primary,
      foregroundColor: HomeStyle.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.account_circle,
            size: HomeStyle.iconProfileSize,
          ),
          onPressed: () => Get.to(() => const ProfileViewPage()),
        ),
        IconButton(
          icon: const Icon(Icons.logout, size: HomeStyle.iconLogoutSize),
          onPressed: () => _showLogoutSheet(auth),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // Info Card — แนวนอน (icon ซ้าย + ข้อความขวา)
  // ══════════════════════════════════════════
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeStyle.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HomeStyle.warning300,
          width: HomeStyle.borderWarning,
        ),
        boxShadow: [
          BoxShadow(
            color: HomeStyle.warning.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HomeStyle.warning.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: HomeStyle.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  HomeStyle.pendingInfoTitle,
                  style: HomeStyle.infoTitle,
                ),
                const SizedBox(height: 6),
                const Text(
                  HomeStyle.pendingInfoBody,
                  style: HomeStyle.infoBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // User Card — pill style + badge "ລໍຖ້າ"
  // ══════════════════════════════════════════
  Widget _userCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeStyle.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeStyle.brown200),
        boxShadow: [
          BoxShadow(
            color: HomeStyle.brown800.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [HomeStyle.brown600, HomeStyle.brown800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, size: 22, color: HomeStyle.white),
          ),
          const SizedBox(width: 12),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.displayName ??
                      user.email?.split('@').first ??
                      HomeStyle.defaultUserName,
                  style: HomeStyle.userName.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? HomeStyle.dash,
                  style: HomeStyle.userEmail.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Status badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: HomeStyle.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: HomeStyle.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: HomeStyle.warning,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'ລໍຖ້າ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HomeStyle.warning900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // Refresh Button
  // ══════════════════════════════════════════
  Widget _refreshButton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final pulse = 1 + math.sin(_pulseCtrl.value * 2 * math.pi) * 0.02;
        return Transform.scale(scale: pulse, child: child);
      },
      child: OutlinedButton.icon(
        onPressed: () {
          AppSnackbar.info(
            HomeStyle.pendingRefreshToastTitle,
            HomeStyle.pendingRefreshToastMsg,
          );
        },
        icon: const Icon(Icons.refresh, size: HomeStyle.iconRefreshSize),
        label: const Text(HomeStyle.pendingRefreshBtn),
        style: OutlinedButton.styleFrom(
          foregroundColor: HomeStyle.primary,
          backgroundColor: HomeStyle.white,
          side: const BorderSide(color: HomeStyle.brown300),
          padding: HomeStyle.padRefreshBtn,
          shape: const RoundedRectangleBorder(borderRadius: HomeStyle.r12),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // Logout sheet
  // ══════════════════════════════════════════
  void _showLogoutSheet(AuthController auth) {
    final isLoggingOut = false.obs;

    Get.bottomSheet(
      Obx(
        () => Container(
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
              child: isLoggingOut.value
                  ? _loadingContent()
                  : _confirmContent(
                      onCancel: () => Get.back(),
                      onConfirm: () async {
                        isLoggingOut.value = true;
                        try {
                          await auth.logout();
                        } catch (_) {}
                        Get.back();
                        Get.offAll(() => const RegisterPage());
                      },
                    ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: HomeStyle.transparent,
      barrierColor: HomeStyle.textPrimary.withValues(
        alpha: HomeStyle.opacityBarrier,
      ),
    );
  }

  Widget _confirmContent({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
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
        HomeStyle.gap20,
        Container(
          width: HomeStyle.logoutIconCircle,
          height: HomeStyle.logoutIconCircle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [HomeStyle.logoutGradStart, HomeStyle.logoutGradEnd],
            ),
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: HomeStyle.white,
            size: HomeStyle.logoutIconSize,
          ),
        ),
        HomeStyle.gapLg,
        const Text(HomeStyle.logoutTitle, style: HomeStyle.logoutTitleStyle),
        HomeStyle.gap6,
        const Text(
          HomeStyle.logoutMsg,
          style: HomeStyle.logoutMsgStyle,
          textAlign: TextAlign.center,
        ),
        HomeStyle.gap24,
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: HomeStyle.btnHeight,
                child: OutlinedButton(
                  onPressed: onCancel,
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
        HomeStyle.gap32,
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 🎬 Animated Border — 2 สีวิ่งสวนทาง
// ══════════════════════════════════════════════
class _AnimatedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final double cwAngle; // 0.0 → 1.0 (วิ่งตามเข็ม)
  final double ccwAngle; // 0.0 → 1.0 (วิ่งทวนเข็ม)

  const _AnimatedBorder({
    required this.child,
    required this.radius,
    required this.borderWidth,
    required this.cwAngle,
    required this.ccwAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── ① เส้นขอบฐาน (สีน้ำตาลเข้ม) ──
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HomeStyle.brown800,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),

        // ── ② แสงวิ่งตามเข็มนาฬิกา (สีทอง) ──
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Transform.rotate(
              angle: cwAngle * 2 * math.pi,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFFFD54F), // bright gold
                      Color(0xFFFFB300), // deep gold
                      Color(0x00FFD54F), // fade out
                      Color(0x00FFD54F),
                      Color(0x00FFD54F),
                      Color(0x00FFD54F),
                    ],
                    stops: [0.0, 0.08, 0.28, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── ③ แสงวิ่งทวนเข็มนาฬิกา (สีส้ม) ──
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Transform.rotate(
              angle: -ccwAngle * 2 * math.pi,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFFF7043), // bright coral
                      Color(0xFFE64A19), // deep orange
                      Color(0x00FF7043), // fade out
                      Color(0x00FF7043),
                      Color(0x00FF7043),
                      Color(0x00FF7043),
                    ],
                    stops: [0.0, 0.08, 0.28, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── ④ Content (mask ตรงกลาง) ──
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - borderWidth),
              child: ColoredBox(color: HomeStyle.brown50, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 🎬 Helper — Fade + Slide
// ══════════════════════════════════════════════
class _FadeSlide extends StatelessWidget {
  final Animation<double> a;
  final Widget child;
  final double dy;
  const _FadeSlide({required this.a, required this.child, this.dy = 20});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * dy),
          child: child,
        ),
      ),
    );
  }
}
