import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_durations.dart';

/// ══════════════════════════════════════════════
/// 📍 WOOD 3D STYLE — Feature: wood_3d
/// ══════════════════════════════════════════════
class Wood3DStyle {
  Wood3DStyle._();

  // ══════════ COLORS ══════════
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
  static const Color black = AppColors.black;
  static const Color black12 = AppColors.black12;
  static const Color black26 = AppColors.black26;
  static const Color black54 = AppColors.black54;
  static const Color black87 = AppColors.black87;
  static const Color transparent = AppColors.transparent;
  static const Color grey50 = AppColors.grey50;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;
  static const Color green700 = AppColors.green700;
  static const Color orange800 = AppColors.orange800;
  static const Color error700 = AppColors.error700;
  static const Color info = AppColors.info;
  static const Color textSecondary = AppColors.textSecondary;

  // ── Wood 3D ──
  static const Color wood3dBg = AppColors.woodBg;
  static const Color wood3dBgAlt = AppColors.bg;
  static const Color woodLight = AppColors.woodLight;
  static const Color woodMid = AppColors.woodMid;
  static const Color woodDark = AppColors.woodDark;
  static const Color woodShadow = AppColors.woodShadow;
  static const Color woodLightGrain = AppColors.woodLightGrain;

  // ── Opacity factors ──
  static const double overlayBgOpacity = 0.4;
  static const double panelShadowOpacity = 0.06;
  static const double chipBorderActive = 0.4;
  static const double dropdownFillOpacity = 0.4;

  // ── Painter opacities ──
  static const double grainDarkOpacity = 0.22;
  static const double grainLightOpacity = 0.12;
  static const double aoOpacity = 0.28;
  static const double aoStrengthMul = 0.28;
  static const double specularOpacity = 0.28;
  static const double specular2Opacity = 0.08;
  static const double edgeShadowOpacity = 0.55;
  static const double edgeHighlightOpacity = 0.10;
  static const double groundShadow1 = 0.22;
  static const double groundShadow2 = 0.08;
  static const double viewBtnBgOpacity = 0.95;

  // ── Lerp factors ──
  static const double lerpGrainDark = 0.35;
  static const double lerpGrainLight = 0.35;
  static const double lerpEdgeShadow = 0.65;
  static const double lerpShadeMul = 0.42;
  static const double lerpShadeRange = 0.58;
  static const double lerpHighlight = 0.10;
  static const double lerpGradientDark = 0.12;

  // ── Border widths ──
  static const double borderW1_0 = 1.0;
  static const double borderW1_2 = 1.2;
  static const double borderW1_5 = 1.5;
  static const double borderW1_8 = 1.8;
  static const double edgeStrokeW = 1.2;
  static const double edgeHighlightW = 0.5;
  static const double arrowStrokeW = 1.5;

  // ── Sizes — Icons ──
  static const double iconStar13 = 13;
  static const double iconStar14 = 14;
  static const double iconStar15 = 15;
  static const double iconStar16 = 16;
  static const double iconDot3 = 3;
  static const double iconDot4 = 4;

  // ── Sizes — Layout ──
  static const double sliderHandleW = 40;
  static const double sliderHandleH = 4;
  static const double viewBtnH = 32;
  static const double viewBtnRadius = 16;
  static const double quickFabIcon = 20;
  static const double labelPadH = 7;
  static const double labelPadV = 3.5;
  static const double chipRowH = 32;
  static const double zoneChipPadH = 6;
  static const double zoneChipPadV = 1;
  static const double dropdownPadH = 12;
  static const double dropdownPadV = 10;
  static const double panelHandlePadV = 6;

  // ── Sizes — Skeleton ──
  static const double skelCardW = 200;
  static const double skelCardH = 160;
  static const double skelCardRadius = 14;
  static const double skelBoxH = 46;
  static const double skelBoxW = 90;
  static const double skelBoxRadius = 6;
  static const double skelBoxRadiusSm = 4;

  // ── Sizes — Painter ──
  static const double cameraDistance = 4.0;
  static const double baseScaleFactor = 0.8;
  static const double grainLineMin = 8;
  static const double grainLineMax = 60;
  static const double grainDivisor = 3;

  // ── Animations (3D) ──
  static const double defaultRotationX = 0.4;
  static const double defaultRotationY = 2.38;
  static const double defaultZoom = 1.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 3.5;
  static const double dragFactor = 0.01;

  // ── Sizes — 3D label placement ──
  static const double labelGap = 10;
  static const double labelPad = 4;
  static const double labelW = 20;
  static const double labelH = 7;
  static const double labelInflate = 3;
  static const double labelOverlapMul = 0.5;

  // ── Wrap spacing ──
  static const double wrapSpacing = 4.0;
  static const double wrapRunSpacing = 4.0;

