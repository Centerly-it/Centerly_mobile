import 'package:centrally/core/utils/contact_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Egyptian guardian numbers open the exact WhatsApp recipient without a message',
    () {
      for (final value in [
        '01012345678',
        '010 1234 5678',
        '+20 (10) 1234-5678',
        '٠١٠١٢٣٤٥٦٧٨',
        '۰۱۰۱۲۳۴۵۶۷۸',
        '+20 101 234 5678',
        '00201012345678',
      ]) {
        final uri = contactUri(value, whatsapp: true)!;
        expect(uri.toString(), 'whatsapp://send?phone=201012345678');
        expect(uri.queryParameters, {'phone': '201012345678'});
        expect(uri.queryParameters.containsKey('text'), isFalse);
        expect(
          contactUri(value, whatsapp: false).toString(),
          'tel:+201012345678',
        );
      }
    },
  );
  test('missing and malformed contacts never create an external intent', () {
    for (final value in [
      '',
      '12',
      '123',
      'javascript:alert(1)',
      'number',
      '01012345678?text=hello',
    ]) {
      expect(contactUri(value, whatsapp: true), isNull);
    }
  });
}
