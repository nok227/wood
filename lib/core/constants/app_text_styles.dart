import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ══════════════════════════════════════════
  // Headings
  // ══════════════════════════════════════════
  static const TextStyle heading1 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87,
  );

  // ══════════════════════════════════════════
  // Titles & Body
  // ══════════════════════════════════════════
  static const TextStyle title = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87,
  );
  static const TextStyle body = TextStyle(fontSize: 13, color: Colors.black87);
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, color: Colors.black54,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, color: Colors.black54,
  );

  // ══════════════════════════════════════════
  // Labels
  // ══════════════════════════════════════════
  static const TextStyle label = TextStyle(
    fontSize: 10.5, fontWeight: FontWeight.w900,
    color: Colors.black54, letterSpacing: 1.2,
  );

  // ══════════════════════════════════════════
  // Money
  // ══════════════════════════════════════════
  static const TextStyle money = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w900,
    color: Colors.black87, letterSpacing: 0.2,
  );
  static const TextStyle moneyLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.3,
  );
}