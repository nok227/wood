import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 AUTH STYLE — Feature: Auth
/// ══════════════════════════════════════════════
class AuthStyle {
  AuthStyle._();

  // ══════════ COLORS ══════════
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;

  static const Color bg = AppColors.brown50;
  static const Color surface = AppColors.surface;

  static const Color brown50 = AppColors.brown50;
  static const Color brown100 = AppColors.brown100;
  static const Color brown200 = AppColors.brown200;
  static const Color brown300 = AppColors.brown300;
  static const Color brown400 = AppColors.brown400;
  static const Color brown500 = AppColors.brown500;
  static const Color brown600 = AppColors.brown600;
  static const Color brown700 = AppColors.brown700;
  static const Color brown800 = AppColors.brown800;
  static const Color brown900 = AppColors.brown900;

  static const Color white = AppColors.white;
  static const Color white24 = AppColors.white24;
  static const Color white70 = AppColors.white70;
  static const Color black12 = AppColors.black12;

  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;

  static const Color amber50 = AppColors.amber50;
  static const Color amber200 = AppColors.amber200;
  static const Color amber300 = AppColors.amber300;
  static const Color amber800 = AppColors.amber800;
  static const Color amber900 = AppColors.amber900;

  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color successMid = AppColors.successMid;
  static const Color success300 = AppColors.success300;
  static const Color successDark = AppColors.successDark;

  static const Color error = AppColors.error;
  static const Color error300 = AppColors.error300;
  static const Color error700 = AppColors.error700;
  static const Color errorRed = AppColors.errorRed;

  // ── Extend ──
  static const Color profileGradStart = AppColors.brown800;
  static const Color profileGradEnd = AppColors.brown600;
  static const Color profileShadow = Color(0x4D5D4037);
  static const Color avatarBg = Color(0x33FFFFFF);

  // ── Opacity factors ──
  static const double borderOpacity = 0.25;
  static const double circleBorderOpacity = 0.5;

  // ══════════ TEXT STYLES ══════════
  static const TextStyle heading1 = AppTextStyles.heading1;
  static const TextStyle heading2 = AppTextStyles.heading2;
  static const TextStyle heading3 = AppTextStyles.heading3;
  static const TextStyle title = AppTextStyles.title;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodyBold = AppTextStyles.bodyBold;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;
  static const TextStyle caption = AppTextStyles.caption;
  static const TextStyle label = AppTextStyles.label;

  static const TextStyle profileName = TextStyle(
    color: AppColors.white,
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle profileNameSmall = TextStyle(
    color: AppColors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle profileEmail = TextStyle(
    color: AppColors.white70,
    fontSize: 12,
  );
  static const TextStyle roleBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle userName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle userEmail = TextStyle(
    fontSize: 11.5,
    color: AppColors.grey600,
  );
  static const TextStyle usersHeader = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle infoText = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const TextStyle roleChip = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle youBadgeStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle inputLabel = TextStyle(fontSize: 14);
  static const TextStyle buttonText = TextStyle(fontSize: 16);
  static const TextStyle loginBtnText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
  );
  static const TextStyle saveBtnText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle menuTileTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle menuTileKey = TextStyle(
    fontSize: 11,
    color: AppColors.grey500,
  );
  static const TextStyle emptyText = TextStyle(color: AppColors.grey600);
  static const TextStyle dialogText = TextStyle(color: AppColors.grey600);

  // ══════════ LAYOUT ══════════
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;
  static const Widget gapLg = AppLayout.gapLg;

  static const double gap20 = 20;
  static const double gap24 = 24;

  static const Widget gap2 = AppLayout.gap2;
  static const Widget gap3 = AppLayout.gap3;
  static const Widget gap4 = AppLayout.gap4;
  static const Widget gap5 = AppLayout.gap5;
  static const Widget gap6 = AppLayout.gap6;
  static const Widget gap10 = AppLayout.gap10;
  static const Widget gap12 = AppLayout.gap12;
  static const Widget gap14 = AppLayout.gap14;
  static const Widget gap20W = AppLayout.gap20;
  static const Widget gap24W = AppLayout.gap24;

  static const EdgeInsets padPageAuth = EdgeInsets.all(20);
  static const EdgeInsets padPageList = AppLayout.padAll16;
  static const EdgeInsets padCard = AppLayout.padAll12;
  static const EdgeInsets padProfileCard = EdgeInsets.all(18);
  static const EdgeInsets padHeader = EdgeInsets.all(14);
  static const EdgeInsets padInfo = EdgeInsets.all(10);
  static const EdgeInsets padHeaderIcon = EdgeInsets.all(6);
  static const EdgeInsets padPresetBtn = EdgeInsets.symmetric(vertical: 10);
  static const EdgeInsets padChipBadge = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const EdgeInsets padBadgeTiny = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 1,
  );
  static const EdgeInsets padEmptyCard = EdgeInsets.all(24);

