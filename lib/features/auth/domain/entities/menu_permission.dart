import 'package:flutter/material.dart';

enum MenuKey {
  /// ເພີ່ມໄມ້ໃໝ່ → "post_add" = ແທ່ນ/ໄມ້ + ເຄື່ອງໝາຍບວກ
  /// ສື່ຄວາມໝາຍ "ເພີ່ມສິ່ງຂອງເຂົ້າ" ໄດ້ຊັດ ກວ່າ add_box
  woodForm('woodForm', 'ເພີ່ມໄມ້', Icons.post_add),

  /// ລາຍການໄມ້ໃນຄັງ → "warehouse" = ໂກດສິນຄ້າ/ຄັງເກັບ
  /// ສື່ຄວາມໝາຍ "ຄັງ" ໄດ້ຊັດ ກວ່າ inventory_2
  woodList('woodList', 'ລາຍການໄມ້', Icons.forest_outlined),

  /// ການຂາຍ → "point_of_sale" = ເຄື່ອງຄິດເງິນ/ຈຸດຂາຍ
  /// ຄົງເດີມ ເພາະສື່ຄວາມໝາຍດີຢູ່ແລ້ວ
  salesList('salesList', 'ການຂາຍ', Icons.handshake_outlined),

  /// ບັນຊີ ລາຍຮັບ-ລາຍຈ່າຍ → "receipt_long" = ໃບບິນ/ບັນທຶກຍາວ
  /// ສື່ຄວາມໝາຍ "ບັນຊີ/ລາຍການທຸລະກຳ" ໄດ້ຊັດ ກວ່າ wallet
  account('account', 'ບັນຊີ', Icons.receipt_long_outlined),

  /// ໂມເດວ 3D → "view_in_ar" = ມອງເຫັນໃນພື້ນທີ່ຈິງ (AR)
  /// ຄົງເດີມ ເພາະສື່ຄວາມໝາຍ 3D ໄດ້ດີທີ່ສຸດ
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