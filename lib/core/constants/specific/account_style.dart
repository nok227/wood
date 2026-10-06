import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 ACCOUNT STYLE — Feature: Account
/// ══════════════════════════════════════════════
class AccountStyle {
  AccountStyle._();

  // ══════════════════════════════════════════
  // 🎨 COLORS
  // ══════════════════════════════════════════
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color brown50 = AppColors.brown50;
  static const Color brown100 = AppColors.brown100;
  static const Color brown200 = AppColors.brown200;
  static const Color brown300 = AppColors.brown300;
  static const Color brown400 = AppColors.brown400;
  static const Color brown500 = AppColors.brown500;
  static const Color brown700 = AppColors.brown700;
  static const Color brown800 = AppColors.brown800;

  static const Color bg = AppColors.bg;
  static const Color surface = AppColors.surface;
  static const Color divider = AppColors.divider;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textHint;
  static const Color black87 = AppColors.black87;
  static const Color black54 = AppColors.black54;

  static const Color white = AppColors.white;
  static const Color white70 = AppColors.white70;
  static const Color white24 = AppColors.white24;
  static const Color transparent = AppColors.transparent;

  static const Color grey50 = AppColors.grey50;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;

  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color green400 = AppColors.green400;
  static const Color green600 = AppColors.green600;
  static const Color green700 = AppColors.green700;
  static const Color green800 = AppColors.green800;

  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color errorRed = AppColors.errorRed;
  static const Color error700 = AppColors.error700;
  static const Color error800 = AppColors.red800;
  static const Color red200 = AppColors.red200;
  static const Color red400 = AppColors.red400;
  static const Color red600 = AppColors.red600;
  static const Color red700 = AppColors.red700;

  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color amber50 = AppColors.amber50;
  static const Color amber300 = AppColors.amber300;
  static const Color amber700 = AppColors.amber700;
  static const Color amber800 = AppColors.amber800;
  static const Color amber900 = AppColors.amber900;

  static const Color info = AppColors.info;
  static const Color blue50 = AppColors.blue50;
  static const Color blue700 = AppColors.blue700;

  static const Color income = AppColors.success;
  static const Color expense = AppColors.error;
  static const Color cash = AppColors.cash;
  static const Color transfer = AppColors.transfer;

  // ── Extend — Token alias ──
  static const Color bannerGradStart = AppColors.brown700;
  static const Color bannerGradEnd = AppColors.brown500;
  static const Color bannerNegative = AppColors.red200;
  static const Color incomeBtnStart = AppColors.green600;
  static const Color incomeBtnEnd = AppColors.green700;
  static const Color expenseBtnStart = AppColors.red600;
  static const Color expenseBtnEnd = AppColors.red700;
  static const Color sessionDivider = AppColors.grey200;
  static const Color sessionDateBadge = AppColors.brown800;
  static const Color sessionCashIcon = AppColors.amber800;
  static const Color sessionTransferIcon = AppColors.blue700;

  // ── Extend — Opacity factors ──
  static const double iconCircleOpacity = 0.2;
  static const double subTextOpacity = 0.85;
  static const double bannerShadowOpacity = 0.2;
  static const double tintOpacity = 0.1;

  // ══════════════════════════════════════════
  // 📝 TEXT STYLES
  // ══════════════════════════════════════════
  static const TextStyle heading1 = AppTextStyles.heading1;
  static const TextStyle heading2 = AppTextStyles.heading2;
  static const TextStyle heading3 = AppTextStyles.heading3;
  static const TextStyle title = AppTextStyles.title;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodyBold = AppTextStyles.bodyBold;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;
  static const TextStyle caption = AppTextStyles.caption;
  static const TextStyle label = AppTextStyles.label;
  static const TextStyle labelTiny = AppTextStyles.labelTiny;
  static const TextStyle money = AppTextStyles.money;
  static const TextStyle moneyBig = AppTextStyles.moneyBig;

  // ── Alias ຈາກ Global ──
  static const TextStyle dateHeader = AppTextStyles.dateHeader;

