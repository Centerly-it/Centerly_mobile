import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/config/backend_projects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev and prod cannot share or swap their configured project', () {
    expect(BackendProjects.development, isNot(BackendProjects.production));
    for (final environment in ['development', 'production']) {
      final ref = environment == 'development'
          ? BackendProjects.development
          : BackendProjects.production;
      final other = environment == 'development'
          ? BackendProjects.production
          : BackendProjects.development;
      expect(
        AppConfig(
          url: 'https://$ref.supabase.co',
          publishableKey: 'sb_publishable_live',
          environment: environment,
        ).isValid,
        isTrue,
      );
      expect(
        AppConfig(
          url: 'https://$other.supabase.co',
          publishableKey: 'sb_publishable_live',
          environment: environment,
        ).isValid,
        isFalse,
      );
    }
  });
  test(
    'selected local define file is valid without launching the app',
    () {
      final config = AppConfig.fromEnvironment();
      expect(config.isValid, isTrue);
      final expected = config.environment == 'production'
          ? BackendProjects.production
          : BackendProjects.development;
      expect(Uri.parse(config.url).host, '$expected.supabase.co');
    },
    skip: const String.fromEnvironment('APP_ENV').isEmpty,
  );
}
