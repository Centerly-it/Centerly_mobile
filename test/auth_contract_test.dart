import 'dart:convert';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:centrally/features/auth/data/auth_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const id = '10000000-0000-0000-0000-000000000001';
  test(
    'only verified teacher identity matching Auth UID and tenant is accepted',
    () {
      expect(
        TeacherProfile.fromJson({
          'id': id,
          'teacher_id': id,
          'role': 'teacher',
        }, id).id,
        id,
      );
      for (final data in [
        {'id': id, 'teacher_id': id, 'role': 'secretary'},
        {'id': id, 'teacher_id': 'other', 'role': 'teacher'},
        {'id': 'malformed', 'teacher_id': 'malformed', 'role': 'teacher'},
      ]) {
        expect(
          () => TeacherProfile.fromJson(data, id),
          throwsA(isA<TeacherAuthFailure>()),
        );
      }
    },
  );
  test(
    'mobile configuration rejects privileged keys and remote plaintext HTTP',
    () {
      final payload = base64Url.encode(utf8.encode('{"role":"service_role"}'));
      for (final key in ['sb_secret_private', 'header.$payload.signature']) {
        expect(
          AppConfig(
            url: 'https://test.supabase.co',
            publishableKey: key,
          ).isValid,
          isFalse,
        );
      }
      expect(
        const AppConfig(
          url: 'http://remote.example',
          publishableKey: 'sb_publishable_test',
        ).isValid,
        isFalse,
      );
      expect(
        const AppConfig(
          url: 'https://test.supabase.co',
          publishableKey: 'sb_publishable_test',
        ).isValid,
        isTrue,
      );
    },
  );
  test('database and auth errors map to stable safe UI codes', () {
    expect(
      mapAuthFailure(
        const PostgrestException(message: 'SUBSCRIPTION_INACTIVE'),
      ).code,
      'SUBSCRIPTION_INACTIVE',
    );
    expect(
      mapAuthFailure(
        const PostgrestException(message: 'private SQL details'),
      ).code,
      'SERVICE_UNAVAILABLE',
    );
    expect(
      mapAuthFailure(
        const AuthException('private response', code: 'invalid_credentials'),
      ).code,
      'INVALID_CREDENTIALS',
    );
  });
}
