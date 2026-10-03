import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wood/core/widgets/animated_number.dart';
import '../controllers/account_controller.dart';

class BalanceBanner extends StatelessWidget {
  final AccountController controller;
  const BalanceBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bal = controller.balance;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade700, Colors.brown.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white70, size: 12),
                SizedBox(width: 4),
                Text('ຍອດຄົງເຫຼືອ',
                    style: TextStyle(color: Colors.white70, fontSize: 11,
                        fontWeight: FontWeight.w600, letterSpacing: 0.3)),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedNumber(
                value: bal,
                suffix: ' ກີບ',
                duration: 1200,
                style: TextStyle(
                  color: bal < 0 ? Colors.red.shade200 : Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _tile(Icons.payments_outlined, 'ສົດ', controller.cashBalance)),
              Container(width: 1, height: 20, color: Colors.white24),
              Expanded(child: _tile(Icons.account_balance, 'ໂອນ', controller.transferBalance)),
            ]),
          ],
        ),
      );
    });
  }

  Widget _tile(IconData i, String l, double v) => Column(
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, color: Colors.white70, size: 11),
        const SizedBox(width: 3),
        Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedNumber(
          value: v, suffix: ' ກີບ', duration: 1100,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}