import 'package:flutter/material.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/student_attendance_record.dart';
import 'attendance_history_row.dart';

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({required this.record, super.key});
  final StudentAttendanceRecord record;
  @override
  Widget build(BuildContext context) =>
      TeacherCard(child: AttendanceHistoryRow(record: record));
}
