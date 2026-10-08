import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AuthHeroHeader extends StatelessWidget {
  final String? title;   // ⭐ เปลี่ยนเป็น nullable

  const AuthHeroHeader({
    super.key,
    this.title,          // ⭐ ไม่ required แล้ว
  });

  static const String _lottiePath = 'assets/lottie/pending.json';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          // ── Lottie ──
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Lottie.asset(
                    _lottiePath,
                    fit: BoxFit.cover,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.brown600,
                              AppColors.brown800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.login_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ⭐ แสดง title แค่ถ้ามี
          if (title != null && title!.trim().isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.brown800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}