  static const EdgeInsets marginTileBottom = EdgeInsets.only(bottom: 8);

  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r8 = AppLayout.r8;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r16 = AppLayout.r16;
  static const BorderRadius r20 = AppLayout.r20;

  static const BorderRadius inputRadius = AppLayout.r8;
  static const BorderRadius cardRadius = AppLayout.r12;
  static const BorderRadius profileRadius = AppLayout.r16;
  static const BorderRadius chipRadius = AppLayout.r20;
  static const BorderRadius badgeRadius = AppLayout.r6;

  // ── Sizes — base ──
  static const double buttonHeight = AppLayout.buttonHeight;
  static const double avatarLg = 32;
  static const double avatarMd = 24;
  static const double avatarSm = 21;
  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconLg = AppLayout.iconLg;
  static const double snackbarRadius = 12;

  // ── Sizes — Icon (alias จาก AppLayout) ──
  static const double iconAvatarBig = 34; // ← เฉพาะ auth
  static const double iconAvatarMd = AppLayout.icon26;
  static const double iconToolbar = AppLayout.icon22;
  static const double iconTile = AppLayout.iconMd; // 20
  static const double iconMenuTile = AppLayout.icon18;
  static const double iconPreset = AppLayout.iconSm; // 16
  static const double iconBadgeSmall = AppLayout.icon12; // icon role badge

  // ── Sizes — Avatar / Box ──
  static const double userAvatarSize = 42;
  static const double skeletonAvatarSize = 64;
  static const double emptyIconSize = 40;
  static const double iconBadgeSize = 15;
  static const double spinnerSmall = 18;
  static const double spinnerStroke = 2;
  static const double iconBtnSize = 36;
  static const double borderWidth = 1.2;

  // ── Sizes — Skeleton ──
  // ── Sizes — Skeleton (ชื่อยาว) ──
  static const double skeletonTextHeight = 16;
  static const double skeletonTextWidth = 140;
  static const double skeletonTextSmallHeight = 12;
  static const double skeletonBadgeHeight = 18;
  static const double skeletonBadgeWidth = 70;
  static const double skeletonBadgeRadius = 20;
  static const double skeletonTitleWidth = 160;
  static const double skeletonTitleHeight = 15;
  static const double skeletonCardHeight = 64;
  static const double skeletonCardRadius = 12;
  static const double skeletonMinHeight = 400;

  // ── Alias ชื่อสั้น (backward-compat) ──
  static const double skeletonTextH = skeletonTextHeight;
  static const double skeletonTextW = skeletonTextWidth;
  static const double skeletonTextHSm = skeletonTextSmallHeight;
  static const double skeletonBadgeH = skeletonBadgeHeight;
  static const double skeletonBadgeW = skeletonBadgeWidth;
  static const double skeletonBadgeR = skeletonBadgeRadius;
  static const double skeletonTitleW = skeletonTitleWidth;
  static const double skeletonTitleH = skeletonTitleHeight;
  static const double skeletonCardH = skeletonCardHeight;
  static const double skeletonCardR = skeletonCardRadius;

  // ── Border widths ──
  static const double borderWidthSelected = 1.6;
  static const double borderWidthNormal = 1.0;

  // ── BoxConstraints ──
  static const BoxConstraints iconBtnConstraints = BoxConstraints(
    minWidth: iconBtnSize,
    minHeight: iconBtnSize,
  );

