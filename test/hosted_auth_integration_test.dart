// Explicit opt-in: uses only owner-approved synthetic hosted development accounts.
import 'dart:convert';
import 'dart:io';
import 'package:centrally/features/auth/data/repo_impl/supabase_teacher_auth.dart';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const enabled = bool.fromEnvironment('RUN_HOSTED_AUTH_TESTS');
  test(
    'hosted Supabase SDK teacher login, restore, logout and secretary denial',
    () async {
      final config =
          jsonDecode(await File('.env.local.json').readAsString()) as Map;
      final credentials =
          jsonDecode(
                await File('.env.development-accounts.json').readAsString(),
              )
              as Map;
      final accounts = (credentials['accounts'] as List).cast<Map>();
      final teacher = accounts.firstWhere((a) => a['name'] == 'teacher-a');
      final secretary = accounts.firstWhere((a) => a['name'] == 'secretary-a');
      final client = SupabaseClient(
        config['SUPABASE_URL'] as String,
        config['SUPABASE_PUBLISHABLE_KEY'] as String,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      var cleared = false;
      final repository = SupabaseTeacherAuth(client, () async {
        cleared = true;
      });
      try {
        final profile = await repository.login(
          teacher['email'] as String,
          teacher['password'] as String,
        );
        expect(profile.teacherId, teacher['id']);
        expect((await repository.restore())?.teacherId, teacher['id']);
        await client.auth.refreshSession();
        expect((await repository.restore())?.id, teacher['id']);
        await repository.logout();
        expect(cleared, isTrue);
        expect(client.auth.currentSession, isNull);
        await expectLater(
          repository.login(
            secretary['email'] as String,
            secretary['password'] as String,
          ),
          throwsA(
            isA<TeacherAuthFailure>().having(
              (e) => e.code,
              'code',
              'FORBIDDEN_ROLE',
            ),
          ),
        );
        expect(client.auth.currentSession, isNull);
        await expectLater(
          repository.login(
            teacher['email'] as String,
            'incorrect-synthetic-password',
          ),
          throwsA(
            isA<TeacherAuthFailure>().having(
              (e) => e.code,
              'code',
              'INVALID_CREDENTIALS',
            ),
          ),
        );
      } finally {
        await repository.logout();
        await client.dispose();
      }
    },
    skip: !enabled
        ? 'Opt in only after approved hosted development provisioning'
        : false,
  );
}
