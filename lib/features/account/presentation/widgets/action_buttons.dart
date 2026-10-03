import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final void Function(String type) onTap;
  const ActionButtons({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(children: [
        Expanded(child: _btn(
          Icons.arrow_downward_rounded, 'ຮັບເງິນ', 'ເງິນເຂົ້າ',
          Colors.green.shade600, Colors.green.shade700, () => onTap('in'),
        )),
        const SizedBox(width: 10),
        Expanded(child: _btn(
          Icons.arrow_upward_rounded, 'ຈ່າຍເງິນ', 'ເບີກໄປໃຊ້',
          Colors.red.shade600, Colors.red.shade700, () => onTap('out'),
        )),
      ]),
    );
  }

  Widget _btn(IconData i, String t, String s, Color c1, Color c2, VoidCallback tap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c1, c2],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: c2.withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(i, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(color: Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.2)),
                const SizedBox(height: 1),
                Text(s, style: TextStyle(color: Colors.white.withOpacity(0.85),
                    fontSize: 10.5, fontWeight: FontWeight.w600)),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}