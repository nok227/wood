import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 WOOD STYLE — Feature: wood_products ONLY
/// (wood_3d ແຍກໄປໃຊ້ wood_3d_style.dart)
///
/// ไฟล์ที่เรียกใช้ (11 ไฟล์):
///   pages: wood_product_form_page, wood_product_list_page,
///          wood_gallery_page
///   widgets: wood_form_image_picker, wood_form_section,
///            wood_form_zone_selector, wood_list_filter_bar,
///            wood_list_group, wood_list_product_card,
///            wood_list_skeleton, wood_product_preview_card
/// ══════════════════════════════════════════════
class WoodStyle {
  WoodStyle._();

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
  static const Color brown600 = AppColors.brown600;
  static const Color brown700 = AppColors.brown700;
  static const Color brown800 = AppColors.brown800;
  static const Color brown900 = AppColors.brown900;

  static const Color bg = AppColors.grey50;
  static const Color surface = AppColors.white;
  static const Color divider = AppColors.divider;
  static const Color white = AppColors.white;
  static const Color black = AppColors.black;
  static const Color transparent = AppColors.transparent;
  static const Color white24 = AppColors.white24;
  static const Color white54 = AppColors.white54;
  static const Color black12 = AppColors.black12;
  static const Color black54 = AppColors.black54;
  static const Color black87 = AppColors.black87;

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
  static const Color green50 = AppColors.green50;
  static const Color green100 = AppColors.green100;
  static const Color green300 = AppColors.green300;
  static const Color green400 = AppColors.green400;
  static const Color green600 = AppColors.green600;
  static const Color green700 = AppColors.green700;
  static const Color green800 = AppColors.green800;

  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color error600 = AppColors.error600;
  static const Color error700 = AppColors.error700;
  static const Color errorRed = AppColors.errorRed;
  static const Color red600 = AppColors.red600;

  static const Color warning = AppColors.warning;
  static const Color amber50 = AppColors.amber50;
  static const Color amber100 = AppColors.amber100;
  static const Color amber300 = AppColors.amber300;
  static const Color amber400 = AppColors.amber400;
  static const Color amber900 = AppColors.amber900;

  static const Color info = AppColors.info;
  static const Color blue = AppColors.blue;
  static const Color blueAccent = AppColors.blueAccent;
  static const Color tealAccent = AppColors.tealAccent;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textHint;

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

  // ── Alias ຈາກ Global (ເຄີຍຊ້ຳ) ──
  static const TextStyle groupHeader = AppTextStyles.groupHeader;
  static const TextStyle subHeaderTitle = AppTextStyles.subHeaderTitle;
  static const TextStyle previewTitle = AppTextStyles.previewTitle;
  static const TextStyle filterChip = AppTextStyles.filterChip;
  static const TextStyle filterTitle = AppTextStyles.filterTitle;
  static const TextStyle cardLabel = AppTextStyles.cardLabel;
  static const TextStyle cardValue = AppTextStyles.cardValue;
  static const TextStyle priceLabel = AppTextStyles.priceLabel;
  static const TextStyle zoneChipText = AppTextStyles.zoneChipText;

