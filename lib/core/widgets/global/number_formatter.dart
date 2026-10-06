import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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