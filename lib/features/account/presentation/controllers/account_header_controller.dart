import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountHeaderController extends GetxController {
  final scrollCtrl = ScrollController();

  /// ⭐ ປຸ່ມ ຮັບເງິນ/ຈ່າຍເງິນ — ສະແດງ/ຊ່ອນ ຕາມ scroll
  final actionsVisible = true.obs;

  double _lastOffset = 0;

  // ⭐ Hysteresis 2 ຄ່າ → ປ້ອງກັນ jitter
  static const double _hideAt = 80.0; // scroll ລົງເກີນ 80 → ຊ່ອນ
  static const double _showAt = 30.0; // ກັບມາໃຕ້ 30 → ສະແດງ
  static const double _delta = 6.0;   // ຄວາມໄວ ຂັ້ນຕ່ຳ

  @override
  void onInit() {
    super.onInit();
    scrollCtrl.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollCtrl.removeListener(_onScroll);
    scrollCtrl.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollCtrl.hasClients) return;

    final offset = scrollCtrl.offset;
    final delta = offset - _lastOffset;
    _lastOffset = offset;

    // ── ຢູ່ເທິງສຸດ → ສະແດງຕະຫຼອດ ──
    if (offset < _showAt) {
      if (!actionsVisible.value) actionsVisible.value = true;
      return;
    }

    // ── ຊ່ອນ: scroll ລົງ + ເກີນ threshold ເທິງ ──
    if (delta > _delta && offset > _hideAt && actionsVisible.value) {
      actionsVisible.value = false;
    }
    // ── ສະແດງ: scroll ຂຶ້ນ ──
    else if (delta < -_delta && !actionsVisible.value) {
      actionsVisible.value = true;
    }
  }
}