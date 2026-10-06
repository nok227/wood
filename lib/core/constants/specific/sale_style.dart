import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 SALE STYLE — Feature: Sales
///
/// ไฟล์ที่เรียกใช้ (17 ไฟล์):
///   pages: sales_list_page, add_payment_page, sale_detail_page,
///          debt_payment_page, sale_image_edit_page,
///          sales_summary_page, sales_summary_detail_page
///   widgets: sale_card, sale_order_preview_card,
///            sales_list_skeleton, sales_summary_skeleton,
///            add_payment_bills_panel, add_payment_debt_form,
///            add_payment_items_panel, add_payment_summary,
///            add_payment_wood_picker, full_image_viewer
/// ══════════════════════════════════════════════
class SaleStyle {
  SaleStyle._();

  // ══════════════════════════════════════════
  // 🎨 COLORS
  // ══════════════════════════════════════════
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;

  static const Color bg = AppColors.bg;
  static const Color surface = AppColors.surface;
  static const Color softBg = AppColors.brown50;
  static const Color greyBg = AppColors.grey50;
  static const Color greyLight = AppColors.grey100;
  static const Color divider = AppColors.divider;
  static const Color border = AppColors.grey200;

  static const Color white = AppColors.white;
  static const Color black = AppColors.black;
  static const Color transparent = AppColors.transparent;
  static const Color white24 = AppColors.white24;
  static const Color white54 = AppColors.white54;
  static const Color white70 = AppColors.white70;
  static const Color black12 = AppColors.black12;
  static const Color black26 = AppColors.black26;
  static const Color black45 = AppColors.black45;
  static const Color black54 = AppColors.black54;
  static const Color black87 = AppColors.black87;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textHint;

  // ── Brown scale ──
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

  // ── Grey scale ──
  static const Color grey50 = AppColors.grey50;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;
  static const Color grey800 = AppColors.grey800;

  // ── Success ──
  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color successMid = AppColors.successMid;
  static const Color success300 = AppColors.success300;
  static const Color successDark = AppColors.successDark;
  static const Color green50 = AppColors.green50;
  static const Color green100 = AppColors.green100;
  static const Color green300 = AppColors.green300;
  static const Color green400 = AppColors.green400;
  static const Color green600 = AppColors.green600;
  static const Color green700 = AppColors.green700;
  static const Color green800 = AppColors.green800;

  // ── Error ──
  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color error300 = AppColors.error300;
  static const Color error400 = AppColors.error400;
  static const Color error600 = AppColors.error600;
  static const Color error700 = AppColors.error700;
  static const Color errorRed = AppColors.errorRed;
  static const Color red50 = AppColors.red50;
  static const Color red100 = AppColors.red100;
  static const Color red200 = AppColors.red200;
  static const Color red300 = AppColors.red300;
  static const Color red400 = AppColors.red400;
  static const Color red500 = AppColors.red500;
  static const Color red600 = AppColors.red600;
  static const Color red700 = AppColors.red700;

  // ── Warning ──
  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color warning300 = AppColors.warning300;
  static const Color warning400 = AppColors.warning400;
  static const Color warning900 = AppColors.warning900;
  static const Color amber50 = AppColors.amber50;
  static const Color amber100 = AppColors.amber100;
  static const Color amber200 = AppColors.amber200;
  static const Color amber300 = AppColors.amber300;
  static const Color amber400 = AppColors.amber400;
  static const Color amber700 = AppColors.amber700;
  static const Color amber800 = AppColors.amber800;
  static const Color amber900 = AppColors.amber900;
  static const Color orange = AppColors.orange;
  static const Color orange50 = AppColors.orange50;
  static const Color orange100 = AppColors.orange100;
  static const Color orange200 = AppColors.orange200;
  static const Color orange300 = AppColors.orange300;
  static const Color orange400 = AppColors.orange400;
  static const Color orange700 = AppColors.orange700;
  static const Color orange800 = AppColors.orange800;
  static const Color orange900 = AppColors.orange900;

  // ── Info ──
  static const Color info = AppColors.info;
  static const Color infoLight = AppColors.infoLight;
  static const Color blue = AppColors.blue;
  static const Color blue50 = AppColors.blue50;
  static const Color blue100 = AppColors.blue100;
  static const Color blue200 = AppColors.blue200;
  static const Color blue600 = AppColors.blue600;
  static const Color blue700 = AppColors.blue700;
  static const Color blueAccent = AppColors.blueAccent;
  static const Color blueGrey700 = Color(0xFF455A64);

  // ── Accent ──
  static const Color indigo = AppColors.indigo;
  static const Color indigo700 = AppColors.indigo700;

  // ── Payment ──
  static const Color cash = AppColors.cash;
  static const Color transfer = AppColors.transfer;
  static const Color mixed = AppColors.mixed;
  static const Color debt = AppColors.debt;

  // ── Status ──
  static const Color confirmed = AppColors.confirmed;
  static const Color mismatch = AppColors.mismatch;
  static const Color pending = AppColors.pending;

  // ── Extend ສະເພາະ sale (alias token) ──
  static const Color discountBadge = AppColors.red700;
  static const Color changeGradStart = AppColors.brown800;
  static const Color changeGradEnd = AppColors.brown600;
  static const Color summaryGradStart = AppColors.brown700;
  static const Color summaryGradEnd = AppColors.brown500;
  static const Color medal1 = AppColors.amber700;
  static const Color medal2 = AppColors.grey600;
  static const Color medal3 = AppColors.brown400;
  static const Color medal4 = AppColors.brown200;

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
  static const TextStyle moneyHuge = AppTextStyles.moneyHuge;

