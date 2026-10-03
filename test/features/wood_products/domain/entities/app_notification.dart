import 'package:flutter/material.dart';

enum AppNotificationType {
  productAdd,
  productEdit,
  priceChange,
  saleAdd,
  saleDebtAdd,
  saleConfirm,
  saleMismatch,
  saleMismatchClear,
  saleDelete,
  debtPaid,
  debtPartial,
  accountAdd,
  accountDelete,
}

enum NotificationAudience { admin, user, all }

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final String actorEmail;
  final bool actorIsAdmin;
  final NotificationAudience audience;
  final DateTime date;
  final bool isRead;
  final String? targetId;
  final Map<String, dynamic>? meta;
  final List<String> readBy;
  final List<String> deletedBy;
  final DateTime expireAt; // 🆕 TTL — ລຶບອັດຕະໂນມັດຫຼັງ 7 ວັນ

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.actorEmail,
    required this.actorIsAdmin,
    required this.audience,
    required this.date,
    this.isRead = false,
    this.targetId,
    this.meta,
    this.readBy = const [],
    this.deletedBy = const [],
    required this.expireAt, // 🆕
  });

  bool isReadBy(String? uid) {
    if (uid == null || uid.isEmpty) return isRead;
    return readBy.contains(uid);
  }

  bool isDeletedBy(String? uid) {
    if (uid == null || uid.isEmpty) return false;
    return deletedBy.contains(uid);
  }

  AppNotification copyWith({
    bool? isRead,
    List<String>? readBy,
    List<String>? deletedBy,
  }) =>
      AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        actorEmail: actorEmail,
        actorIsAdmin: actorIsAdmin,
        audience: audience,
        date: date,
        isRead: isRead ?? this.isRead,
        targetId: targetId,
        meta: meta,
        readBy: readBy ?? this.readBy,
        deletedBy: deletedBy ?? this.deletedBy,
        expireAt: expireAt,
      );

  IconData get icon {
    switch (type) {
      case AppNotificationType.productAdd:
        return Icons.add_box_outlined;
      case AppNotificationType.productEdit:
        return Icons.edit_outlined;
      case AppNotificationType.priceChange:
        return Icons.price_change_outlined;
      case AppNotificationType.saleAdd:
        return Icons.point_of_sale_outlined;
      case AppNotificationType.saleDebtAdd:
        return Icons.receipt_long_outlined;
      case AppNotificationType.saleConfirm:
        return Icons.check_circle_outline;
      case AppNotificationType.saleMismatch:
        return Icons.warning_amber_rounded;
      case AppNotificationType.saleMismatchClear:
        return Icons.restore;
      case AppNotificationType.saleDelete:
        return Icons.delete_outline;
      case AppNotificationType.debtPaid:
        return Icons.verified_outlined;
      case AppNotificationType.debtPartial:
        return Icons.payments_outlined;
      case AppNotificationType.accountAdd:
        return Icons.account_balance_wallet_outlined;
      case AppNotificationType.accountDelete:
        return Icons.money_off_outlined;
    }
  }

  Color get color {
    switch (type) {
      case AppNotificationType.productAdd:
      case AppNotificationType.saleConfirm:
      case AppNotificationType.debtPaid:
        return const Color(0xFF2E7D32);

      case AppNotificationType.productEdit:
        return const Color(0xFF1565C0);

      case AppNotificationType.priceChange:
      case AppNotificationType.saleDebtAdd:
      case AppNotificationType.debtPartial:
        return const Color(0xFFE65100);

      case AppNotificationType.saleAdd:
        return const Color(0xFF5D4037);

      case AppNotificationType.saleMismatch:
      case AppNotificationType.saleDelete:
      case AppNotificationType.accountDelete:
        return const Color(0xFFB71C1C);

      case AppNotificationType.saleMismatchClear:
        return const Color(0xFF00695C);

      case AppNotificationType.accountAdd:
        return const Color(0xFF283593);
    }
  }
}