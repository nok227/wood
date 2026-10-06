import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 RECIPE STYLE — Feature: Recipe
/// ══════════════════════════════════════════════
class RecipeStyle {
  RecipeStyle._();

  // ══════════ COLORS ══════════
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
  static const Color brown800 = AppColors.brown800;
  static const Color brown900 = AppColors.brown900;

  static const Color bg = AppColors.brown50;
  static const Color surface = AppColors.surface;
  static const Color divider = AppColors.divider;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textHint;
  static const Color black54 = AppColors.black54;

  static const Color white = AppColors.white;
  static const Color grey50 = AppColors.grey50;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;

  static const Color success = AppColors.success;
  static const Color green50 = AppColors.green50;
  static const Color green300 = AppColors.green300;
  static const Color green700 = AppColors.green700;
  static const Color green800 = AppColors.green800;

  static const Color warning = AppColors.warning;
  static const Color amber50 = AppColors.amber50;
  static const Color amber700 = AppColors.amber700;
  static const Color amber800 = AppColors.amber800;
  static const Color amber900 = AppColors.amber900;
  static const Color orange = AppColors.orange;

  static const Color error = AppColors.error;
  static const Color errorRed = AppColors.errorRed;
  static const Color error300 = AppColors.error300;
  static const Color error400 = AppColors.error400;
  static const Color error600 = AppColors.error600;
  static const Color error700 = AppColors.error700;
  static const Color red400 = AppColors.red400;
  static const Color red600 = AppColors.red600;
  static const Color red700 = AppColors.red700;

  // ── Extend — token alias ──
  static const Color freshBorder = AppColors.green300;
  static const Color freshBg = AppColors.green50;
  static const Color freshFg = AppColors.green800;
  static const Color cardBorder = AppColors.brown200;
  static const Color deleteIcon = AppColors.red500;
  static const Color micRecording = AppColors.red600;

  // ── Opacity factors ──
  static const double sectionShadowOpacity = 0.05;
  static const double bottomBarShadowOpacity = 0.08;
  static const double bubbleOpacity = 0.12;
  static const double bubbleBorderOpacity = 0.3;
  static const double pulseBase = 0.3;
  static const double pulseRange = 0.5;
  static const double pulseShadowBase = 0.4;

  // ── Border widths ──
  static const double borderWidthNormal = 1.2;
  static const double borderWidthActive = 2.0;

  // ── Pulse animation values ──
  static const double pulseBlur = 12;
  static const double pulseSpread = 4;

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

