import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';
import '../../preview/student_preview_data.dart';
import 'student_data_table.dart';
import 'student_summary_tiles.dart';

class StudentAttendanceDesign extends StatelessWidget {
  const StudentAttendanceDesign({required this.data, super.key});
  final StudentPreviewData data;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppSurfaceSection(
        title: 'student_design_attendance_summary'.tr(),
        icon: const StudentAsset('bc58e.svg'),
        child: StudentSummaryTiles(
          values: [
            StudentSummaryValue(
              'student_design_attendance_rate'.tr(),
              '${data.attendancePercent}%',
            ),
            StudentSummaryValue(
              'student_design_present'.tr(),
              '${data.present}',
              unit: 'student_design_of_total'.tr(
                args: ['${data.totalSessions}'],
              ),
              color: ColorManager.success,
            ),
            StudentSummaryValue(
              'student_design_absent_summary'.tr(),
              '${data.absent}',
              unit: 'student_design_sessions_unit'.tr(),
              color: ColorManager.error,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSize.s16),
      AppSurfaceSection(
        title: 'student_design_attendance_history'.tr(),
        icon: const StudentAsset('f399a.svg'),
        child: StudentDataTable(
          headers: [
            'student_design_day'.tr(),
            'student_design_date'.tr(),
            'student_design_status'.tr(),
          ],
          rows: [
            for (final present in [false, true, false])
              [
                Text(
                  DateFormat.EEEE(
                    context.locale.toString(),
                  ).format(DateTime(2026, 5, 10)),
                  style: AppTextStyles.caption,
                ),
                Text(
                  DateFormat.MMMMd(
                    context.locale.toString(),
                  ).format(DateTime(2026, 5, 10)),
                  style: AppTextStyles.caption.copyWith(
                    color: ColorManager.textSecondary,
                  ),
                ),
                StudentTag(
                  label:
                      (present
                              ? 'student_design_present_status'
                              : 'student_design_absent')
                          .tr(),
                  positive: present,
                ),
              ],
          ],
        ),
      ),
    ],
  );
}
