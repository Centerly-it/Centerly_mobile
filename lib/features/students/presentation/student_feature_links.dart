import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../academics/presentation/student_academics_page.dart';
import '../../attendance/presentation/student_attendance_page.dart';
import '../../finances/presentation/teacher_finance_page.dart';
import '../../notes/presentation/student_note_page.dart';

class StudentFeatureLinks extends StatelessWidget {
  const StudentFeatureLinks({
    required this.studentId,
    required this.initialDate,
    super.key,
  });
  final String studentId;
  final DateTime initialDate;
  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      for (final entry in <String, Widget>{
        'completion_academics': StudentAcademicsPage(
          studentId: studentId,
          initialDate: initialDate,
        ),
        'completion_attendance': StudentAttendancePage(
          studentId: studentId,
          initialDate: initialDate,
        ),
        'nav_finance': TeacherFinancePage(
          studentId: studentId,
          initialDate: initialDate,
        ),
        'completion_notes': StudentNotePage(studentId: studentId),
      }.entries)
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => entry.value),
          ),
          child: Text(entry.key.tr()),
        ),
    ],
  );
}