  // ── Extend ──
  static const TextStyle recipeName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle ingredients = TextStyle(
    fontSize: 11.5,
    color: AppColors.grey700,
    height: 1.3,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
    color: AppColors.brown700,
  );
  static const TextStyle sectionNumber = TextStyle(
    color: AppColors.white,
    fontSize: 12,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle fieldHint = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.bold,
    color: AppColors.grey600,
  );
  static const TextStyle chipText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle chipTiny = TextStyle(fontSize: 12);
  static const TextStyle statusTab = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle ratingLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.brown700,
  );
  static const TextStyle langLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.brown600,
  );
  static const TextStyle statBubbleValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle statBubbleLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle emptyTitle = TextStyle(
    color: AppColors.brown400,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle emptyHint = TextStyle(
    color: AppColors.grey500,
    fontSize: 12,
  );
  static const TextStyle addImageLabelStyle = TextStyle(
    fontSize: 10,
    color: AppColors.brown600,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle saveBtnText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ── Extend เพิ่มเติม ──
  static const TextStyle chipPreview = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle stepsFieldText = TextStyle(
    fontSize: 14,
    height: 1.5,
  );
  static const TextStyle stepsHintText = TextStyle(
    color: AppColors.grey400,
    fontSize: 13,
    height: 1.5,
  );
  static const TextStyle micBtnText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle emojiThumb = TextStyle(fontSize: 34);
  static const TextStyle emojiFallback = TextStyle(fontSize: 32);
  static const TextStyle noIngredientsText = TextStyle(
    fontSize: 12,
    color: AppColors.grey500,
  );
  static const TextStyle eatenBtnText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
    color: AppColors.green800,
  );
  static const TextStyle eatenBadgeText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );
  static const TextStyle menuDeleteText = TextStyle(
    color: AppColors.errorRed,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle dropdownItemText = TextStyle(
    fontWeight: FontWeight.bold,
  );
  static const TextStyle searchCloseIcon = TextStyle(fontSize: 18);

  // ══════════ LAYOUT ══════════
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;
  static const Widget gapLg = AppLayout.gapLg;

  // ── Gap เพิ่มเติม ──
  static const Widget gap2 = SizedBox(height: 2, width: 2);
  static const Widget gap3 = SizedBox(height: 3, width: 3);
  static const Widget gap4 = SizedBox(height: 4, width: 4);
  static const Widget gap6 = SizedBox(height: 6, width: 6);
  static const Widget gap8 = SizedBox(height: 8, width: 8);
  static const Widget gap10 = SizedBox(height: 10, width: 10);
  static const Widget gap12 = SizedBox(height: 12, width: 12);
  static const Widget gap14 = SizedBox(height: 14, width: 14);
  static const Widget gap80 = SizedBox(height: 80);

  // ── Padding เดิม ──
  static const EdgeInsets padCard = AppLayout.padAll10;
  static const EdgeInsets padPage = AppLayout.padAll12;
  static const EdgeInsets padSection = AppLayout.padAll12;
  static const EdgeInsets padFormPage = EdgeInsets.fromLTRB(12, 12, 12, 120);
  static const EdgeInsets padSectionHeader = EdgeInsets.fromLTRB(12, 10, 12, 10);
  static const EdgeInsets padBottomBar = EdgeInsets.fromLTRB(12, 8, 12, 12);
  static const EdgeInsets padChip = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const EdgeInsets padChipMd = EdgeInsets.symmetric(horizontal: 7, vertical: 3);
  static const EdgeInsets padStatBubble = EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  // ── Padding เพิ่มเติม ──
  static const EdgeInsets padSearchBar = EdgeInsets.fromLTRB(12, 8, 12, 4);
  static const EdgeInsets padFilterTabs = EdgeInsets.fromLTRB(8, 2, 8, 6);
  static const EdgeInsets padStatsRow = EdgeInsets.fromLTRB(12, 0, 12, 6);
  static const EdgeInsets padListFAB = EdgeInsets.fromLTRB(8, 4, 8, 120);
  static const EdgeInsets padListSkeleton = EdgeInsets.fromLTRB(8, 4, 8, 24);
  static const EdgeInsets padCardMargin =
      EdgeInsets.symmetric(vertical: 5, horizontal: 4);
  static const EdgeInsets padFilterChip = EdgeInsets.symmetric(horizontal: 2);
  static const EdgeInsets padVertical10 = EdgeInsets.symmetric(vertical: 10);
  static const EdgeInsets padVertical6 = EdgeInsets.symmetric(vertical: 6);
  static const EdgeInsets padDropdown =
      EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const EdgeInsets padImgBadge = EdgeInsets.all(3);
  static const EdgeInsets padIngredientEmpty = EdgeInsets.only(top: 8);
  static const EdgeInsets padLangRow = EdgeInsets.only(top: 6);
  static const EdgeInsets padBottomBarBtn =
      EdgeInsets.symmetric(vertical: 16);

  // ── Wrap spacing ──
  static const double wrapSpacing = 6.0;
  static const double wrapRunSpacing = 6.0;
  static const double wrapImgSpacing = 8.0;
  static const double wrapCardSpacing = 5.0;
  static const double wrapCardRunSpacing = 4.0;

  // ── Radius ──
  static const BorderRadius r5 = BorderRadius.all(Radius.circular(5));
  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r8 = AppLayout.r8;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r20 = AppLayout.r20;
  static const BorderRadius cardRadius = AppLayout.r12;
  static const BorderRadius chipRadius = AppLayout.r6;
  static const BorderRadius bannerRadius = AppLayout.r10;
  static const BorderRadius sectionRadius = AppLayout.r14;
  static const BorderRadius topR13 =
      BorderRadius.vertical(top: Radius.circular(13));

  // ── Icon sizes ──
  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconLg = AppLayout.iconLg;
  static const double iconXl = AppLayout.iconXl;

  static const double iconXs = 12;
  static const double iconSmMd = 15;
  static const double iconMdSm = 17;
  static const double iconMenuTile = 18;
  static const double iconMdLg = 22;
  static const double iconAdd = 24;
  static const double iconPulse = 20;

  // ── Sizes ──
  static const double thumbRecipe = 84;
  static const double thumbPicker = 84;
  static const double sectionNumberSize = 24;
  static const double imageTileSize = 84;
  static const int maxImages = 3;
  static const double buttonHeight = AppLayout.buttonHeight;
  static const double saveButtonHeight = 48;
  static const double starSize = 32;
  static const double starSm = 11;
  static const double emptyIconLg = 72;
  static const double spinnerSmall = 20;
  static const double spinnerStroke = 2.2;
  static const double thumbPopupSize = 28;
  static const double imgCloseBadge = 12;

  // ── BoxConstraints ──
  static const BoxConstraints starBtnConstraints = BoxConstraints(
    minWidth: 44,
    minHeight: 44,
  );

  // ══════════ SHADOWS ══════════
  static List<BoxShadow> get card => AppShadows.card;
  static List<BoxShadow> get cardMd => AppShadows.cardMd;
  static List<BoxShadow> colored(Color c) => AppShadows.colored(c);
  static List<BoxShadow> get sectionShadow => [
        BoxShadow(
          color: primary.withOpacity(sectionShadowOpacity),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
  static List<BoxShadow> get bottomBarShadow => [
        BoxShadow(
          color: textPrimary.withOpacity(bottomBarShadowOpacity),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ];

  // ══════════ DURATIONS ══════════
  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;
  static const Duration slow = AppDurations.slow;
  static const Duration animFast = AppDurations.animFast;
  static const Duration animNormal = AppDurations.animNormal;
  static const Duration pulseAnim = Duration(milliseconds: 700);
  static const Duration snackbarShort = AppDurations.snackbarShort;
  static const Duration snackbarLong = AppDurations.snackbarLong;

  // ══════════ STRINGS ══════════
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
  static const String search = AppStrings.search;
  static const String clear = AppStrings.clear;

  static const String libraryTitle = 'ຄັງເມນູອາຫານ';
  static const String formTitleAdd = 'ເພີ່ມເມນູໃໝ່';
  static const String formTitleEdit = 'ແກ້ໄຂເມນູ';
  static const String noRecipes = 'ຍັງບໍ່ມີເມນູອາຫານ';
  static const String addRecipe = 'ເພີ່ມເມນູໃໝ່';
  static const String searchHint = 'ຄົ້ນຫາເມນູ ຫຼື ສ່ວນປະກອບ...';
  static const String statusWant = 'ຢາກລອງ';
  static const String statusTried = 'ເຄີຍເຮັດ';
  static const String statusNever = 'ຍັງບໍ່ເຄີຍ';
  static const String markEaten = 'ກິນແລ້ວ';
  static const String markEatenLast = 'ກິນຫຼ້າສຸດ';

  static const String sortLeastRecent = 'ຍັງບໍ່ກິນດົນ';
  static const String sortNewest = 'ເພີ່ມໃໝ່ສຸດ';
  static const String sortHighestRating = 'ຄະແນນສູງສຸດ';

  static const String filterAll = 'ທັງໝົດ';
  static const String filterWant = '⏳ ຢາກລອງ';
  static const String filterTried = '✓ ເຄີຍເຮັດ';
  static const String filterNever = '· ຍັງບໍ່ເຄີຍ';

  static const String notFound = 'ບໍ່ພົບເມນູທີ່ຄົ້ນຫາ';
  static const String emptyLibrary = 'ຍັງບໍ່ມີເມນູອາຫານ';
  static const String clearFilter = 'ລ້າງຕົວກອງ';
  static const String addFirstHint = 'ກົດປຸ່ມ + ເພື່ອເພີ່ມເມນູທຳອິດ';
  static const String deleteConfirmPrefix = 'ລຶບເມນູ "';
  static const String deleteConfirmSuffix = '" ອອກບໍ?';

  static const String statAll = 'ທັງໝົດ';
  static const String statWant = 'ຢາກລອງ';
  static const String statNever = 'ຍັງບໍ່ເຄີຍ';

  static const String sectionBasic = 'ຊື່ ແລະ ປະເພດ';
  static const String sectionIngredients = 'ສ່ວນປະກອບ';
  static const String sectionSteps = 'ສູດອາຫານ';
  static const String sectionStatus = 'ສະຖານະ ແລະ ຄະແນນ';
  static const String sectionImages = 'ຮູບພາບ (ສູງສຸດ 3)';
  static const String sectionNote = 'ໝາຍເຫດ';

  static const String nameLabel = 'ຊື່ເມນູ *';
  static const String nameHint = 'ຕົວຢ່າງ: ຕົ້ມຍຳ, ຜັດໄທ...';
  static const String suggestionLabel = 'ຄຳແນະນຳ (ກົດເພື່ອເພີ່ມ):';
  static const String categoryLabel = 'ປະເພດອາຫານ:';
  static const String ingredientHint = 'ເຊັ່ນ: ໝູ, ຜັກ, ນ້ຳປາ';
  static const String noIngredients = 'ຍັງບໍ່ໄດ້ໃສ່ສ່ວນປະກອບ';
  static const String ratingLabel = 'ຄະແນນຄວາມມັກ';
  static const String noteHint = 'ໝາຍເຫດເພີ່ມເຕີມ (ຖ້າມີ)';
  static const String addImageLabel = 'ເພີ່ມຮູບ';
  static const String saveEditBtn = 'ບັນທຶກການແກ້ໄຂ';
  static const String saveNewBtn = '💾 ບັນທຶກເມນູ';

  static const String micStart = 'ກົດເພື່ອເວົ້າ (ລາວ)';
  static const String micStop = 'ກຳລັງຟັງ... ກົດເພື່ອຢຸດ';
  static const String langLabel = 'ພາສາລາວເທົ່ານັ້ນ · lo_LA';

  static const String nameRequired = 'ກະລຸນາໃສ່ຊື່ເມນູ';
  static const String maxImagesMsg = 'ໃສ່ໄດ້ສູງສຸດ 3 ຮູບ';
  static const String unsupported = 'ບໍ່ຮອງຮັບ';
  static const String unsupportedMsg = 'ອຸປະກອນນີ້ບໍ່ຮອງຮັບການພິມສຽງ';
  static const String errorStartingMic = 'ບໍ່ສາມາດເລີ່ມຟັງໄດ້';
  static const String savedNew = 'ເພີ່ມເມນູຮຽບຮ້ອຍແລ້ວ';
  static const String savedEdit = 'ແກ້ໄຂຮຽບຮ້ອຍແລ້ວ';

  static const String stepsHint =
      'ພິມ ຫຼື ກົດໄມ 🎤 ເວົ້າເປັນພາສາລາວ...\n\n'
      'ຕົວຢ່າງ:\n'
      '1. ຕັ້ງໝໍ້ ໃສ່ນ້ຳພໍປະມານ\n'
      '2. ປຸງລົດດ້ວຍ ນ້ຳປາ, ນ້ຳຕານ, ໝາກນາວ\n'
      '3. ຕົ້ມໃຫ້ເດືອດ 10 ນາທີ\n'
      '4. ຊີມລົດ ແລ້ວຕັກໃສ່ຈານ';

  static const List<String> nameSuggestions = [
    'ຕົ້ມ', 'ຜັດ', 'ຍ່າງ', 'ປີ້ງ',
    'ລາບ', 'ຍຳ', 'ແກງ', 'ຂົ້ວ',
    'ຂອງຫວານ', 'ຂອງກິນ',
  ];
}