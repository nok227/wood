import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/home_style.dart';
import 'package:wood/features/wood_3d/presentation/pages/wood_3d_page.dart';

class Lazy3DWrapper extends StatefulWidget {
  final RxBool? swipeLock;
  const Lazy3DWrapper({super.key, this.swipeLock});

  @override
  State<Lazy3DWrapper> createState() => _Lazy3DWrapperState();
}

class _Lazy3DWrapperState extends State<Lazy3DWrapper>
    with AutomaticKeepAliveClientMixin {
  bool _ready = false;

  /// Bridge: RxBool → ValueNotifier
  /// (เพราะ Wood3DPage ยังรับ ValueNotifier<bool>?)
  late final ValueNotifier<bool> _lockVN;
  Worker? _lockWorker;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _lockVN = ValueNotifier<bool>(widget.swipeLock?.value ?? false);

    if (widget.swipeLock != null) {
      _lockWorker = ever(
        widget.swipeLock!,
        (v) => _lockVN.value = v,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _lockWorker?.dispose();
    _lockVN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ready) {
      return const ColoredBox(
        color: HomeStyle.brown50,
        child: Center(
          child: CircularProgressIndicator(color: HomeStyle.primary),
        ),
      );
    }
    return Wood3DPage(swipeLock: _lockVN);
  }
}