import 'package:flutter/material.dart';
import 'package:wood/features/wood_3d/presentation/pages/wood_3d_page.dart';

class Lazy3DWrapper extends StatefulWidget {
  final ValueNotifier<bool>? swipeLock;
  const Lazy3DWrapper({super.key, this.swipeLock});

  @override
  State<Lazy3DWrapper> createState() => _Lazy3DWrapperState();
}

class _Lazy3DWrapperState extends State<Lazy3DWrapper>
    with AutomaticKeepAliveClientMixin {
  bool _ready = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ready) {
      return const ColoredBox(
        color: Color(0xFFEFEBE9),
        child: Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }
    return Wood3DPage(swipeLock: widget.swipeLock);
  }
}