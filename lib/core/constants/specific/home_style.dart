import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

class HomeStyle {
  HomeStyle._();

  // ⭐ Brand = get
  static Color get bg => AppColors.bg;
  static Color get primary => AppColors.primary;
  static Color get primaryLight => AppColors.primaryLight;

  static const Color white = AppColors.white;
  static const Color transparent = AppColors.transparent;

  static Color get brown50 => AppColors.brown50;
  static Color get brown200 => AppColors.brown200;
  static Color get brown300 => AppColors.brown300;
  static Color get brown600 => AppColors.brown600;
  static Color get brown800 => AppColors.brown800;

  static const Color grey300 = AppColors.grey300;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;

  static const Color amber200 = AppColors.amber200;
  static const Color orange300 = AppColors.orange300;
  static const Color warning = AppColors.warning;
  static const Color warning300 = AppColors.warning300;
  static const Color warning900 = AppColors.warning900;

  static const Color error400 = AppColors.error400;
  static const Color error600 = AppColors.error600;
  static const Color errorRed = AppColors.errorRed;

  static const Color textPrimary = AppColors.textPrimary;

  // ── Nav ──
  static Color get navSelected => primary;
  static Color get navUnselected => grey500;

  static const Color pendingGradStart = AppColors.amber200;
  static const Color pendingGradEnd = AppColors.orange300;
  static const Color pendingGlow = AppColors.orange;
  static const Color logoutGradStart = AppColors.red400;
  static const Color logoutGradEnd = AppColors.red600;

  static const double opacityHero = 0.35;
  static const double opacityLogoutGlow = 0.3;
  static const double opacityBarrier = 0.4;

  // ── TEXT ──
  static const TextStyle title = AppTextStyles.title;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;

  static TextStyle get loadingText => TextStyle(color: AppColors.brown700, fontSize: 14);
  static TextStyle get heroTitle => TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.brown700, letterSpacing: 0.5);
  static TextStyle get infoTitle => TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brown800);
  static const TextStyle infoBody = TextStyle(fontSize: 12.5, color: AppColors.grey700, height: 1.5);
  static TextStyle get userName => TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.brown700);
  static TextStyle get userEmail => TextStyle(fontSize: 11.5, color: AppColors.brown600);
  static const TextStyle logoutTitleStyle = TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.3);
  static const TextStyle logoutMsgStyle = TextStyle(fontSize: 13, color: AppColors.grey600);
  static const TextStyle cancelBtnText = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700);
  static const TextStyle logoutBtnText = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800);
  static TextStyle get logoutLoadingText => TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.brown700, letterSpacing: 0.2);
  static const TextStyle logoutLoadingHint = TextStyle(fontSize: 12, color: AppColors.grey500);

  // ══ LAYOUT ══
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;
  static const Widget gapLg = AppLayout.gapLg;
  static const Widget gap2 = AppLayout.gap2;
  static const Widget gap3 = AppLayout.gap3;
  static const Widget gap4 = AppLayout.gap4;
  static const Widget gap6 = AppLayout.gap6;
  static const Widget gap10 = AppLayout.gap10;
  static const Widget gap20 = AppLayout.gap20;
  static const Widget gap24 = AppLayout.gap24;
  static const Widget gap32 = AppLayout.gap32;

  static const EdgeInsets padPendingPage = EdgeInsets.all(24);
  static const EdgeInsets padInfoCard = EdgeInsets.all(16);
  static const EdgeInsets padUserCard = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets padLogoutSheet = EdgeInsets.fromLTRB(20, 12, 20, 24);
  static const EdgeInsets padRefreshBtn = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const EdgeInsets padToast = EdgeInsets.all(12);
  static const EdgeInsets padHeroGlow = EdgeInsets.zero;

  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius topR24 = AppLayout.topR24;

  static const double navIconSelected = 26;
  static const double navIconUnselected = 22;
  static const double navFontSelected = 12;
  static const double navFontUnselected = 11;

  static const double heroSize = 120;
  static const double heroIconSize = 60;
  static const double logoutIconCircle = 72;
  static const double logoutIconSize = 34;
  static const double btnHeight = 48;
  static const double loadingIndicator = 56;
  static const double loadingStrokeWidth = 3.5;
  static const double handleBarW = 40;
  static const double handleBarH = 4;
  static const double avatarRadius = 18;
  static const double avatarIconSize = 20;
  static const double blurHero = 24;
  static const double spreadHero = 4;
  static const double blurLogout = 16;
  static const double offsetLogoutY = 6;
  static const double borderWarning = AppLayout.borderW1_5;
  static const double borderCancel = 1.4;
  static const double toastRadius = 12;
  static const double iconMdSize = AppLayout.icon22;
  static const double iconProfileSize = AppLayout.icon26;
  static const double iconLogoutSize = AppLayout.icon22;
  static const double iconRefreshSize = AppLayout.icon18;
  static const double iconLogoutBtnSize = AppLayout.icon18;

  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;
  static const Duration barsAnim = Duration(milliseconds: 240);
  static const Duration pageSlide = Duration(milliseconds: 200);
  static const Duration heroScale = Duration(milliseconds: 1200);
  static const Duration sheetAnim = Duration(milliseconds: 280);
  static const Duration snackbarShort = Duration(seconds: 1);

  // STRINGS
  static const String loading = AppStrings.loading;
  static const String cancel = AppStrings.cancel;
  static const String refresh = AppStrings.refresh;
  static const String pendingTitle = 'ລໍຖ້າການອະນຸມັດ';
  static const String pendingHeading = 'ຢູ່ລະຫວ່າງການກວດສອບ';
  static const String pendingInfoTitle = 'ບັນຊີຂອງທ່ານຍັງບໍ່ໄດ້ຮັບການກຳນົດສິດ';
  static const String pendingInfoBody = 'ກະລຸນາລໍຖ້າໃຫ້ Admin ກຳນົດສິດການເຂົ້າເຖິງ\nຈຶ່ງຈະສາມາດເຂົ້າໃຊ້ງານໄດ້';
  static const String pendingRefreshToastTitle = 'ກຳລັງກວດສອບ';
  static const String pendingRefreshToastMsg = 'ກຳລັງກວດສອບສິດອີກຄັ້ງ...';
  static const String pendingRefreshBtn = 'ກວດສອບອີກຄັ້ງ';
  static const String profileTooltip = 'ໂປຣຟາຍ';
  static const String logoutTooltip = 'ອອກຈາກລະບົບ';
  static const String logoutTitle = 'ອອກຈາກລະບົບ';
  static const String logoutMsg = 'ທ່ານຕ້ອງການອອກຈາກລະບົບແມ່ນບໍ່?';
  static const String logoutBtn = 'ອອກຈາກລະບົບ';
  static const String loggingOut = 'ກຳລັງອອກຈາກລະບົບ...';
  static const String logoutWait = 'ກະລຸນາລໍຖ້າໜຶ່ງຄູ່';
  static const String defaultUserName = 'ຜູ້ໃຊ້';
  static const String dash = '-';
}