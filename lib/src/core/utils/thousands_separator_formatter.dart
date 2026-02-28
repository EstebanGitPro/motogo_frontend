import 'package:flutter/services.dart';

/// Formatter that adds dots as thousand separators while the user types.
///
/// Example: 185000 → 185.000, 1500000 → 1.500.000
///
/// **Usage**: combine with [FilteringTextInputFormatter.digitsOnly] so that
/// only digits reach this formatter:
/// ```dart
/// inputFormatters: [
///   FilteringTextInputFormatter.digitsOnly,
///   ThousandsSeparatorFormatter(),
/// ],
/// ```
///
/// To retrieve the raw numeric value, strip dots before parsing:
/// ```dart
/// final value = double.tryParse(controller.text.replaceAll('.', ''));
/// ```
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    if (digits.isEmpty) return newValue;

    final buffer = StringBuffer();
    final length = digits.length;
    for (var i = 0; i < length; i++) {
      buffer.write(digits[i]);
      final remaining = length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
