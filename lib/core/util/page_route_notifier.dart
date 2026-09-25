import 'package:flutter/foundation.dart';

/// 🔔 Global Notifier — bump on route/tab change
///
/// WaveText ແລະ AnimatedNumber ຈະຟັງ notifier ນີ້
/// ເພື່ອ replay animation ທຸກຄັ້ງທີ່ໜ້ານັ້ນກາຍມາເຫັນ
class PageRouteNotifier {
  PageRouteNotifier._();
  static final PageRouteNotifier instance = PageRouteNotifier._();

  final ValueNotifier<int> tick = ValueNotifier<int>(0);

  void bump() => tick.value++;
}