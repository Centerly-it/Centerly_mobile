import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/format/money_egp.dart';
import 'package:centrally/features/academics/domain/academic_record.dart';
import 'package:centrally/features/attendance/domain/student_attendance_record.dart';
import 'package:centrally/features/finances/domain/finance_record.dart';
import 'package:centrally/features/students/domain/student_record.dart';
import 'package:centrally/features/students/domain/student_membership.dart';
import 'package:centrally/features/secretaries/domain/secretary_record.dart';
import 'package:centrally/features/notifications/domain/notification_record.dart';
import 'package:centrally/features/notes/domain/student_note.dart';

void main() {
  final fixture = readMap(
    jsonDecode(
      File('test/fixtures/teacher_completion.json').readAsStringSync(),
    ),
  );
  test('typed Flutter models parse actual local SQL contract JSON', () {
    final profile = readMap(fixture['profile']);
    expect(
      StudentRecord.fromJson(readMap(profile['student'])).guardianPhone,
      isNull,
    );
    expect(
      StudentMembership.fromJson(
        readMap((profile['memberships'] as List).first),
      ).status,
      'active',
    );
    final exams = readMap(fixture['exams']);
    final rows = (exams['rows'] as List)
        .map((r) => AcademicRecord.fromJson(readMap(r)))
        .toList();
    expect(rows.where((r) => r.score == null).length, 1);
    expect(rows.where((r) => r.score == '0.00').length, 1);
    expect(
      AcademicSummary.fromJson(readMap(exams['summary'])).average,
      '50.00',
    );
    final attendance = readMap(fixture['attendance']);
    expect(
      StudentAttendanceRecord.fromJson(
        readMap((attendance['rows'] as List).first),
      ).status,
      'not_marked',
    );
    expect(
      StudentAttendanceSummary.fromJson(
        readMap(attendance['summary']),
      ).denominator,
      0,
    );
    final invoices = readMap(fixture['invoices']);
    expect(
      FinanceRecord.fromJson(
        readMap((invoices['rows'] as List).first),
      ).outstanding!.decimal,
      '100.01',
    );
    final summary = FinanceSummary.fromJson(readMap(invoices['summary']));
    expect(summary.values['period_net_collected_egp']!.minorUnits, BigInt.zero);
    expect(summary.daily.values.single.minorUnits, BigInt.zero);
    final payments = (readMap(fixture['payments'])['rows'] as List).map(
      (r) => FinanceRecord.fromJson(readMap(r)),
    );
    expect(
      payments.any((r) => r.signedAmount!.minorUnits == BigInt.from(-2501)),
      isTrue,
    );
    expect(StudentNote.fromJson(readMap(fixture['note'])).version, isNull);
    expect(
      SecretaryRecord.fromJson(
        readMap((readMap(fixture['secretaries'])['rows'] as List).first),
      ).email,
      'a@example.invalid',
    );
    expect(
      NotificationRecord.fromJson(
        readMap((readMap(fixture['notifications'])['rows'] as List).first),
      ).labelKey,
      startsWith('completion_event_'),
    );
  });
  test('money and pending denominators reject malformed data', () {
    expect(
      MoneyEgp.parse('999999999999999999.99').minorUnits,
      BigInt.parse('99999999999999999999'),
    );
    for (final invalid in [1.01, '1.001', 'NaN', '1e3', 'Infinity']) {
      expect(() => MoneyEgp.parse(invalid), throwsFormatException);
    }
    expect(
      () => StudentAttendanceSummary.fromJson({
        'present': 0,
        'absent': 0,
        'excused': 0,
        'not_marked': 5,
        'marked_denominator': 5,
        'cancelled_records': 0,
      }),
      throwsFormatException,
    );
  });
  test(
    'note version retains exact microseconds and unknown events render safely',
    () {
      const version = '2026-10-19T10:11:12.123456+00:00';
      expect(
        StudentNote.fromJson({
          'note': {'content': 'Draft', 'updated_at': version},
        }).version,
        version,
      );
      expect(
        NotificationRecord.fromJson({
          'id': 'event',
          'type': '<script>phone secret</script>',
          'created_at': version,
          'read_at': null,
          'payload': {'session_id': 'bad'},
        }).labelKey,
        'completion_event_admin',
      );
    },
  );
}
