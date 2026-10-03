import 'package:flutter/material.dart';

enum MenuKey {
  woodForm('woodForm', 'ເພີ່ມໄມ້', Icons.add_box_outlined),
  woodList('woodList', 'ລາຍການໄມ້', Icons.inventory_2_outlined),
  salesList('salesList', 'ການຂາຍ', Icons.point_of_sale_outlined),
  account('account', 'ບັນຊີ', Icons.account_balance_wallet_outlined),
  wood3d('wood3d', 'ໂມເດວ 3D', Icons.view_in_ar_rounded);

  final String key;
  final String label;
  final IconData icon;
  const MenuKey(this.key, this.label, this.icon);

  static MenuKey? fromKey(String? k) {
    if (k == null) return null;
    for (final m in MenuKey.values) {
      if (m.key == k) return m;
    }
    return null;
  }
}