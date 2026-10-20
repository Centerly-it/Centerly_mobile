import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';
import 'session_student_row.dart';

class SessionDetailStudents extends StatefulWidget {
  const SessionDetailStudents({required this.data, super.key});
  final SessionDesignData data;
  @override
  State<SessionDetailStudents> createState() => _SessionDetailStudentsState();
}

class _SessionDetailStudentsState extends State<SessionDetailStudents> {
  bool _present = true;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      DefaultTabController(
        length: 2,
        child: TabBar(
          indicatorWeight: 1.5,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p24,
          ),
          onTap: (i) => setState(() => _present = i == 0),
          tabs: [
            Tab(
              text: 'design_present_count'.tr(args: ['${widget.data.present}']),
            ),
            Tab(
              text: 'design_not_present_count'.tr(
                args: ['${widget.data.expected - widget.data.present}'],
              ),
            ),
          ],
        ),
      ),
      for (final student
          in widget.data.students
              .where(
                (s) => _present ? s.status == 'present' : s.status != 'present',
              )
              .take(4)) ...[
        const Divider(height: 1, color: SessionDesign.stroke),
        SessionStudentRow(student: student),
      ],
    ],
  );
}
