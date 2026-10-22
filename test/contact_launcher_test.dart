import 'package:centrally/core/utils/contact_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Egypt and international phone normalization excludes malformed URIs',
    () {
      expect(contactDigits('010 1234 5678'), '201012345678');
      expect(contactDigits('+20 (10) 1234-5678'), '201012345678');
      expect(contactDigits('00201012345678'), '201012345678');
      expect(contactDigits('javascript:alert(1)'), isNull);
      expect(contactDigits('12'), isNull);
    },
  );
}
