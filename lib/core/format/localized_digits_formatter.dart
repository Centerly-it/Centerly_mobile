import 'package:flutter/services.dart';

/// Normalize Arabic and Persian decimal digits before applying integer filtering.
class LocalizedDigitsFormatter extends TextInputFormatter {
  const LocalizedDigitsFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = newValue.text.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (
      match,
    ) {
      final code = match[0]!.codeUnitAt(0);
      return String.fromCharCode(0x30 + code - (code >= 0x6f0 ? 0x6f0 : 0x660));
    });
    return FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
      oldValue,
      newValue.copyWith(text: normalized),
    );
  }
}
