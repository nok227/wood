import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/features/home/presentation/controllers/home_controller.dart';
import 'package:wood/features/wood_3d/presentation/pages/wood_3d_page.dart';

class Lazy3DWrapper extends StatefulWidget {
  final RxBool? swipeLock;
  final int tabIndex;
  final HomeController home;

  const Lazy3DWrapper({
    super.key,
    this.swipeLock,
    required this.tabIndex,
    required this.home,
  });

  @override
  State<Lazy3DWrapper> createState() => _Lazy3DWrapperState();
}

class _Lazy3DWrapperState extends State<Lazy3DWrapper>
    with AutomaticKeepAliveClientMixin {
  bool _ready = false;

  /// Bridge 2 ทาง: RxBool (HomeController) ⇄ ValueNotifier (Wood3DPage)
  late final ValueNotifier<bool> _lockVN;
  Worker? _lockWorker;
  VoidCallback? _vnListener;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _lockVN = ValueNotifier<bool>(widget.swipeLock?.value ?? false);

    final rx = widget.swipeLock;
    if (rx != null) {
      // ── RxBool → VN (external change) ──
      _lockWorker = ever(rx, (v) {
        if (_lockVN.value != v) _lockVN.value = v;
      });

      // ── VN → HomeController (Wood3DController เขียนกลับ) ──
      _vnListener = () {
        widget.home.setTabLock(widget.tabIndex, _lockVN.value);
      };
      _lockVN.addListener(_vnListener!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    if (_vnListener != null) _lockVN.removeListener(_vnListener!);
    _lockWorker?.dispose();
    _lockVN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ready) {
      return ColoredBox(
        color: HomeStyle.brown50,
        child: Center(
          child: CircularProgressIndicator(color: HomeStyle.primary),
        ),
      );
    }
    return Wood3DPage(swipeLock: _lockVN);
  }
}