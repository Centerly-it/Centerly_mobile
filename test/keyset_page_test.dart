import 'package:centrally/core/data/keyset_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keyset final/next cursors are stable and strictly advance', () {
    expect(validateKeysetPage(['01', '02'], limit: 2), '02');
    expect(validateKeysetPage(['03'], limit: 2, cursor: '02'), isNull);
    expect(validateKeysetPage([], limit: 2, cursor: '03'), isNull);
  });
  for (final values in [
    ['02', '02'],
    ['02', '01'],
    [''],
    ['02', '03', '04'],
  ]) {
    test('rejects duplicate, unsorted, empty or oversized page: $values', () {
      expect(() => validateKeysetPage(values, limit: 2), throwsFormatException);
    });
  }
  test(
    'rejects replay at old cursor',
    () => expect(
      () => validateKeysetPage(['02'], limit: 2, cursor: '02'),
      throwsFormatException,
    ),
  );
}
