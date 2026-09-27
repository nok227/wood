import 'package:flutter/material.dart';

enum AppNotificationType {
  productAdd,
  productEdit,
  priceChange,
  saleAdd,           // ຂາຍສົດ / ໂອນ / ປະສົມ (ຈ່າຍຄົບ)
  saleDebtAdd,       // 🆕 ສ້າງໜີ້ໃໝ່
  saleConfirm,
  saleMismatch,
  saleMismatchClear,
  saleDelete,
  debtPaid,          // ປິດໜີ້ເຕັມ
  debtPartial,       // 🆕 ຈ່າຍໜີ້ບາງສ່ວນ
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
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
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
      case AppNotificationType.saleDebtAdd:      // 🆕
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
      case AppNotificationType.debtPartial:      // 🆕
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
        return const Color(0xFF2E7D32); // ຂຽວ

      case AppNotificationType.productEdit:
        return const Color(0xFF1565C0); // ຟ້າ

      case AppNotificationType.priceChange:
      case AppNotificationType.saleDebtAdd:       // 🆕 ສົ້ມ
      case AppNotificationType.debtPartial:       // 🆕 ສົ້ມ
        return const Color(0xFFE65100);

      case AppNotificationType.saleAdd:
        return const Color(0xFF5D4037); // ນ້ຳຕານ

      case AppNotificationType.saleMismatch:
      case AppNotificationType.saleDelete:
      case AppNotificationType.accountDelete:
        return const Color(0xFFB71C1C); // ແດງ

      case AppNotificationType.saleMismatchClear:
        return const Color(0xFF00695C); // ຂຽວເຂັ້ມ

      case AppNotificationType.accountAdd:
        return const Color(0xFF283593); // ມ່ວງ
    }
  }
}