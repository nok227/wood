import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wood/core/constants/global/app_colors.dart';

class AuthHeroHeader extends StatelessWidget {
  final String? title;

  const AuthHeroHeader({
    super.key,
    this.title,
  });

  static const String _lottiePath = 'assets/lottie/pending.json';

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ⭐ 1. เปลี่ยน 24 เป็น 20 ให้ตรงกับการ์ดด้านล่าง
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          // ── Lottie ──
          // ⭐ 2. ลบ ConstrainedBox ที่จำกัด maxWidth: 300 ออก
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Lottie.asset(
                  _lottiePath,
                  fit: BoxFit.cover, // จะขยายเต็มพื้นที่ที่กำหนด
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