  // ── Extend (wood-specific) ──
  static const TextStyle sizeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.green700,
  );
  static const TextStyle formLabel = TextStyle(
    color: AppColors.grey600,
    fontSize: 14,
  );
  static const TextStyle suggestionHeader = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.brown400,
  );
  static const TextStyle suggestionChip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.brown700,
  );
  static const TextStyle zoneText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: AppColors.black87,
  );
  static const TextStyle previewEditBadge = TextStyle(
    color: AppColors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
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
  static const EdgeInsets padSection = AppLayout.padAll12;
  static const EdgeInsets padForm = AppLayout.padAll16;
  static const EdgeInsets padPage = EdgeInsets.all(8);

  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r5 = BorderRadius.all(Radius.circular(5));
  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r8 = AppLayout.r8;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r11 =
      BorderRadius.vertical(top: Radius.circular(11));
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r16 = AppLayout.r16;
  static const BorderRadius r20 = AppLayout.r20;

  static const BorderRadius cardRadius = AppLayout.r12;
  static const BorderRadius chipRadius = AppLayout.r6;

  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconLg = AppLayout.iconLg;

  static const double thumbList = 72;
  static const double thumbListH = 148;
  static const double thumbPreview = 60;
  static const double thumbPicker = 72;

  static const double buttonHeight = AppLayout.buttonHeight;

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
  static const Duration sh = Duration(milliseconds: 150);
  static const Duration page = Duration(milliseconds: 250);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration debounce = Duration(milliseconds: 800);

  // ══════════════════════════════════════════
  // 📝 STRINGS
  // ══════════════════════════════════════════
  static const String save = AppStrings.save;
  static const String cancel = AppStrings.cancel;
  static const String delete = AppStrings.delete;
  static const String edit = AppStrings.edit;
  static const String successMsg = AppStrings.success;
  static const String errorMsg = AppStrings.error;
  static const String warningMsg = AppStrings.warning;
  static const String loading = AppStrings.loading;
  static const String saving = AppStrings.saving;
  static const String noData = AppStrings.noData;
  static const String confirmDelete = AppStrings.confirmDelete;
  static const String all = 'ທັງໝົດ';
  static const String currency = 'ກີບ';
  static const String dash = '-';
  static const String noName = 'ບໍ່ລະບຸຊື່';
  static const String noType = 'ບໍ່ລະບຸຊະນິດ';
  static const String notSpecified = 'ບໍ່ລະບຸ';
  static const String newBadge = 'ລ່າສຸດ';
  static const String newImg = 'ໃໝ່';

  static const String formTitleAdd = 'ເພີ່ມໄມ້ໃໝ່';
  static const String formTitleEdit = 'ແກ້ໄຂຂໍ້ມູນໄມ້';
  static const String noProducts = 'ຍັງບໍ່ມີຂໍ້ມູນສິນຄ້າໄມ້';
  static const String noFiltered = 'ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ';

  static const String secImages = 'ຮູບໄມ້ (ສູງສຸດ 6 ຮູບ)';
  static const String secWoodType = 'ຊະນິດໄມ້';
  static const String secName = 'ຊື່ໄມ້';
  static const String secZone = 'ໂຊນ';
  static const String secSize = 'ຂະໜາດ';
  static const String secQtyUnit = 'ຈຳນວນ ແລະ ໜ່ວຍນັບ';
  static const String secPrice = 'ລາຄາຂາຍ';
  static const String secNote = 'ໝາຍເຫດ';

  static const String width = 'ກວ້າງ';
  static const String length = 'ຍາວ';
  static const String thickness = 'ໜາ';
  static const String sizeUnitLabel = 'ໜ່ວຍຂະໜາດ';
  static const String qtyLabel = 'ຈຳນວນ';
  static const String unitLabel = 'ໜ່ວຍນັບ';
  static const String unitHint = 'ເລືອກໜ່ວຍນັບ';
  static const String unitOther = 'ອື່ນໆ';
  static const String customUnit = 'ລະບຸໜ່ວຍນັບ';
  static const String priceLabelInput = 'ລາຄາຂາຍ xxx ກີບ';
  static const String noteHint =
      'ໝາຍເຫດເພີ່ມເຕີມ (ຖ້າມີ) — ເຊັ່ນ ສີໄມ້, ຄຸນນະພາບ, ຂໍ້ຄວນລະວັງ';
  static const String saveAdd = 'ບັນທຶກ';
  static const String saveEdit = 'ບັນທຶກແກ້ໄຂ';
  static const String prevInput = 'ເຄີຍປ້ອນ';
  static const String cameraOrGallery = 'ກ້ອງ/ຄັງ';
  static const String savingProgress = 'ກຳລັງບັນທຶກ...';
  static const String savedNew = 'ບັນທຶກຂໍ້ມູນແລ້ວ';
  static const String savedEdit = 'ແກ້ໄຂຂໍ້ມູນແລ້ວ';
  static const String zoneSelected = 'ເລືອກແລ້ວ';
  static const String zoneUnit = 'ໂຊນ';
  static const String typePrefix = 'ຊະນິດ: ';
  static const String sizeLabel = 'ຂະໜາດ';
  static const String priceLabelPreview = 'ລາຄາ: ';
  static const String typeCountUnit = 'ຊະນິດ';
  static const String itemsCountUnit = 'ລາຍການ';
  static const String sizesCountUnit = 'ຂະໜາດ';
  static const String filterLabel = 'ກັ່ນກອງ:';
  static const String note = 'ໝາຍເຫດ';
  static const String previewTitleText = 'ກວດເບິ່ງຂໍ້ມູນກ່ອນບັນທຶກ';
  static const String editBadge = 'ແກ້ໄຂ';
  static const String imagesLabel = 'ຮູບພາບ';
  static const String priceLabelFull = 'ລາຄາຂາຍ';
  static const String deleteTitle = 'ຢືນຢັນການລຶບ';
  static const String deleteMsgPrefix = 'ຕ້ອງການລຶບ "';
  static const String deleteMsgSuffix = '" ແມ່ນຫຼືບໍ່?';
    // ══════════════════════════════════════════
  // ⭐ EXTEND 2 — Round A (gallery + list)
  // ══════════════════════════════════════════

  // ── Opacity factors ──
  static const double opacityHeaderBadge = 0.25;
  static const double opacityHeaderSub = 0.85;
  static const double opacityGradientEnd = 0.75;
  static const double opacityGlow = 0.45;
  static const double opacitySubBorder = 0.35;
  static const double opacitySubInner = 0.15;
  static const double opacityCardShadow = 0.05;

  // ── Border widths ──
  static const double borderW1_0 = 1.0;
  static const double borderW1_2 = 1.2;
  static const double borderW2_0 = 2.0;

  // ── Sizes — Gallery ──
  static const double galleryThumbW = 62;
  static const double galleryGap = 8;  
  static const double galleryHeight = 100;
  static const double galleryErrorLg = 48;
  static const double galleryErrorSm = 20;
  static const double galleryPlaceholderSize = 14;
  static const double galleryPlaceholderStroke = 2;
  static const double galleryGlowBlur = 8;

  // ── Sizes — List ──
  static const int perPage = 10;
  static const double listThreshold = 50;
  static const double pageLoadPadV = 24;
  static const double headerRadius = 11;
  static const double badgeRadius = 10;
  static const double badgePadH = 8;
  static const double badgePadV = 3;
  static const double subBadgePadH = 6;
  static const double subBadgePadV = 1;
  static const double groupMarginBottom = 12;

  // ── Widget gaps ──
  static const Widget gap2 = SizedBox(height: 2, width: 2);
  static const Widget gap3 = SizedBox(height: 3, width: 3);
  static const Widget gap4 = SizedBox(height: 4, width: 4);
  static const Widget gap5 = SizedBox(height: 5, width: 5);
  static const Widget gap6 = SizedBox(height: 6, width: 6);
  static const Widget gap8 = SizedBox(height: 8, width: 8);
  static const Widget gap10 = SizedBox(height: 10, width: 10);
  static const Widget gap12 = SizedBox(height: 12, width: 12);

  // ── Padding — Gallery ──
  static const EdgeInsets padGallery =
      EdgeInsets.symmetric(vertical: 10, horizontal: 8);
  static const EdgeInsets padGalleryBadge =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  // ── Padding — List ──
  static const EdgeInsets padListPage = EdgeInsets.all(8);
  static const EdgeInsets padGroupHeader =
      EdgeInsets.symmetric(horizontal: 12, vertical: 9);
  static const EdgeInsets padGroupBody =
      EdgeInsets.fromLTRB(10, 4, 10, 8);
  static const EdgeInsets padSubHeader =
      EdgeInsets.symmetric(horizontal: 10, vertical: 6);
  static const EdgeInsets padFilterBar = EdgeInsets.fromLTRB(12, 8, 12, 10);
  static const EdgeInsets padFilterHeader = EdgeInsets.all(5);

  // ── Radius ──
  static const BorderRadius galleryThumbR = BorderRadius.all(Radius.circular(8));
  static const BorderRadius galleryThumbRSm =
      BorderRadius.all(Radius.circular(6));
  static const BorderRadius galleryBadgeR =
      BorderRadius.all(Radius.circular(12));

  // ── Durations ──
  static const Duration galleryAnim = Duration(milliseconds: 250);

  // ── Text Styles ──
  static const TextStyle txGalleryCounter = TextStyle(fontSize: 13);
  static const TextStyle txEmptyState = TextStyle(fontSize: 14);
  static const TextStyle txFilterLabel = TextStyle(fontSize: 12);
  static const TextStyle txFilterLabelSel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle txGroupTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
  );
  static const TextStyle txGroupSub = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle txGroupCount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle txSubHeader = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle txSubCount = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  // ── Strings เพิ่ม ──
  static const String noProductsList = 'ຍັງບໍ່ມີຂໍ້ມູນສິນຄ້າໄມ້';
  static const String noFilteredList = 'ບໍ່ພົບຂໍ້ມູນໄມ້ທີ່ເລືອກ';
  static const String typeCountSuffix = ' ຊະນິດ · ';
  static const String itemCountSuffix = ' ລາຍການ';
  static const String sizeCountSuffix = ' ຂະໜາດ';
  static const String typePrefixLabel = 'ຊະນິດ: ';
}