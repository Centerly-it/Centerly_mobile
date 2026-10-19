import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/data/teacher_actions.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/notes/data/student_note_repository.dart';
import 'package:centrally/features/notes/presentation/student_note_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'helpers/completion_fixture.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'note duplicate taps save once, then reconcile server version',
    () async {
      final fixture = CompletionFixture();
      final client = fixture.client();
      final editor = StudentNoteEditor(
        StudentNoteRepository(TeacherReadClient(client)),
        'student',
      );
      try {
        await editor.load();
        editor.text.text = 'ملاحظة تجريبية';
        await Future.wait([editor.save(), editor.save()]);
        expect(
          fixture.requests.where((r) => r == 'save_teacher_note').length,
          1,
        );
        expect(editor.dirty, isFalse);
        expect(editor.saved!.version, '2026-10-19T10:00:00.123456Z');
      } finally {
        editor.dispose();
        await client.dispose();
      }
    },
  );
  test(
    'conflict preserves draft and blocks resubmission until explicit reload',
    () async {
      final fixture = CompletionFixture()..failSave = true;
      final client = fixture.client();
      final editor = StudentNoteEditor(
        StudentNoteRepository(TeacherReadClient(client)),
        'student',
      );
      try {
        await editor.load();
        editor.text.text = 'Unsaved draft';
        await editor.save();
        await editor.save();
        expect(editor.text.text, 'Unsaved draft');
        expect(editor.error, 'CONFLICT');
        expect(editor.mustReload, isTrue);
        expect(
          fixture.requests.where((r) => r == 'save_teacher_note').length,
          1,
        );
        await editor.load();
        expect(editor.mustReload, isFalse);
      } finally {
        editor.dispose();
        await client.dispose();
      }
    },
  );
  test(
    'removal and notification mutations never retry ambiguous transport failures',
    () async {
      var calls = 0;
      final client = readFixture((_) async {
        calls++;
        throw http.ClientException('synthetic offline');
      });
      final api = TeacherReadClient(client);
      try {
        final generation = api.cache.generation;
        await expectLater(
          TeacherActions(api).requestRemoval('secretary'),
          throwsA(isA<BackendFailure>()),
        );
        expect(calls, 1);
        expect(api.cache.generation, greaterThan(generation));
        await expectLater(
          TeacherActions(api).markRead('notification'),
          throwsA(isA<BackendFailure>()),
        );
        expect(calls, 2);
      } finally {
        await client.dispose();
      }
    },
  );
}