  // ── Alias ຈາກ Global (ເຄີຍຊ້ຳ) ──
  static const TextStyle dateHeader = AppTextStyles.dateHeader;
  static const TextStyle sectionTitle = AppTextStyles.sectionTitle;
  static const TextStyle sectionLabel = AppTextStyles.sectionLabel;
  static const TextStyle itemName = AppTextStyles.itemName;
  static const TextStyle itemNameBold = AppTextStyles.itemNameBold;

  // ── Extend (sale-specific) ──
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
    color: AppColors.black87,
  );
  static const TextStyle cardMeta = TextStyle(
    fontSize: 11.5,
    color: AppColors.grey600,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle cardSubMeta = TextStyle(
    fontSize: 11,
    color: AppColors.grey700,
  );
  static const TextStyle badge = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle miniChip = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );
  static const TextStyle moneyLg = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle moneyXl = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle moneyHuge2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle moneyFull = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    height: 1.1,
  );
  static const TextStyle sectionLabelOrange = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w900,
    color: AppColors.orange800,
    letterSpacing: 1.2,
  );
  static const TextStyle sectionLabelRed = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w900,
    color: AppColors.error,
    letterSpacing: 1.2,
  );
  static const TextStyle statusBanner = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle dateHeaderGrey = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.grey600,
  );
  static const TextStyle moneyLabel = TextStyle(
    fontSize: 12,
    color: AppColors.grey600,
  );
  static const TextStyle moneyLabelBold = TextStyle(
    fontSize: 12,
    color: AppColors.grey600,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle itemDim = TextStyle(
    fontSize: 10.5,
    color: AppColors.grey600,
  );
  static const TextStyle amountValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle amountValueBold = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle moneyRow = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle moneyRowBold = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle sectionHeaderLine = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
    color: AppColors.green800,
  );

  // ══════════════════════════════════════════
  // 📏 LAYOUT
  // ══════════════════════════════════════════
  static const Widget gapXs = AppLayout.gapXs;
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;
  static const Widget gapLg = AppLayout.gapLg;

  static const EdgeInsets padCard = AppLayout.padAll10;
  static const EdgeInsets padCardLg = AppLayout.padAll12;
  static const EdgeInsets padSection = AppLayout.padAll14;
  static const EdgeInsets padPage = AppLayout.padAll12;
  static const EdgeInsets padAll16 = AppLayout.padAll16;
  static const EdgeInsets padFormPage = EdgeInsets.fromLTRB(12, 12, 12, 24);
  static const EdgeInsets padImgHeader = EdgeInsets.fromLTRB(18, 16, 18, 8);
  static const EdgeInsets padImgBody = EdgeInsets.fromLTRB(18, 8, 18, 16);
  static const EdgeInsets padBottomBar = EdgeInsets.fromLTRB(12, 8, 12, 12);
  static const EdgeInsets padListFAB = EdgeInsets.only(
    bottom: 200,
    left: 12,
    right: 12,
  );
  static const EdgeInsets padSummary = EdgeInsets.fromLTRB(10, 4, 10, 20);

  // ── Radius ──
  static const BorderRadius r2 = AppLayout.r4;
  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r5 = BorderRadius.all(Radius.circular(5));
  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r8 = AppLayout.r8;
  static const BorderRadius r9 = BorderRadius.all(Radius.circular(9));
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r13 = BorderRadius.all(Radius.circular(13));
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r16 = AppLayout.r16;
  static const BorderRadius r20 = AppLayout.r20;
  static const BorderRadius r28 = BorderRadius.all(Radius.circular(28));

  static const BorderRadius cardRadius = AppLayout.r12;
  static const BorderRadius cardRadiusLg = AppLayout.r14;
  static const BorderRadius thumbRadius = AppLayout.r8;
  static const BorderRadius chipRadius = AppLayout.r6;
  static const BorderRadius bannerRadius = AppLayout.r14;
  static const BorderRadius pillRadius = AppLayout.r20;
  static const BorderRadius topR13 = BorderRadius.vertical(
    top: Radius.circular(13),
  );
  static const BorderRadius topR14 = BorderRadius.vertical(
    top: Radius.circular(14),
  );

  // ── Icons ──
  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconLg = AppLayout.iconLg;
  static const double iconXl = AppLayout.iconXl;

  // ── Sizes ──
  static const double thumbSale = 76;
  static const double thumbSaleLg = 90;
  static const double thumbSaleH = 76;
  static const double avatarMd = 42;
  static const double avatarSm = 40;
  static const double buttonHeight = AppLayout.buttonHeight;
  static const double buttonHeightSm = 44;
  static const double fabMain = 56;
  static const double fabMainIcon = 26;
  static const double fabAction = 46;
  static const double fabActionIcon = 24;
  static const double imgTileHeight = 110;
  static const double imgTileHeightLg = 200;
  static const double imgTileHeightXLg = 320;
  static const double billCardHeight = 76;
  static const double billCardSubHeight = 26;
  static const double billCardRadius = 8;
  static const double snackbarRadius = 12;

  // ── Nav / Sections ──
  static const double navIconSelected = 26;
  static const double navIconUnselected = 22;

  // ══════════════════════════════════════════
  // 🎭 SHADOWS
  // ══════════════════════════════════════════
  static List<BoxShadow> get card => AppShadows.card;
  static List<BoxShadow> get cardMd => AppShadows.cardMd;
  static List<BoxShadow> get cardLg => AppShadows.cardLg;
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
  static const Duration snackbarShort = AppDurations.snackbarShort;
  static const Duration snackbarLong = AppDurations.snackbarLong;

  static const Duration delayDialog = Duration(milliseconds: 300);
  static const Duration delayClose = Duration(milliseconds: 350);
  static const Duration delayAfter = Duration(milliseconds: 250);
  static const Duration debounce = Duration(milliseconds: 500);
  static const Duration animPulse = Duration(milliseconds: 700);
  static const Duration fabAnim = Duration(milliseconds: 240);
  static const Duration pageAnim = Duration(milliseconds: 200);

  // ══════════════════════════════════════════
  // 📝 STRINGS
  // ══════════════════════════════════════════
  static const String save = AppStrings.save;
  static const String cancel = AppStrings.cancel;
  static const String delete = AppStrings.delete;
  static const String edit = AppStrings.edit;
  static const String ok = AppStrings.ok;
  static const String close = AppStrings.close;
  static const String successMsg = AppStrings.success;
  static const String errorMsg = AppStrings.error;
  static const String warningMsg = AppStrings.warning;
  static const String loading = AppStrings.loading;
  static const String saving = AppStrings.saving;
  static const String noData = AppStrings.noData;
  static const String confirmDelete = AppStrings.confirmDelete;
  static const String clear = AppStrings.clear;
  static const String currency = 'ກີບ';
  static const String dash = '-';

  static const String listPageTitle = 'ລາຍການຂາຍ';
  static const String addPageTitle = 'ບັນທຶກການຂາຍ';
  static const String detailPageTitle = 'ລາຍລະອຽດການຂາຍ';
  static const String debtPageTitle = 'ຢືນຢັນຮັບເງິນໜີ້';
  static const String editImagesTitle = 'ແກ້ໄຂຮູບພາບ';
  static const String summaryPageTitle = 'ສະຫຼຸບການຂາຍ';
  static const String addSaleBtn = 'ບັນທຶກການຂາຍ';
  static const String summaryBtn = 'ສະຫຼຸບການຂາຍ';

  static const String cashLabel = 'ສົດ';
  static const String transferLabel = 'ໂອນ';
  static const String debtLabel = 'ຕິດໜີ້';
  static const String cashFull = 'ເງິນສົດ';
  static const String transferFull = 'ເງິນໂອນ';
  static const String mixedLabel = 'ປະສົມ';

  static const String sectionWoodPicker = 'ເລືອກສິນຄ້າໄມ້';
  static const String sectionPayType = 'ປະເພດການຊຳລະ';
  static const String sectionImages = 'ຮູບພາບຢືນຢັນ';
  static const String sectionDebtInfo = 'ຂໍ້ມູນການຕິດໜີ້';
  static const String sectionPayment = 'ການຈ່າຍເງິນ';
  static const String sectionNote = 'ໝາຍເຫດ';
  static const String sectionSummary = 'ສະຫຼຸບຍອດຂາຍ';
  static const String sectionItems = 'ລາຍການສິນຄ້າ';
  static const String sectionRefund = 'ສະຫຼຸບໃບເງິນທີ່ໄດ້ຮັບ';
  static const String sectionTopProducts = 'ສະຫຼຸບຕາມລາຍການໄມ້ (ຫຼາຍ → ໜ້ອຍ)';
  static const String sectionByDenom = 'ແຍກຕາມໃບລະ';
  static const String sectionPaymentDetail = 'ການຊຳລະ';

  static const String clearForm = 'ລ້າງຟອມ';
  static const String savePayBtn = 'ບັນທຶກການຂາຍ';
  static const String addItemBtn = 'ເພີ່ມລາຍການ';
  static const String confirmReceivePayment = 'ຢືນຢັນການຮັບເງິນ';
  static const String confirmPaidBtn = 'ຢືນຢັນ · ຮັບເງິນແລ້ວ';
  static const String notYetBtn = 'ຍັງບໍ່ຮັບ';
  static const String pendingTitle = 'ຈັດການສະຖານະ';
  static const String pendingSubtitle = 'ເລືອກການດຳເນີນການ';
  static const String confirmPaymentStatus = 'ຢືນຢັນເງິນເຂົ້າ';
  static const String confirmPaymentSub = 'ບັນທຶກວ່າຮັບເງິນຄົບແລ້ວ';
  static const String mismatchBtn = 'ບັນຊີບໍ່ຕົງກັນ';
  static const String mismatchBtnSub = 'ບັນທຶກບັນຫາ · ລໍຖ້າກວດສອບ';
  static const String deleteConfirmPrefix =
      'ຈະລຶບອອກຈາກ Firebase ແລະ Cloudinary ຖາວອນ';
  static const String deleteConfirmMsg = 'ຢືນຢັນການລຶບ?';
  static const String saveImageSuccess = 'ບັນທຶກລົງຄັງຮູບແລ້ວ';
  static const String saveImageError = 'ບໍ່ສາມາດບັນທຶກໄດ້';
  static const String saveToDevice = 'ບັນທຶກລົງເຄື່ອງ';
  static const String noSales = 'ບໍ່ມີລາຍການຂາຍໃນຊ່ວງເວລານີ້';
  static const String noItems = 'ບໍ່ມີລາຍການ';
  static const String noBillData = 'ບໍ່ມີຂໍ້ມູນໃບເງິນສົດ';

  static const String filterAll = 'ທັງໝົດ';
  static const String filterToday = 'ມື້ນີ້';
  static const String filterWeek = 'ອາທິດນີ້';
  static const String filterMonth = 'ເດືອນນີ້';
  static const String filterYear = 'ປີນີ້';

  static const String billCountLabel = 'ນັບແຍກໃບເງິນ (ບັງຄັບ)';
  static const String billCountHint = 'ແຕະ +1 · ກົດຄ້າງ +5 · ແຕະ × ພິມຈຳນວນ';
  static const String billCountDialog = 'ນັບໃບ';
  static const String billCountInput = 'ຈຳນວນໃບ';
  static const String billCountSuffix = 'ໃບ';
  static const String itemsPanelTitle = 'ລາຍການທີ່ເພີ່ມແລ້ວ';
  static const String itemDimPrefix = 'ຂະໜາດ';
  static const String itemDiscountPrefix = 'ລົດ';
  static const String discountLabel = 'ສ່ວນລົດຂອງລາຍການນີ້';
  static const String discountTotal = 'ສ່ວນລົດລວມ';
  static const String netLabel = 'ຍອດສຸດທິ';
  static const String totalLabel = 'ລວມທັງໝົດ';
  static const String totalSales = 'ຍອດຂາຍລວມ';
  static const String qtyLabel = 'ຈຳນວນ';
  static const String priceLabel = 'ລາຄາ';
  static const String pricePerUnit = 'ລົດ/ຕົວ';
  static const String priceUnitSuffix = 'ກີບ';
  static const String helperNet = 'ຍອດຕ້ອງຈ່າຍ';
  static const String changeTitle = 'ເງິນທອນລູກຄ້າ';
  static const String changeMsgPrefix = 'ຮັບມາ';
  static const String changeMsgMid = '− ຍອດ';
  static const String paidExact = 'ຈ່າຍຄົບພໍດີ';
  static const String notPaidYet = 'ລູກຄ້າຍັງບໍ່ຈ່າຍ — ຕ້ອງການຕິດໜີ້ບໍ?';
  static const String notEnoughCash = 'ຍອດບໍ່ຄົບ — ຕ້ອງການໂອນເຕີມບໍ?';
  static const String notEnoughTransfer = 'ຍອດບໍ່ຄົບ — ຕ້ອງການສົດເຕີມບໍ?';
  static const String topUpTransfer = 'ໂອນເຕີມ';
  static const String topUpCash = 'ສົດເຕີມ';
  static const String topUpTransferSub = 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍການໂອນ';
  static const String topUpCashSub = 'ຈ່າຍສ່ວນທີ່ຂາດດ້ວຍເງິນສົດ';
  static const String debtOnlySub = 'ບັນທຶກເປັນໜີ້ · ຈະເກັບພາຍຫຼັງ';
  static const String debtHoldSub = 'ຄ້າງໄວ້ · ຈະເກັບພາຍຫຼັງ';
  static const String topUpSlipLabel = 'ແນບຮູບສະລິບໂອນເຕີມ *';
  static const String topUpCashLabel = 'ແນບຮູບເງິນສົດທີ່ເຕີມ *';

  static const String debtFormTitle = 'ລູກຄ້າຈ່າຍກ່ອນຫຼືບໍ່?';
  static const String debtPaidLabel = 'ຈຳນວນທີ່ຈ່າຍກ່ອນ *';
  static const String debtImgLabel = 'ຮູບເງິນທີ່ຈ່າຍກ່ອນ (ຖ້າມີ)';
  static const String debtImgAddCash = 'ແນບຮູບເງິນສົດ';
  static const String debtImgAddTransfer = 'ແນບຮູບສະລິບ';
  static const String debtApptLabel = 'ນັດວັນຈ່າຍ';
  static const String debtApptLabelPending = 'ນັດວັນຈ່າຍທີ່ເຫຼືອ';
  static const String debtApptPick = 'ເລືອກວັນ/ເລືອກເວລາ';
  static const String debtCustLabel = 'ຂໍ້ມູນລູກຄ້າ';
  static const String debtNameLabel = 'ຊື່ລູກຄ້າ *';
  static const String debtPhoneLabel = 'ເບີໂທ *';
  static const String debtAddrLabel = 'ທີ່ຢູ່ *';
  static const String debtNoteLabel = 'ໝາຍເຫດໜີ້ (ຖ້າມີ)';
  static const String debtBillLabel = 'ຮູບໃບບິນໜີ້ *';
  static const String debtBillHint = 'ຖ່າຍຮູບໃບບິນທີ່ລູກຄ້າຢືນຢັນການຕິດໜີ້';
  static const String debtBillAdd = 'ແນບຮູບໃບບິນໜີ້';
  static const String debtRealLabel = 'ຍອດຕິດໜີ້ຕົວຈິງ';
  static const String debtTotalSales = 'ຍອດຂາຍທັງໝົດ';
  static const String debtPaidPrefix = '-';
  static const String debtPaidLabel2 = 'ຈ່າຍກ່ອນ';

  static const String debtPayTitle = 'ຢືນຢັນຮັບເງິນໜີ້';
  static const String debtPayAmount = 'ຍອດຕິດໜີ້ທີ່ຈະຮັບ';
  static const String debtPayBillView = 'ໃບບິນໜີ້ຕອນສ້າງ';
  static const String debtPayBillHint = 'ແຕະເພື່ອເບິ່ງຂະໜາດເຕັມ';
  static const String debtPayBillSaved = 'ໃບບິນໜີ້ທີ່ແນບໄວ້';
  static const String debtPayType = 'ປະເພດເງິນ *';
  static const String debtPayImgCash = 'ຮູບເງິນສົດທີ່ຮັບມາ *';
  static const String debtPayImgTransfer = 'ຮູບສະລິບໂອນທີ່ຮັບມາ *';
  static const String debtPayImgHint = 'ຕ້ອງແນບຮູບທຸກຄັ້ງເພື່ອຢືນຢັນການຮັບເງິນ';
  static const String debtPayImgEmpty = 'ແຕະເພື່ອແນບຮູບ';
  static const String debtPayOk = 'ຢືນຢັນຮັບເງິນ';
  static const String debtPayAttachFirst = 'ແນບຮູບກ່ອນ';
  static const String debtPaySaving = 'ກຳລັງບັນທຶກ...';
  static const String debtPaySuccess = 'ປິດໜີ້ຮຽບຮ້ອຍ · ຮັບເງິນແລ້ວ';

  static const String alertTitle = 'ຕ້ອງການຂໍ້ມູນ';
  static const String alertTitleError = 'ຜິດພາດ';
  static const String alertTitleWarn = 'ຂາດຂໍ້ມູນ';
  static const String alertMinItem = 'ກະລຸນາເພີ່ມລາຍການຢ່າງໜ້ອຍ 1';
  static const String alertTotalZero = 'ຍອດລວມຕ້ອງ > 0';
  static const String alertMissDebt = 'ກະລຸນາປ້ອນ ຊື່ · ເບີໂທ · ທີ່ຢູ່';
  static const String alertMissDebtBill = 'ກະລຸນາແນບຮູບໃບບິນໜີ້ *';
  static const String alertMissDebtPaid = 'ກະລຸນາໃສ່ ຈຳນວນທີ່ຈ່າຍກ່ອນ';
  static const String alertDebtOverflow = 'ຈ່າຍກ່ອນ ຕ້ອງບໍ່ເກີນ';
  static const String alertNoPayment = 'ກະລຸນາເລືອກ "ຕິດໜີ້"';
  static const String alertShortPayment = 'ເລືອກວິທີຈ່າຍສ່ວນທີ່ຂາດ';
  static const String alertNoBills = 'ກະລຸນານັບແຍກໃບເງິນ';
  static const String alertBillsMismatch = 'ນັບບໍ່ຕົງ';
  static const String alertBillSkip = 'ກະລຸນາແນບຮູບສະລິບ';
  static const String alertCashSkip = 'ກະລຸນາແນບຮູບເງິນສົດ';
  static const String alertCustomerData = 'ກະລຸນາປ້ອນຂໍ້ມູນລູກຄ້າ';
  static const String alertWoodNeed = 'ກະລຸນາເລືອກໄມ້ · ຊະນິດ · ຂະໜາດ';
  static const String alertQtyMin = 'ຈຳນວນຕ້ອງ ≥ 1';
  static const String alertDiscMax = 'ສ່ວນລົດຕ້ອງບໍ່ເກີນລາຄາ';
  static const String alertProductNotFound = 'ບໍ່ພົບສິນຄ້າໃນຄັງ';
  static const String alertImgRequired = 'ຕ້ອງມີຮູບການຊຳລະຢ່າງໜ້ອຍ 1 ຮູບ';
  static const String alertBillOver = 'ເກີນຍອດ';
  static const String alertNotEnough = 'ຍອດເງິນບໍ່ພໍ';
  static const String alertSuccess = 'ສຳເລັດ';
  static const String alertDeleted = 'ລຶບລາຍການຮຽບຮ້ອຍແລ້ວ';
  static const String alertAddedItem = 'ເພີ່ມແລ້ວ';
  static const String alertItemNum = 'ລາຍການທີ';
  static const String alertCleared = 'ລ້າງຟອມຮຽບຮ້ອຍແລ້ວ';
  static const String alertUpdatedNote = 'ອັບເດດໝາຍເຫດແລ້ວ';
  static const String alertMismatchSaved = 'ບັນທຶກບັນຊີບໍ່ຕົງແລ້ວ';
  static const String alertCancelStatus = 'ຍົກເລີກສະຖານະແລ້ວ';
  static const String alertConfirmPaid = 'ຢືນຢັນເງິນເຂົ້າແລ້ວ';
  static const String alertSaveSaleOk = 'ບັນທຶກການຂາຍ';
  static const String alertSaveSaleFail = 'ບັນທຶກບໍ່ສຳເລັດ';
  static const String alertEditImgOk = 'ແກ້ໄຂຮູບຮຽບຮ້ອຍແລ້ວ';
  static const String alertEditImgFail = 'ບໍ່ສາມາດບັນທຶກໄດ້';
  static const String alertFillReason = 'ກະລຸນາປ້ອນເຫດຜົນ';
  static const String alertFillReason2 = 'ປ້ອນເຫດຜົນ...';

  static const String summaryCash = '💵 ເງິນສົດ';
  static const String summaryTransfer = '🏦 ເງິນໂອນ';
  static const String summaryConfirmed = '✓ ເງິນເຂົ້າແລ້ວ';
  static const String summaryPending = '⏳ ລໍຖ້າກວດສອບ';
  static const String summaryMismatch = '⚠ ບັນຊີບໍ່ຕົງ';
  static const String summaryDebt = '📝 ຕິດໜີ້';
  static const String summaryDiscount = '🏷 ສ່ວນລົດລວມ';
  static const String summaryChange = '💰 ເງິນທອນລວມ';
  static const String summaryDiscountDetail = '🏷 ລາຍລະອຽດສ່ວນລົດ';
  static const String summaryChangeDetail = '💰 ລາຍລະອຽດເງິນທອນ';
  static const String summaryAllItems = 'ລາຍການທັງໝົດ';
  static const String summaryAllBills = '💰 ໃບເງິນທັງໝົດ';
  static const String summaryTotalBills = 'ໃບເງິນສົດທີ່ໄດ້ຮັບທັງໝົດ';
  static const String summaryTotalSheets = 'ໃບ ທັງໝົດ';
  static const String summaryOrderUnit = 'ອໍເດີ';
  static const String summaryItemsUnit = 'ລາຍການ';
  static const String summaryPiecesUnit = 'ຊິ້ນ';
  static const String summaryPerSheet = 'ໃບລະ';
  static const String summaryCount = 'ຈຳນວນ';
  static const String summaryTotal = 'ລວມ';
  static const String summaryCountTimes = 'ຄັ້ງ';
  static const String summaryReturnBtn = 'ປັດກັບ';
  static const String summarySwipeHint = 'ປັດກັບ';
  static const String summaryTotalLabel = 'ລວມທັງໝົດ';

  static const String detailEditImages = 'ແກ້ໄຂຮູບພາບ';
  static const String detailDelete = 'ລຶບລາຍການ';
  static const String detailSettings = 'ຕັ້ງຄ່າ';
  static const String detailSaveDevice = 'ບັນທຶກລົງເຄື່ອງ';
  static const String detailNetLabel = 'ຍອດລວມ';
  static const String detailImgLabel = 'ຮູບພາບຢືນຢັນ';
  static const String detailPayLabel = 'ການຊຳລະ';
  static const String detailCashLabel = 'ຮູບເງິນສົດ';
  static const String detailTransferLabel = 'ຮູບສະລິບໂອນ';
  static const String detailBillLabel = 'ຮູບໃບບິນ';
  static const String detailNoImg = 'ບໍ່ມີຮູບ';
  static const String detailZoomHint = 'ກົດເພື່ອຂະຫຍາຍ';
  static const String detailCustomerLabel = 'ຂໍ້ມູນລູກຄ້າຕິດໜີ້';
  static const String detailNoteLabel = 'ໝາຍເຫດ';
  static const String detailMismatchLabel = 'ເຫດຜົນບັນຊີບໍ່ຕົງ';
  static const String detailCashPrefix = 'ຈ່າຍສົດ';
  static const String detailTransferPrefix = 'ຈ່າຍໂອນ';
  static const String detailReceived = 'ຮັບມາ';
  static const String detailChange = 'ເງິນທອນ';
  static const String detailDebtAmount = 'ຍອດຕິດໜີ້';
  static const String detailMethodLabel = 'ວິທີ';
  static const String detailStatusConfirmed = 'ເງິນເຂົ້າແລ້ວ';
  static const String detailStatusMismatch = 'ບັນຊີບໍ່ຕົງກັນ';
  static const String detailStatusPending = 'ແຕະຈັດການ';
  static const String detailStatusDebtPending = 'ແຕະຢືນຢັນຮັບເງິນ';
  static const String detailCancel = 'ຍົກເລີກ';
  static const String detailCloseDialog = 'ປິດ';
  static const String detailEditReason = 'ແກ້ໄຂບັນຊີບໍ່ຕົງ';
  static const String detailMismatchTitle = 'ບັນຊີບໍ່ຕົງກັນ';
  static const String detailSaveReason = 'ບັນທຶກ';
  static const String detailMismatchConfirm = 'ຢືນຢັນ';
  static const String detailReceivedDebt = 'ທ່ານໄດ້ຮັບເງິນໜີ້ທີ່ຄ້າງນີ້ແລ້ວບໍ?';
  static const String detailCustomerPrefix = 'ລູກຄ້າ';
  static const String detailPhonePrefix = 'ເບີໂທ';
  static const String detailAddrPrefix = 'ທີ່ຢູ່';
  static const String detailReason = 'ເຫດຜົນ';

  static const String imgEditHint =
      'ແກ້ໄຂໄດ້ສະເພາະຮູບ — ບໍ່ສາມາດແກ້ລາຄາ / ຈຳນວນ / ລູກຄ້າ';
  static const String imgEditPay = 'ຮູບການຊຳລະ';
  static const String imgEditPaySub = 'ຮູບເງິນສົດ / ສະລິບໂອນ';
  static const String imgEditBill = 'ຮູບໃບບິນ';
  static const String imgEditBillSub = 'ໃບບິນຮ້ານ / ໃບບິນໜີ້';
  static const String imgEditTopUp = 'ຮູບເງິນເຕີມ';
  static const String imgEditTopUpSub = 'ສະລິບ / ສົດເຕີມ';
  static const String imgEditAdd = 'ເພີ່ມຮູບ';
  static const String imgEditNew = 'ໃໝ່';

  static const String pickCamera = 'ຖ່າຍຮູບ';
  static const String pickGallery = 'ຄັງຮູບ';

  static const String woodUnit = 'ໜ່ວຍນັບ';
  static const String woodUnitAll = 'ທັງໝົດ (ໜ່ວຍ)';
  static const String woodName = 'ຊື່ໄມ້ *';
  static const String woodNameHint = 'ເລືອກຊື່ໄມ້';
  static const String woodType = 'ຊະນິດໄມ້ *';
  static const String woodTypeHint = 'ເລືອກຊະນິດ';
  static const String woodSize = 'ຂະໜາດ / ລາຄາ *';
  static const String woodSizeHint = 'ເລືອກຂະໜາດ';
  static const String woodEmpty = 'ຍັງບໍ່ມີລາຍການໄມ້ໃນຄັງ';
  static const String woodAddItem = 'ເພີ່ມລາຍການນີ້';
  static const String woodInStock = 'ຄົງເຫຼືອ';
  static const String woodUnnamed = 'ບໍ່ລະບຸ';
  static const String woodUnnamedType = 'ບໍ່ລະບຸ';
  static const String woodUnnamedName = 'ບໍ່ລະບຸຊື່';
  static const String woodUnnamedType2 = 'ບໍ່ລະບຸຊະນິດ';
  static const String woodStatusAll = 'ທັງໝົດ';

  static const String cardPayment = 'ຈ່າຍແລ້ວ';
  static const String cardSummary = 'ສະຫຼຸບ';
  static const String cardItemsMore = 'ລາຍການອື່ນ';
  static const String cardNoImg = 'ບໍ່ມີຮູບ';
  static const String cardPending = 'ແຕະຈັດການ';
  static const String cardCheck = 'ກວດສອບ';
  static const String cardMismatch = 'ບັນຊີບໍ່ຕົງ';
  static const String cardMismatchEdit = 'ບັນຊີບໍ່ຕົງ · ແຕະແກ້ໄຂ';
  static const String cardDebtConfirm = 'ແຕະຢືນຢັນຮັບເງິນ';
  static const String cardDebtOverflow = 'ຕິດໜີ້';
  static const String cardTotalPrefix = 'ລວມ';
  static const String cardItemsPrefix = 'ລາຍການ';
  static const String cardPiecesPrefix = 'ຊິ້ນ';
  static const String cardTypePrefix = 'ວິທີ: ';
  static const String cardDiscountPrefix = 'ສ່ວນລົດ';
  static const String cardChangePrefix = 'ເງິນທອນ';
  static const String cardMixedPrefix = 'ສົດ';

  static const String previewTitle = 'ໃບສະຫຼຸບການຂາຍ';
  static const String previewSub = 'ກວດເບິ່ງກ່ອນບັນທຶກ';
  static const String previewTotal = 'ຍອດລວມ';
  static const String previewNet = 'ຍອດຂາຍລວມ';
  static const String previewNetLabel = 'ຍອດຂາຍລວມ';
  static const String previewDiscountLabel = 'ສ່ວນລົດ';
  static const String previewItemsUnit = 'ລາຍການ';
  static const String previewBillsPrefix = 'ນັບແຍກໃບເງິນ';
  static const String previewCustLabel = 'ຂໍ້ມູນລູກຄ້າຕິດໜີ້';
  static const String previewApptLabel = 'ນັດຈ່າຍ';
  static const String previewImgLabel = 'ຮູບພາບແນບ';
  static const String previewImgPay = 'ຊຳລະ';
  static const String previewImgBill = 'ໃບບິນ';
  static const String previewImgTopUp = 'ເຕີມ';
  static const String previewImgDebt = 'ຈ່າຍໜີ້';
  static const String previewImgDebtBill = 'ໃບບິນໜີ້';
  static const String previewFooterItems = 'ລາຍການ';
  static const String previewFooterPieces = 'ຊິ້ນ';
  static const String previewTotalQty = 'ລວມ';
  static const String previewReceived = 'ຮັບມາ';
  static const String previewCash = 'ຈ່າຍສົດ';
  static const String previewTransfer = 'ຈ່າຍໂອນ';

  static const String sec1 = '1';
  static const String sec2 = '2';
  static const String sec3 = '3';
  static const String sec4 = '4';
  static const String sec5 = '5';

  static const String langLine = 'ພາສາລາວເທົ່ານັ້ນ · lo_LA';
  static const String batchDelete = 'ຈະລຶບທັງໝົດ';
  static const String itemsSuffix = 'ລາຍການອື່ນ';
  static const String listFilterLabel = 'ກັ່ນກອງ:';
  static const String dashIcon = '·';

  static const List<int> billDenominations = [
    100000,
    50000,
    20000,
    10000,
    5000,
    2000,
    1000,
    500,
  ];

  static const double dialogWidth = 8;
  // ══════════════════════════════════════════
  // ⭐ EXTEND 2 — Round 1 (list + edit_images)
  // ══════════════════════════════════════════

  // ── Opacity factors ──
  static const double overlayOpacity = 0.2;
  static const double fabGlowOpacity = 0.35;
  static const double fabShadowOpacity = 0.5;
  static const double imgSectionBgOpacity = 0.08;
  static const double imgSectionBorderOpacity = 0.25;
  static const double imgSectionSubOpacity = 0.7;

  // ── Border widths ──
  static const double borderWidthNormal = 1.2;
  static const double borderWidthActive = 2.0;

  // ── Sizes — Icons ──
  static const double iconCalendar = 13;
  static const double iconCheckSm = 16;
  static const double iconMenuSmall = 18;
  static const double iconInfoMd = 20;
  static const double iconAddPhoto = 26;
  static const double iconCloseSm = 13;
  static const double iconChevron = 16;
  static const double iconChevronLg = 18;
  static const double iconBadgeCircle = 32;

  // ── Sizes — Lists ──
  static const int perPage = 10;
  static const double scrollLoadMoreThreshold = 200;
  static const double loadingIndicatorSize = 20;
  static const double loadingIndicatorStroke = 2.2;
  static const double loadingBoxSpinner = 18;
  static const double loadingBoxPad = 24;

  // ── Gap ──
  static const Widget gap2 = SizedBox(height: 2, width: 2);
  static const Widget gap3 = SizedBox(height: 3, width: 3);
  static const Widget gap4 = SizedBox(height: 4, width: 4);
  static const Widget gap6 = SizedBox(height: 6, width: 6);
  static const Widget gap10 = SizedBox(height: 10, width: 10);
  static const Widget gap12 = SizedBox(height: 12, width: 12);
  static const Widget gap14 = SizedBox(height: 14, width: 14);
  static const Widget gap90 = SizedBox(height: 90);
  static const Widget gap120 = SizedBox(height: 120);

  // ── Wrap spacing ──
  static const double wrapSpacing = 6.0;
  static const double wrapRunSpacing = 6.0;
  static const double wrapCardSpacing = 5.0;
  static const double wrapCardRunSpacing = 4.0;

  // ── Padding ──
  static const EdgeInsets padFilterRow = EdgeInsets.only(top: 4, bottom: 4);
  static const EdgeInsets padH8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets padDateHeader = EdgeInsets.fromLTRB(4, 10, 4, 6);
  static const EdgeInsets padLoadMore = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets padFabAction = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 12,
  );
  static const EdgeInsets padFilterChip = EdgeInsets.symmetric(horizontal: 4.0);
  static const EdgeInsets padImgCloseBadge = EdgeInsets.all(3);
  static const EdgeInsets padSectionHeaderImg = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets padBadgeTiny = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 1,
  );

  // ── Text Styles ──
  static const TextStyle textEmptyList = TextStyle(
    fontSize: 14,
    color: AppColors.grey600,
  );
  static const TextStyle textFabAction = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
  static const TextStyle textFilterChip = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle textFilterChipSelected = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textInfoHint = TextStyle(
    fontSize: 12,
    color: AppColors.brown800,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle textImgSectionTitle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle textImgSectionSub = TextStyle(fontSize: 11);
  static const TextStyle textImgEditAdd = TextStyle(
    fontSize: 11,
    color: AppColors.brown600,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textBadgeNew = TextStyle(
    color: AppColors.white,
    fontSize: 9,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textLoadingBox = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.brown800,
  );
  // ══════════════════════════════════════════
  // ⭐ EXTEND 3 — Round 2A (widgets)
  // ══════════════════════════════════════════

  // ── Icon sizes เพิ่ม ──
  static const double iconDot4 = 4;
  static const double iconDot5 = 5;
  static const double iconDot6 = 6;
  static const double iconStar11 = 11;
  static const double iconStar12 = 12;
  static const double iconStar13 = 13;
  static const double iconStar15 = 15;
  static const double iconStar20 = 20;
  static const double iconMdLg = 22;
  static const double iconMd24 = 24;
  static const double iconMd26 = 26;

  // ── Sizes สำหรับ widget card ──
  static const double thumbMiniW = 76;
  static const double thumbMiniH = 76;
  static const double iconBtnSmall = 46;
  static const double iconBtnTiny = 28;
  static const double actionBtnH = 40;
  static const double actionStepY = 52;
  static const double actionOffsetY = -18;
  static const double actionOffsetTop = 42;
  static const double badgeCircle = 60;
  static const double pendingIconBadge = 30;
  static const double confirmIconLg = 48;
  static const double checkCircleSm = 16;
  static const double checkCircleMd = 18;
  static const double checkMarkSm = 11;
  static const double checkMarkMd = 13;

  // ── Skeleton sizes ──
  static const double skelCardH = 76;
  static const double skelBarH14 = 14;
  static const double skelBarH15 = 15;
  static const double skelBarH11 = 11;
  static const double skelBarH10 = 10;
  static const double skelBarH13 = 13;
  static const double skelBarW80 = 80;
  static const double skelBarW110 = 110;
  static const double skelBarW120 = 120;
  static const double skelBarW130 = 130;
  static const double skelBarW140 = 140;
  static const double skelBarW160 = 160;
  static const double skelGap4 = 4;
  static const double skelGap6 = 6;
  static const double skelBtnH = 30;

  // ── Bill card sizes ──
  static const double billIconSize = 18;
  static const double billCloseSize = 18;
  static const double billIconClose = 11;
  static const double billSubIcon = 14;
  static const double billChipPadH = 10;
  static const double billChipPadV = 3;
  static const double billChipPadH6 = 6;
  static const double billChipPadV2 = 2;

  // ── Duration ──
  static const Duration skelPulse = Duration(milliseconds: 1200);
  static const Duration swipeClose = Duration(milliseconds: 180);
  static const Duration swipeDelay = Duration(milliseconds: 200);
  static const Duration floatMenu = Duration(milliseconds: 220);

  // ── Opacity ──
  static const double skelPulseMin = 0.5;
  static const double skelPulseMax = 1.0;
  static const double skelShadowOpacity = 0.05;
  static const double pulseStart = 0.3;
  static const double pulseEnd = 0.5;
  static const double previewDashOpacity = 0.4;

  // ── Border widths ──
  static const double borderW1_0 = 1.0;
  static const double borderW1_5 = 1.5;
  static const double borderW1_8 = 1.8;
  static const double borderW2_5 = 2.5;

  // ── Extend TextStyles (สำหรับ widget) ──
  static const TextStyle txPreviewTitle = TextStyle(
    color: AppColors.brown800,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle txPreviewSub = TextStyle(
    color: AppColors.grey500,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const TextStyle txItemCount = TextStyle(
    color: AppColors.brown700,
    fontSize: 11.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle txSectionLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w900,
    color: AppColors.grey500,
    letterSpacing: 1.5,
  );
  static const TextStyle txPreviewItemName = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.bold,
    color: AppColors.black87,
  );
  static const TextStyle txPreviewItemSub = TextStyle(
    fontSize: 11.5,
    color: AppColors.grey600,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle txPreviewItemSubBold = TextStyle(
    fontSize: 11.5,
    color: AppColors.grey600,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle txPreviewItemPrice = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.brown800,
    letterSpacing: 0.2,
  );
  static const TextStyle txPreviewMoneyLabel = TextStyle(
    fontSize: 12.5,
    color: AppColors.grey600,
  );
  static const TextStyle txPreviewMoneyValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.black87,
  );
  static const TextStyle txPreviewMoneyValueBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle txPreviewNetLabel = TextStyle(
    color: AppColors.green800,
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle txPreviewNetValue = TextStyle(
    color: AppColors.green800,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle txPreviewInfoLabel = TextStyle(
    fontSize: 12,
    color: AppColors.grey600,
  );
  static const TextStyle txPreviewInfoValue = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.black87,
  );
  static const TextStyle txPreviewImgText = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.grey700,
  );
  static const TextStyle txPreviewFooter = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.grey600,
  );

  // ── Skeleton card decorations ──
  static const double skelCardRadius = 12;
  static const double skelCardPad = 10;
  static const double skelBoxRadius = 4;
  static const double skelBtnRadius = 8;
}
