import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';

class SessionAttendanceFilters extends StatelessWidget {
  const SessionAttendanceFilters({
    required this.students,
    required this.status,
    required this.onChanged,
    super.key,
  });
  final List<SessionStudentData> students;
  final String? status;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wideLabels =
          MediaQuery.textScalerOf(context).scale(14) > 20 ||
          constraints.maxWidth < 300 ||
          context.locale.languageCode != 'ar';
      final columns = wideLabels ? 2 : 4;
      final width =
          (constraints.maxWidth - (columns - 1) * AppSize.s8) / columns;
      return Wrap(
        spacing: AppSize.s8,
        runSpacing: AppSize.s8,
        children: [
          for (final value in [
            null,
            'present',
            'absent',
            'excused',
            if (students.any((s) => s.status == 'not_marked')) 'not_marked',
          ])
            SizedBox(
              width: width,
              child: ChoiceChip(
                showCheckmark: false,
                selected: status == value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p4,
                  vertical: AppPadding.p8,
                ),
                backgroundColor: ColorManager.grey200,
                selectedColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  side: const BorderSide(color: SessionDesign.stroke),
                ),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  color: status == value
                      ? ColorManager.white
                      : SessionDesign.text,
                ),
                label: SizedBox(
                  width: width - AppSize.s16,
                  child: Text(
                    '${(value == null ? 'design_all' : 'attendance_$value').tr()} ${value == null ? students.length : students.where((s) => s.status == value).length}',
                    textAlign: TextAlign.center,
                  ),
                ),
                onSelected: (_) => onChanged(value),
              ),
            ),
        ],
      );
    },
  );
}
