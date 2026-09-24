import 'package:flutter/material.dart';

class WaveText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const WaveText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // ⚡ ปรับเวลาลงเหลือ 700ms เพื่อความรวดเร็วและกระฉับกระเฉง ไม่ดียเลย์
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WaveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');
    final int count = characters.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        // 🌊 คำนวณ Delay แบบกระจายตามความยาวข้อความจริง เพื่อไม่ให้ตัวท้ายๆ หลุดขอบเวลา
        final double maxDelay = 0.3; 
        final double delay = count > 1 ? (index / (count - 1)) * maxDelay : 0.0;
        final double durationRatio = 0.7; // ระยะเวลาเคลื่อนไหวต่อตัวอักษร

        // 🚀 TweenSequence ปรับความสูงการเด้งแรงขึ้นเป็น -14.0 (สูงสะใจ เต้น 2 รอบ)
        final Animation<double> animation = TweenSequence<double>([
          // --- รอบที่ 1 (เด้งขึ้น-ลง แรงๆ) ---
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
          TweenSequenceItem(tween: Tween(begin: -14.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 25),
          // --- รอบที่ 2 (เด้งขึ้น-ลง แรงๆ) ---
          // TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
          // TweenSequenceItem(tween: Tween(begin: -14.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 25),

        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay,
              (delay + durationRatio).clamp(0.0, 1.0),
            ),
          ),
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, animation.value),
              child: Text(
                characters[index],
                style: widget.style,
              ),
            );
          },
        );
      }),
    );
  }
}