  // ── Extend — Form ──
  static const TextStyle formTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle amountInput = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle itemName = TextStyle(
    fontSize: 12.5,
    color: Color(0xDD000000),
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );
  static const TextStyle statValueBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Color(0x8A000000),
    letterSpacing: 0.5,
  );
  static const TextStyle inputLabel = TextStyle(
    fontSize: 13,
    color: Color(0xFF757575),
  );
  static const TextStyle formSaveBtnText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle toggleBtnText = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );
  static const TextStyle addItemBtnText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle totalLabelSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle totalValueBig = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );

  // ── Extend — Banner ──
  static const TextStyle bannerMoney = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle bannerLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  static const TextStyle bannerStatLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bannerStatValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  // ── Extend — Action buttons ──
  static const TextStyle actionTitleText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle actionSubText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
  );

  // ── Extend — Session ──
  static const TextStyle statLabelText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );
  static const TextStyle txItemName = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    color: Color(0xDD000000),
  );
  static const TextStyle txItemPrice = TextStyle(
    fontSize: 11.5,
    color: Color(0xFF757575),
    fontWeight: FontWeight.w600,
  );
  static const TextStyle txAmount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle txMeta = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle txNote = TextStyle(
    fontSize: 10.5,
    color: Color(0xFF9E9E9E),
    fontStyle: FontStyle.italic,
  );

  // ══════════════════════════════════════════
  // 📏 LAYOUT
  // ══════════════════════════════════════════
  static const double xs = AppLayout.xs;
  static const double sm = AppLayout.sm;
  static const double md = AppLayout.md;
  static const double lg = AppLayout.lg;

  static const Widget gapXs = AppLayout.gapXs;
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;
  static const Widget gapLg = AppLayout.gapLg;

  // ── Gaps เพิ่มเติม ──
  // ── Gaps เพิ่มเติม (alias จาก AppLayout) ──
  static const Widget gap2 = AppLayout.gap2;
  static const Widget gap3 = AppLayout.gap3;
  static const Widget gap4 = AppLayout.gap4;
  static const Widget gap6 = AppLayout.gap6;
  static const Widget gap10 = AppLayout.gap10;

  // ── Paddings เดิม ──
  static const EdgeInsets padCard = AppLayout.padAll14;
  static const EdgeInsets padPage = AppLayout.padAll12;
  static const EdgeInsets padSection = AppLayout.padAll16;
  static const EdgeInsets padFormSheet = AppLayout.padAll16;

  // ── Paddings เพิ่มเติม ──
  static const EdgeInsets padList =
      EdgeInsets.only(bottom: 100, left: 12, right: 12, top: 4);
  static const EdgeInsets padActionRow =
      EdgeInsets.fromLTRB(12, 12, 12, 4);
  static const EdgeInsets padBanner =
      EdgeInsets.symmetric(vertical: 10, horizontal: 14);
  static const EdgeInsets padActionBtn =
      EdgeInsets.symmetric(vertical: 12, horizontal: 12);
  static const EdgeInsets padStatsRow =
      EdgeInsets.fromLTRB(14, 8, 14, 10);
  static const EdgeInsets padTxTile =
      EdgeInsets.fromLTRB(14, 10, 8, 10);
  static const EdgeInsets padSessionHeader =
      EdgeInsets.fromLTRB(14, 12, 14, 10);
  static const EdgeInsets padDashedH =
      EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets padTotalBox =
      EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  static const EdgeInsets padAddItem =
      EdgeInsets.symmetric(vertical: 10);

  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r8 = AppLayout.r8;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r20 = AppLayout.r20;
  static const BorderRadius cardRadius = AppLayout.r14;
  static const BorderRadius inputRadius = AppLayout.r10;
  static const BorderRadius topR20 = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  // ── Sizes ──
  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconLg = AppLayout.iconLg;
  static const double buttonHeight = AppLayout.buttonHeight;

  // ── Sizes เพิ่มเติม ──
  static const double formMaxHeightFactor = 0.9;
  static const double handleW = 40;
  static const double handleH = 4;
  static const double iconCircleSize = 36;
  static const double txIconCircleSize = 32;
  static const double saveButtonHeight = 50;
  static const double bannerDividerH = 20;

  // ── Scroll behaviour ──
  static const double scrollThreshold = 20;
  static const double scrollDelta = 5;

  // ══════════════════════════════════════════
  // 🎭 SHADOWS
  // ══════════════════════════════════════════
  static List<BoxShadow> get card => AppShadows.card;
  static List<BoxShadow> get cardMd => AppShadows.cardMd;
  static List<BoxShadow> colored(Color c) => AppShadows.colored(c);

  // ══════════════════════════════════════════
  // ⏱️ DURATIONS
  // ══════════════════════════════════════════
  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;
  static const Duration slow = AppDurations.slow;
  static const Duration animFast = AppDurations.animFast;
  static const Duration animNormal = AppDurations.animNormal;
  static const Duration animSlow = AppDurations.animSlow;

  // ══════════════════════════════════════════
  // 📝 STRINGS
  // ══════════════════════════════════════════
  static const String save = AppStrings.save;
  static const String cancel = AppStrings.cancel;
  static const String delete = AppStrings.delete;
  static const String successMsg = AppStrings.success;
  static const String errorMsg = AppStrings.error;
  static const String warningMsg = AppStrings.warning;
  static const String loading = AppStrings.loading;
  static const String saving = AppStrings.saving;
  static const String noData = AppStrings.noData;
  static const String confirmDelete = AppStrings.confirmDelete;
  static const String confirmDeleteMessage = AppStrings.confirmDeleteMessage;
  static const String currency = 'ກີບ';

  // ── Extend ──
  static const String pageTitle = 'ບັນຊີ ລາຍຮັບ-ລາຍຈ່າຍ';
  static const String receiveBtn = 'ຮັບເງິນ';
  static const String receiveSub = 'ເງິນເຂົ້າ';
  static const String payBtn = 'ຈ່າຍເງິນ';
  static const String paySub = 'ເບີກໄປໃຊ້';
  static const String balanceLabel = 'ຍອດຄົງເຫຼືອ';
  static const String cashLabel = 'ສົດ';
  static const String transferLabel = 'ໂອນ';
  static const String cashFull = 'ເງິນສົດ';
  static const String transferFull = 'ເງິນໂອນ';
  static const String noTransactions = 'ບໍ່ມີລາຍການ';
  static const String morning = 'ເຊົ້າ';
  static const String afternoon = 'ບ່າຍ';
  static const String evening = 'ແລງ';

  // ── Form ──
  static const String typeIn = 'ຮັບເຂົ້າ';
  static const String typeOut = 'ຈ່າຍອອກ';
  static const String amountLabel = 'ຈຳນວນເງິນທີ່ຮັບ *';
  static const String itemsLabel = 'ລາຍການທີ່ຈ່າຍ *';
  static const String paymentTypeLabel = 'ປະເພດເງິນ *';
  static const String noteLabel = 'ໝາຍເຫດ (ຖ້າມີ)';
  static const String itemPrefix = 'ລາຍການ';
  static const String priceLabel = 'ລາຄາ';
  static const String addItemBtn = 'ເພີ່ມລາຍການ';
  static const String totalLabel = 'ລວມທັງໝົດ';
  static const String saveReceiveBtn = 'ບັນທຶກຮັບເງິນ';
  static const String savePayBtn = 'ບັນທຶກຈ່າຍເງິນ';
  static const String receiveCash = 'ຮັບເງິນສົດ';
  static const String receiveTransfer = 'ຮັບເງິນໂອນ';
  static const String alertAmount = 'ກະລຸນາໃສ່ຈຳນວນເງິນ';
  static const String alertMinItem = 'ກະລຸນາໃສ່ຢ່າງໜ້ອຍ 1 ລາຍການ';
  static const String alertTitle = 'ເຕືອນ';

  // ── Extend — Dialog / Hint ──
  static const String zeroHint = '0';
  static const String fallbackItemName = 'ລາຍການ';
  static const String deletePrefix = 'ລຶບ "';
  static const String deleteMid = '" ';
  static const String deleteSuffix = ' ກີບ?';

  // ── Extend — Session labels ──
  static const String timePrefix = 'ເວລາ ';
  static const String labelIn = 'ຮັບ';
  static const String labelOut = 'ຈ່າຍ';
  static const String labelBalance = 'ຄົງເຫຼືອ';

  // ── Extend — Day names ──
  static const List<String> dayNames = [
    'ວັນຈັນ',
    'ວັນອັງຄານ',
    'ວັນພຸດ',
    'ວັນພະຫັດ',
    'ວັນສຸກ',
    'ວັນເສົາ',
    'ວັນອາທິດ',
  ];
}