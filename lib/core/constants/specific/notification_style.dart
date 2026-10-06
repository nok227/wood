import 'package:flutter/material.dart';
import 'package:wood/core/constants/global/app_colors.dart';
import 'package:wood/core/constants/global/app_text_styles.dart';
import 'package:wood/core/constants/global/app_layout.dart';
import 'package:wood/core/constants/global/app_shadows.dart';
import 'package:wood/core/constants/global/app_durations.dart';
import 'package:wood/core/constants/global/app_strings.dart';

/// ══════════════════════════════════════════════
/// 📍 NOTIFICATION STYLE — Feature: Notifications
/// ══════════════════════════════════════════════
class NotificationStyle {
  NotificationStyle._();

  // ══════════ COLORS ══════════
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color brown50 = AppColors.brown50;
  static const Color brown200 = AppColors.brown200;
  static const Color brown400 = AppColors.brown400;
  static const Color brown700 = AppColors.brown700;
  static const Color brown900 = AppColors.brown900;

  static const Color bg = AppColors.bg;
  static const Color surface = AppColors.surface;
  static const Color divider = AppColors.divider;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const Color white = AppColors.white;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey800 = AppColors.grey800;

  static const Color amber200 = AppColors.amber200;
  static const Color amber900 = AppColors.amber900;

  static const Color error = AppColors.error;
  static const Color error700 = AppColors.error700;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color info = AppColors.info;

  // ➕ Extend — badge colors ตาม type
  static const Color typeProductAdd = AppColors.green800;
  static const Color typeProductEdit = AppColors.blue800;
  static const Color typePriceChange = AppColors.orange900;
  static const Color typeSaleAdd = AppColors.brown700;
  static const Color typeSaleDebtAdd = AppColors.orange900;
  static const Color typeSaleConfirm = AppColors.green800;
  static const Color typeSaleMismatch = AppColors.error;
  static const Color typeSaleMismatchClear = AppColors.mismatchClear;
  static const Color typeSaleDelete = AppColors.error;
  static const Color typeDebtPaid = AppColors.green800;
  static const Color typeDebtPartial = AppColors.orange900;
  static const Color typeAccountAdd = AppColors.accountAdd;
  static const Color typeAccountDelete = AppColors.error;

  // ── Opacity factors ──
  static const double tileBgOpacity = 0.06;
  static const double tileBorderOpacity = 0.35;
  static const double iconBadgeBgOpacity = 0.12;
  static const double iconBadgeBorderOpacity = 0.35;

  // ── Border widths ──
  static const double borderWidthRead = 1.0;
  static const double borderWidthUnread = 1.4;

  // ══════════ TEXT STYLES ══════════
  static const TextStyle heading2 = AppTextStyles.heading2;
  static const TextStyle title = AppTextStyles.title;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;
  static const TextStyle caption = AppTextStyles.caption;
  static const TextStyle label = AppTextStyles.label;

  static const TextStyle notiTitle = TextStyle(
    fontSize: 13.5,
    color: AppColors.brown900,
  );
  static const TextStyle notiTitleUnread = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w900,
    color: AppColors.brown900,
  );
  static const TextStyle notiMessage = TextStyle(
    fontSize: 12,
    color: AppColors.grey800,
    height: 1.35,
  );
  static const TextStyle dateGroup = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: AppColors.brown700,
    letterSpacing: 0.3,
  );
  static const TextStyle emptyText = TextStyle(
    color: AppColors.brown400,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle actorEmail = TextStyle(
    fontSize: 10.5,
    color: AppColors.grey600,
  );
  static const TextStyle timeText = TextStyle(
    fontSize: 10.5,
    color: AppColors.grey600,
  );
  static const TextStyle adminBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: AppColors.amber900,
  );

  // ══════════ LAYOUT ══════════
  static const Widget gapXs = AppLayout.gapXs;
  static const Widget gapSm = AppLayout.gapSm;
  static const Widget gapMd = AppLayout.gapMd;

  // ── Gap เพิ่มเติม (alias จาก AppLayout) ──
  static const Widget gap3 = AppLayout.gap3;
  static const Widget gap6 = AppLayout.gap6;
  static const Widget gap10 = AppLayout.gap10;
  static const Widget gap12 = AppLayout.gap12;

  // ── Padding ──
  static const EdgeInsets padCard = AppLayout.padAll12;
  static const EdgeInsets padPage = AppLayout.padAll12;
  static const EdgeInsets padList = EdgeInsets.fromLTRB(12, 8, 12, 24);
  static const EdgeInsets padGroupHeader =
      EdgeInsets.only(top: 8, bottom: 6, left: 4);
  static const EdgeInsets padTileMargin = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets padDismiss = EdgeInsets.only(right: 20);
  static const EdgeInsets padAdminBadge =
      EdgeInsets.symmetric(horizontal: 5, vertical: 1);
  static const EdgeInsets padEmpty = EdgeInsets.all(12);

  // ── Radius ──
  static const BorderRadius r4 = AppLayout.r4;
  static const BorderRadius r10 = AppLayout.r10;
  static const BorderRadius cardRadius = AppLayout.r10;

  // ── Sizes ──
  static const double iconSm = AppLayout.iconSm;
  static const double iconMd = AppLayout.iconMd;
  static const double iconBadge = 38;
  static const double dotSize = 8;
  static const double emptyIconSize = 64;
  static const double iconActorSize = 11;
  static const double iconTimeSize = 10;

  // ── Skeleton sizes ──
  static const double skeletonTitleW = 140;
  static const double skeletonTitleH = 13;
  static const double skeletonMsgH = 11;
  static const double skeletonMetaW = 90;
  static const double skeletonMetaH = 10;

  // ══════════ SHADOWS ══════════
  static List<BoxShadow> get card => AppShadows.card;

  // ══════════ DURATIONS ══════════
  static const Duration fast = AppDurations.fast;
  static const Duration normal = AppDurations.normal;
  static const Duration snackbarShort = AppDurations.snackbarShort;
  static const Duration snackbarLong = AppDurations.snackbarLong;
  static const Duration daysOne = Duration(days: 1);

  // ══════════ STRINGS ══════════
  static const String loading = AppStrings.loading;
  static const String noData = AppStrings.noData;
  static const String cancel = AppStrings.cancel;
  static const String clearBtn = AppStrings.clear;

  static const String pageTitle = 'ແຈ້ງເຕືອນ';
  static const String empty = 'ຍັງບໍ່ມີແຈ້ງເຕືອນ';
  static const String markAllRead = 'ອ່ານທັງໝົດ';
  static const String clearAll = 'ລ້າງທັງໝົດ';
  static const String clearConfirm = 'ລ້າງແຈ້ງເຕືອນ';
  static const String clearConfirmMsg =
      'ຕ້ອງການລ້າງແຈ້ງເຕືອນທັງໝົດທີ່ສະແດງຢູ່ບໍ?\n'
      '(ຈະລ້າງສະເພາະບັນຊີຂອງທ່ານເທົ່ານັ້ນ)';
  static const String today = 'ມື້ນີ້';
  static const String yesterday = 'ມື້ວານນີ້';
  static const String adminLabel = 'Admin';

  // ── Date formats ──
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
}