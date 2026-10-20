import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';
import 'session_attendance_filters.dart';
import 'session_student_row.dart';
import 'session_design_empty.dart';

class AttendanceDesignPanel extends StatefulWidget {
  const AttendanceDesignPanel({required this.students, super.key});
  final List<SessionStudentData> students;
  @override
  State<AttendanceDesignPanel> createState() => _AttendanceDesignPanelState();
}

class _AttendanceDesignPanelState extends State<AttendanceDesignPanel> {
  String? _status;
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final rows = widget.students
        .where(
          (s) =>
              (_status == null || s.status == _status) &&
              s.name.toLowerCase().contains(_search.trim().toLowerCase()),
        )
        .toList();
    return SessionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SessionAttendanceFilters(
            students: widget.students,
            status: _status,
            onChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: AppSize.s12),
          TextField(
            onChanged: (value) => setState(() => _search = value),
            decoration: InputDecoration(
              hintText: 'design_search_student'.tr(),
              filled: true,
              fillColor: ColorManager.grey200,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(AppPadding.p16),
                child: SessionAsset('451d4.svg'),
              ),
            ),
          ),
          const SizedBox(height: AppSize.s12),
          if (rows.isEmpty) const SessionSearchEmpty(),
          for (final row in rows) ...[
            const Divider(height: 1, color: SessionDesign.stroke),
            SessionStudentRow(student: row),
          ],
        ],
      ),
    );
  }
}
