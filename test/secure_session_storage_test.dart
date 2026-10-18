import 'package:centrally/core/auth/secure_auth_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'session persists through storage recreation and is removed on logout',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      const first = SecureAuthStorage('centerly-test-session');
      await first.initialize();
      expect(await first.hasAccessToken(), isFalse);
      await first.persistSession('{"synthetic":"test-only-session"}');
      const restarted = SecureAuthStorage('centerly-test-session');
      expect(await restarted.hasAccessToken(), isTrue);
      expect(
        await restarted.accessToken(),
        '{"synthetic":"test-only-session"}',
      );
      await restarted.removePersistedSession();
      expect(await first.accessToken(), isNull);
    },
  );
}
