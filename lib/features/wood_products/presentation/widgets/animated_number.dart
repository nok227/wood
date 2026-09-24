import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🔢 ຕົວເລກວິ່ງ (Count-up animation)
///
/// ໃຊ້:
/// ```dart
/// AnimatedNumber(
///   value: 2500000,
///   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
///   suffix: ' ກີບ',
/// )
/// ```
class AnimatedNumber extends StatefulWidget {
  /// ຄ່າເປົ້າໝາຍທີ່ຈະວິ່ງໄປຮອດ
  final num value;

  /// Style ຂອງຕົວເລກ
  final TextStyle? style;

  /// ເວລາວິ່ງ (ms) — ຄ່າເລີ່ມຕົ້ນ 900
  final int duration;

  /// ຄວາມໜ່ວງ — ຄ່າເລີ່ມຕົ້ນ Curves.easeOutCubic
  final Curve curve;

  /// ຄຳນຳໜ້າ (ເຊັ່ນ '+', '-')
  final String prefix;

  /// ຄຳຕໍ່ທ້າຍ (ເຊັ່ນ ' ກີບ')
  final String suffix;

  /// ຮູບແບບຕົວເລກ — ຄ່າເລີ່ມຕົ້ນ '#,###'
  final String format;

  /// ຈຳນວນຕຳແໜ່ງທົດສະນິຍົມ — ຄ່າເລີ່ມຕົ້ນ 0
  final int decimals;

  /// ວິ່ງໃໝ່ທຸກຄັ້ງທີ່ຄ່າປ່ຽນ — ຄ່າເລີ່ມຕົ້ນ true
  final bool animateOnChange;

  /// ວິ່ງໃໝ່ຕອນ widget ຖືກສ້າງຄັ້ງທຳອິດ — ຄ່າເລີ່ມຕົ້ນ true
  final bool animateOnMount;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = 900,
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.format = '#,###',
    this.decimals = 0,
    this.animateOnChange = true,
    this.animateOnMount = true,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  late NumberFormat _fmt;

  @override
  void initState() {
    super.initState();
    _fmt = NumberFormat(widget.format);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _anim = Tween<double>(
      begin: widget.animateOnMount ? 0 : widget.value.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.animateOnMount) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ ປ່ຽນ format
    if (oldWidget.format != widget.format) {
      _fmt = NumberFormat(widget.format);
    }

    // ✅ ຄ່າປ່ຽນ → ວິ່ງໃໝ່
    if (oldWidget.value != widget.value && widget.animateOnChange) {
      _anim = Tween<double>(
        begin: oldWidget.value.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final v = _anim.value;
        final text = widget.decimals > 0
            ? _fmt.format(v)
            : _fmt.format(v.round());
        return Text(
          '${widget.prefix}$text${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}