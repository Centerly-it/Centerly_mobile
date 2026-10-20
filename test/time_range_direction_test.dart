import 'package:centrally/core/format/cairo_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ar'));
  for (final locale in ['ar', 'en']) {
    for (final direction in TextDirection.values) {
      test('$locale interval follows reading order inside $direction', () {
        final range = CairoTime.range(
          DateTime.utc(2026, 1, 1, 8),
          DateTime.utc(2026, 1, 1, 9, 30),
          locale,
        );
        final painter = TextPainter(
          text: TextSpan(text: range, style: const TextStyle(fontSize: 16)),
          textDirection: direction,
        )..layout();
        double position(String clock) {
          final index = range.indexOf(clock);
          expect(index, greaterThanOrEqualTo(0));
          return painter
              .getBoxesForSelection(
                TextSelection(
                  baseOffset: index,
                  extentOffset: index + clock.length,
                ),
              )
              .first
              .left;
        }

        expect(
          position('10:00'),
          locale == 'ar'
              ? greaterThan(position('11:30'))
              : lessThan(position('11:30')),
        );
        if (locale == 'ar') {
          expect(position('ص'), lessThan(position('10:00')));
        }
        painter.dispose();
      });
    }
  }
}
