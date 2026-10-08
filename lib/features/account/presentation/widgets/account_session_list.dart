import 'package:flutter/material.dart';

import 'package:wood/core/constants/specific/account_style.dart';
import 'package:wood/features/account/presentation/models/session_group.dart';

import '../../domain/entities/account_transaction.dart';
import 'account_session_card.dart';

class AccountSessionList extends StatelessWidget {
  final List<SessionGroup> groups;
  final bool isAdmin;
  final ScrollController scrollCtrl;
  final String Function(DateTime) formatTime;
  final void Function(AccountTransaction) onDelete;

  const AccountSessionList({
    super.key,
    required this.groups,
    required this.isAdmin,
    required this.scrollCtrl,
    required this.formatTime,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: AccountStyle.padList,
      itemCount: groups.length,
      itemBuilder: (_, i) => AccountSessionCard(
        group: groups[i],
        isAdmin: isAdmin,
        formatTime: formatTime,
        onDelete: onDelete,
      ),
    );
  }
}