  // ── Layout — Gaps ──
  static const Widget gap2 = SizedBox(height: 2, width: 2);
  static const Widget gap4 = SizedBox(height: 4, width: 4);
  static const Widget gap5 = SizedBox(height: 5, width: 5);
  static const Widget gap6 = SizedBox(height: 6, width: 6);
  static const Widget gap8 = SizedBox(height: 8, width: 8);
  static const Widget gap10 = SizedBox(height: 10, width: 10);
  static const Widget gap12 = SizedBox(height: 12, width: 12);
  static const Widget gap14 = SizedBox(height: 14, width: 14);

  // ── Padding ──
  static const EdgeInsets padCard = AppLayout.padAll12;
  static const EdgeInsets padPanelRow = EdgeInsets.fromLTRB(14, 0, 14, 8);
  static const EdgeInsets padPanelBottom = EdgeInsets.fromLTRB(14, 2, 14, 14);
  static const EdgeInsets padEmpty = EdgeInsets.all(10);
  static const EdgeInsets padChipRight = EdgeInsets.only(right: 6);
  static const EdgeInsets padChipInner =
      EdgeInsets.symmetric(horizontal: 8, vertical: 0);
  static const EdgeInsets padChipLabel = EdgeInsets.symmetric(horizontal: 2);
  static const EdgeInsets padDropdown =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets padZoneChip =
      EdgeInsets.symmetric(horizontal: 6, vertical: 1);
  static const EdgeInsets padViewBtn = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets padSkeleton = EdgeInsets.fromLTRB(16, 12, 16, 16);
  static const EdgeInsets padSkeletonGap = EdgeInsets.all(12);

  // ── BorderRadius ──
  static const BorderRadius r2 = AppLayout.r4;
  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r6 = AppLayout.r6;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius r12 = AppLayout.r12;
  static const BorderRadius r14 = AppLayout.r14;
  static const BorderRadius r16 = AppLayout.r16;
  static const BorderRadius r20 = AppLayout.r20;

  // ── Text Styles ──
  static const TextStyle txSectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.brown700,
    letterSpacing: 0.2,
  );
  static const TextStyle txChip = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle txChipSelected = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle txPanelHint = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.grey500,
  );
  static const TextStyle txClearBtn = TextStyle(fontSize: 11.5);
  static const TextStyle txInfoLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.brown700,
  );
  static const TextStyle txInfoPrice = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    color: AppColors.green700,
  );
  static const TextStyle txInfoQty = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle txZone = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.brown800,
  );
  static const TextStyle txPlaceholder = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
  );
  static const TextStyle txViewBtn = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle txSkelPlaceholder = TextStyle(
    color: AppColors.textSecondary,
  );

  // ── Durations ──
  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;
  static const Duration viewAnim = Duration(milliseconds: 120);

  // ── Strings ──
  static const String wood3dPlaceholder = 'ພື້ນທີ່ສະແດງໂມເດວໄມ້ 3D';
  static const String dimWidth = 'ກວ້າງ';
  static const String dimLength = 'ຍາວ';
  static const String dimThickness = 'ໜາ';
  static const String noProductsForm =
      'ຍັງບໍ່ມີຂໍ້ມູນໃນຄັງ ກະລຸນາເພີ່ມຂໍ້ມູນກ່ອນ';
  static const String woodTypeLabel = 'ຊະນິດໄມ້';
  static const String unitLabel = 'ໜ່ວຍນັບ';
  static const String nameLabel = 'ຊື່ໄມ້';
  static const String noNameInCategory = 'ບໍ່ມີຊື່ໃນໝວດນີ້';
  static const String pickWoodName = 'ເລືອກຊື່ໄມ້';
  static const String clearSelection = 'ລ້າງການເລືອກ';
  static const String sizeLabelColon = 'ຂະໜາດ:';
  static const String priceLabelColon = 'ລາຄາ:';
  static const String qtyLabelColon = 'ຈຳນວນ:';
  static const String zoneLabelColon = 'ໂຊນ:';
  static const String panelHide = 'ປັດລົງ ຫຼື ແຕະ ເພື່ອຊ່ອນ';
  static const String panelShow = 'ປັດຂຶ້ນ ຫຼື ແຕະ ເພື່ອສະແດງ';
  static const String allFilter = 'ທັງໝົດ';
  static const String currency = 'ກີບ';

  // ── 3D Scene ──
  static const String viewTop = 'ດ້ານເທິງ';
  static const String viewFront = 'ດ້ານໜ້າ';
  static const String viewSide = 'ດ້ານຂ້າງ';
  static const String viewReset = 'ດ້ານສະຫຼຽງ (ເລີ່ມຕົ້ນ)';
  static const String colorOn = 'ສີ';
  static const String colorOff = 'ປິດສີ';
  static const String labelWidth = 'ກວ້າງ';
  static const String labelLength = 'ຍາວ';
  static const String labelThickness = 'ໜາ';
}