  // ══════════ SHADOWS ══════════
  static List<BoxShadow> get card => AppShadows.card;
  static List<BoxShadow> colored(Color c) => AppShadows.colored(c);
  static List<BoxShadow> get profile => [
    BoxShadow(color: profileShadow, blurRadius: 12, offset: const Offset(0, 6)),
  ];
  static List<BoxShadow> get cardLocal => [
    const BoxShadow(
      color: AppColors.black12,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // ══════════ DURATIONS ══════════
  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;

  // ══════════ STRINGS ══════════
  static const String save = AppStrings.save;
  static const String cancel = AppStrings.cancel;
  static const String successMsg = AppStrings.success;
  static const String errorMsg = AppStrings.error;
  static const String loading = AppStrings.loading;
  static const String saving = AppStrings.saving;

  static const String loginTitle = 'ເຂົ້າສູ່ລະບົບ';
  static const String registerTitle = 'ລົງທະບຽນເຂົ້າໃຊ້ງານ';
  static const String emailLabel = 'ອີເມວ';
  static const String passwordLabel = 'ລະຫັດຜ່ານ';
  static const String nameLabel = 'ຊື່ ແລະ ນາມສະກຸນ';
  static const String loginBtn = 'ເຂົ້າສູ່ລະບົບ';
  static const String registerBtn = 'ລົງທະບຽນ';
  static const String googleBtn = 'ເຂົ້າສູ່ລະບົບດ້ວຍ Google';
  static const String orLabel = 'ຫຼື';
  static const String noAccount = 'ຍັງບໍ່ມີບັນຊີ? ';
  static const String hasAccount = 'ມີບັນຊີຢູ່ແລ້ວ? ';

  static const String emailRequired = 'ກະລຸນາປ້ອນອີເມວ';
  static const String emailInvalid = 'ຮູບແບບອີເມວບໍ່ຖືກຕ້ອງ';
  static const String passwordRequired = 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
  static const String passwordTooShort = 'ລະຫັດຜ່ານຕ້ອງຢ່າງນ້ອຍ 6 ຕົວອັກສອນ';

  static const String profileTitle = 'ໂປຣຟາຍ';
  static const String defaultUserName = 'ຜູ້ໃຊ້';
  static const String adminLabel = 'Admin';
  static const String userLabel = 'User';
  static const String youBadge = 'ຂ້ອຍ';
  static const String usersTitle = 'ລາຍຊື່ຜູ້ໃຊ້';
  static const String noUsers = 'ບໍ່ມີຜູ້ໃຊ້';
  static const String refreshTooltip = 'ໂຫຼດໃໝ່';
  static const String logoutTooltip = 'ອອກຈາກລະບົບ';
  static const String logoutTitle = 'ຍືນຍັນການອອກຈາກລະບົບ';
  static const String logoutConfirm = 'ຕ້ອງການອອກຈາກລະບົບແມ່ນບໍ່?';
  static const String logoutBtn = 'ອອກຈາກລະບົບ';
  static const String permissionTooltip = 'ກຳນົດສິດ';
  static const String loadUsersError = 'ບໍ່ສາມາດໂຫຼດຜູ້ໃຊ້ໄດ້';
  static const String logoutError = 'ບໍ່ສາມາດອອກໄດ້';
  static const String dash = '-';

  static const String permissionTitle = 'ກຳນົດສິດການເຂົ້າເຖິງ';
  static const String viewOnly = 'ເບິ່ງຢ່າງດຽວ';
  static const String allMenus = 'ທັງໝົດ';
  static const String noAccess = 'ບໍ່ໃຫ້';
  static const String menuAllowed = 'ເມນູທີ່ອະນຸຍາດ';
  static const String permissionInfo =
      'ຖ້າບໍ່ເລືອກເມນູໃດເລີຍ ຜູ້ໃຊ້ຈະເຫັນໜ້າ "ຢູ່ລະຫວ່າງການກວດສອບ"';
  static const String permissionSaveSuccess = 'ອັບເດດສິດຂອງ';
  static const String permissionSaveSuccessSuffix = 'ແລ້ວ';
  static const String keyPrefix = 'key: ';
}
