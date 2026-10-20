import 'package:centrally/core/format/localized_digits_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = LocalizedDigitsFormatter();
  for (final input in ['٢٠٠٠٠', '۲۰۰۰۰', '20000']) {
    test('normalizes target digits: $input', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: input,
          selection: TextSelection.collapsed(offset: input.length),
        ),
      );
      expect(result.text, '20000');
      expect(result.selection.baseOffset, 5);
    });
  }
  test('rejects non-integer symbols and preserves deletion', () {
    expect(
      formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(text: '١a٢-٣'),
          )
          .text,
      '123',
    );
    expect(
      formatter
          .formatEditUpdate(
            const TextEditingValue(text: '123'),
            TextEditingValue.empty,
          )
          .text,
      isEmpty,
    );
  });
}
