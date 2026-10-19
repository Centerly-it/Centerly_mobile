import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'read_client_fixture.dart';

class CompletionFixture {
  final data =
      jsonDecode(
            File('test/fixtures/teacher_completion.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final requests = <String>[];
  bool failSave = false;
  SupabaseClient client() => readFixture((request) async {
    final name = request.url.pathSegments.last;
    requests.add(name);
    final params = jsonDecode(request.body) as Map;
    if (name == 'save_teacher_note') {
      if (failSave) {
        return jsonResponse(request, {
          'code': 'P0001',
          'message': 'CONFLICT',
        }, status: 400);
      }
      data['note'] = {
        'note': {
          'content': params['p_content'],
          'updated_at': '2026-10-19T10:00:00.123456Z',
        },
      };
      return jsonResponse(request, '2026-10-19T10:00:00.123456Z');
    }
    final key = switch (name) {
      'get_teacher_student_academics' => params['p_kind'] as String,
      'get_teacher_student_attendance' => 'attendance',
      'get_teacher_finance' => params['p_kind'] as String,
      'get_teacher_student_note' => 'note',
      'list_teacher_secretaries' => 'secretaries',
      'list_teacher_notifications' => 'notifications',
      'get_teacher_student_profile' => 'profile',
      _ => throw StateError('Unexpected RPC: $name'),
    };
    return jsonResponse(request, data[key]);
  });
}
