import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/preview/preview_transport.dart';
import 'package:centrally/core/data/teacher_actions.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:centrally/features/groups/data/group_repository.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:centrally/features/sessions/data/session_detail_repository.dart';
import 'package:centrally/features/sessions/data/session_actions.dart';
import 'package:centrally/features/notes/data/student_note_repository.dart';
import 'package:centrally/features/finances/domain/finance_record.dart';
import 'package:centrally/features/academics/domain/academic_record.dart';
import 'package:centrally/features/attendance/domain/student_attendance_record.dart';
import 'package:centrally/features/secretaries/domain/secretary_record.dart';
import 'package:centrally/features/notifications/domain/notification_record.dart';

void main() {
  test('all preview reads and actions use terminal local transport', () async {
    final data = jsonDecode(
      File('assets/preview/teacher.json').readAsStringSync(),
    );
    final transport = PreviewTransport(Map<String, dynamic>.from(data as Map));
    final client = SupabaseClient(
      'https://preview.invalid',
      'preview-key',
      httpClient: transport,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    final api = TeacherReadClient(client);
    final raw = await client.rpc('get_teacher_overview');
    expect(raw, isA<Map>());
    final dashboard = await DashboardRepository(api).load();
    expect(dashboard.sessions.length, 3);
    expect(dashboard.invoicedEgp, '18000.00');
    final groups = await GroupRepository(api).list();
    expect(groups.groups, isNotEmpty);
    final students = await StudentRepository(api).list();
    final student = students.students.first.id;
    final profile = await api.read(
      TeacherRead.studentProfile,
      params: {'p_id': student},
    );
    expect(profile['student']['id'], student);
    final detail = await SessionDetailRepository(
      api,
    ).load(dashboard.sessions[1].id);
    expect(detail.session.id, dashboard.sessions[1].id);
    expect(detail.rows.length, 4);
    for (final kind in ['exams', 'assignments']) {
      final page = await api.read(
        TeacherRead.academics,
        params: {'p_kind': kind},
      );
      for (final row in page['rows']) {
        AcademicRecord.fromJson(Map<String, dynamic>.from(row));
      }
    }
    for (final kind in ['invoices', 'payments']) {
      final page = await api.read(
        TeacherRead.finance,
        params: {'p_kind': kind},
      );
      FinanceSummary.fromJson(Map<String, dynamic>.from(page['summary']));
      for (final row in page['rows']) {
        FinanceRecord.fromJson(Map<String, dynamic>.from(row));
      }
    }
    final attendance = await api.read(TeacherRead.studentAttendance);
    for (final row in attendance['rows']) {
      StudentAttendanceRecord.fromJson(Map<String, dynamic>.from(row));
    }
    final notes = StudentNoteRepository(api);
    await notes.save(student, 'Local draft', null);
    expect((await notes.load(student)).content, 'Local draft');
    final secretaries = await api.read(TeacherRead.secretaries);
    final secretary = SecretaryRecord.fromJson(
      Map<String, dynamic>.from(secretaries['rows'][0]),
    );
    await TeacherActions(api).deactivateSecretary(secretary.id);
    expect(
      transport.responses.data['secretaries']['rows'][0]['status'],
      'inactive',
    );
    await TeacherActions(api).reactivateSecretary(secretary.id);
    expect(
      transport.responses.data['secretaries']['rows'][0]['status'],
      'active',
    );
    final notifications = await api.read(TeacherRead.notifications);
    final notification = NotificationRecord.fromJson(
      Map<String, dynamic>.from(notifications['rows'][0]),
    );
    await TeacherActions(api).markRead(notification.id);
    await SessionActions(api).cancel(dashboard.sessions[1].id, 'Local preview');
    expect(
      (await SessionDetailRepository(
        api,
      ).load(dashboard.sessions[1].id)).cancelReason,
      'Local preview',
    );
    await client.dispose();
  });
}
