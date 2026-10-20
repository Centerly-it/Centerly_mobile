import 'package:centrally/core/auth/remembered_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'restores after recreating store and isolates backend environments',
    () async {
      const first = RememberedLogin('https://first.example');
      await first.save(' teacher@example.test ', 'example-password');
      final restored = await const RememberedLogin(
        'https://first.example',
      ).read();
      expect(restored?.email, 'teacher@example.test');
      expect(restored?.password, 'example-password');
      expect(
        await const RememberedLogin('https://second.example').read(),
        isNull,
      );
    },
  );

  test('malformed stored data does not prevent login', () async {
    FlutterSecureStorage.setMockInitialValues({
      'centerly-remembered-login-https://first.example': '{invalid',
    });
    expect(await const RememberedLogin('https://first.example').read(), isNull);
  });
}
