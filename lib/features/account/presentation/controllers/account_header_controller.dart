import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/account_style.dart';

class AccountHeaderController extends GetxController {
  final scrollCtrl = ScrollController();
  final bannerVisible = true.obs;

  double _lastOffset = 0;

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

    if (offset < AccountStyle.scrollThreshold) {
      if (!bannerVisible.value) bannerVisible.value = true;
      return;
    }
    if (delta > AccountStyle.scrollDelta && bannerVisible.value) {
      bannerVisible.value = false;
    } else if (delta < -AccountStyle.scrollDelta && !bannerVisible.value) {
      bannerVisible.value = true;
    }
  }
}