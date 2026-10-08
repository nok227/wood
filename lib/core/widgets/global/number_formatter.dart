import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────
/// Formatter ใส่ comma: 1,000 / 10,000 / 100,000
/// ─────────────────────────────────────────────
class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = NumberFormat('#,###').format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// ─────────────────────────────────────────────
/// Formatter ใส่จุด: 1.000 / 10.000 / 100.000
/// ─────────────────────────────────────────────
class DotNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;
    final n = int.tryParse(digits);
    if (n == null) return oldValue;

    final formatted = n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// ─────────────────────────────────────────────
/// Formatter จำกัดจำนวนหลัก (นับเฉพาะตัวเลข)
/// ─────────────────────────────────────────────
class DigitLimitFormatter extends TextInputFormatter {
  final int maxDigits;
  const DigitLimitFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length <= maxDigits) return newValue;
    return oldValue;
  }
}