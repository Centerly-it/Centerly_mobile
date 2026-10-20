import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/preview_mode.dart';
import 'bootstrap_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/auth/secure_auth_storage.dart';
import '../core/config/app_config.dart';
import '../core/di/di.dart';
import '../core/utils/cached_data_shared_preferences.dart';
import '../features/auth/data/repo_impl/supabase_teacher_auth.dart';
import '../features/auth/domain/repo/teacher_auth_repository.dart';
import '../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../core/api/teacher_read_client.dart';
import '../features/students/data/student_repository.dart';
import '../features/sessions/data/session_repository.dart';
import '../features/groups/data/group_repository.dart';

Future<void> bootstrapAuth({bool restoreSession = true}) async {
  final config = AppConfig.fromEnvironment();
  getIt.registerSingleton<AppConfig>(config);
  if (PreviewMode.enabled) {
    await bootstrapPreview();
    return;
  }
  // Remove prototype auth and obsolete REST tokens, never import them into Supabase.
  for (final key in [
    CacheConstants.userToken,
    CacheConstants.refreshToken,
    CacheConstants.role,
    CacheConstants.userEmail,
  ]) {
    await CacheService.deleteItem(key: key);
  }
  const secure = FlutterSecureStorage();
  for (final key in [
    'USER_TOKEN',
    'ACCESS_TOKEN',
    'REFRESH_TOKEN',
    'USER_ROLE',
    'TEACHER_ID',
  ]) {
    await secure.delete(key: key);
  }
  TeacherAuthRepository repository = const UnconfiguredTeacherAuth();
  if (config.isConfigured && config.isValid) {
    final storage = SecureAuthStorage(
      'centerly-${Uri.parse(config.url).host}-session',
    );
    try {
      await Supabase.initialize(
        url: config.url,
        publishableKey: config.publishableKey,
        debug: false,
        authOptions: FlutterAuthClientOptions(
          localStorage: storage,
          detectSessionInUri: false,
        ),
      );
      repository = SupabaseTeacherAuth(
        Supabase.instance.client,
        storage.removePersistedSession,
      );
      final readApi = TeacherReadClient(
        Supabase.instance.client,
        onAccessDenied: () => getIt<AuthSessionCubit>().restore(),
      );
      getIt.registerSingleton<TeacherReadClient>(readApi);
      getIt.registerSingleton<DashboardRepository>(
        DashboardRepository(readApi),
      );
      getIt.registerSingleton<GroupRepository>(GroupRepository(readApi));
      getIt.registerSingleton<StudentRepository>(StudentRepository(readApi));
      getIt.registerSingleton<SessionRepository>(SessionRepository(readApi));
    } catch (_) {
      /* Fail closed; configuration/login screen remains usable. */
    }
  }
  getIt.registerSingleton<TeacherAuthRepository>(repository);
  final session = AuthSessionCubit(repository);
  getIt.registerSingleton<AuthSessionCubit>(session);
  session.stream.listen((state) {
    // Also invalidates in-flight responses before account revalidation starts.
    if (!state.isAuthenticated && getIt.isRegistered<TeacherReadClient>()) {
      getIt<TeacherReadClient>().invalidate();
    }
  });
  if (restoreSession) await session.restore();
}
