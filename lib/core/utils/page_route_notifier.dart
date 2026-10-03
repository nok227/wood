import 'package:flutter/foundation.dart';

class PageRouteNotifier {
  PageRouteNotifier._();
  static final PageRouteNotifier instance = PageRouteNotifier._();

  final ValueNotifier<int> tick = ValueNotifier<int>(0);

  void bump() => tick.value++;
}