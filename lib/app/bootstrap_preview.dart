import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/di/di.dart';
import '../core/api/teacher_read_client.dart';
import '../core/preview/preview_transport.dart';
import '../features/auth/domain/entities/teacher_profile.dart';
import '../features/auth/domain/repo/teacher_auth_repository.dart';
import '../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/groups/data/group_repository.dart';
import '../features/students/data/student_repository.dart';
import '../features/sessions/data/session_repository.dart';

Future<void> bootstrapPreview() async {
  final fixtures = jsonDecode(
    await rootBundle.loadString('assets/preview/teacher.json'),
  );
  final client = SupabaseClient(
    'https://preview.invalid',
    'preview-public-key',
    httpClient: PreviewTransport(Map<String, dynamic>.from(fixtures as Map)),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  final api = TeacherReadClient(client);
  getIt.registerSingleton<TeacherReadClient>(api);
  getIt.registerSingleton<DashboardRepository>(DashboardRepository(api));
  getIt.registerSingleton<GroupRepository>(GroupRepository(api));
  getIt.registerSingleton<StudentRepository>(StudentRepository(api));
  getIt.registerSingleton<SessionRepository>(SessionRepository(api));
  final auth = _PreviewAuth();
  getIt.registerSingleton<TeacherAuthRepository>(auth);
  final session = AuthSessionCubit(auth);
  getIt.registerSingleton<AuthSessionCubit>(session);
  await session.restore();
}

class _PreviewAuth implements TeacherAuthRepository {
  bool signedIn = true;
  static const profile = TeacherProfile(
    id: '10000000-0000-0000-0000-000000000001',
    teacherId: '10000000-0000-0000-0000-000000000001',
  );
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  Future<TeacherProfile?> restore() async => signedIn ? profile : null;
  @override
  Future<TeacherProfile> login(String email, String password) async {
    signedIn = true;
    return profile;
  }

  @override
  Future<void> logout() async {
    signedIn = false;
  }
}
