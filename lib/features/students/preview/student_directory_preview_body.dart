import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/widgets/app_search_empty.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/student_directory_row.dart';
import '../presentation/design/student_directory_filters.dart';
import 'student_preview_data.dart';
import 'student_preview_filters.dart';
import 'student_search_field.dart';
import 'student_profile_preview.dart';

class StudentDirectoryPreviewBody extends StatelessWidget {
  const StudentDirectoryPreviewBody({
    required this.rows,
    required this.filters,
    required this.onQuery,
    required this.onPick,
    required this.onReset,
    super.key,
  });
  final List<StudentPreviewData> rows;
  final StudentPreviewFilters filters;
  final ValueChanged<String> onQuery, onPick;
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: ColorManager.canvas,
    child: Padding(
      padding: const EdgeInsets.all(AppPadding.p16),
      child: Column(
        children: [
          StudentSearchField(onChanged: onQuery),
          const SizedBox(height: AppSize.s16),
          StudentDirectoryFilters(
            filters: filters,
            onClear: onReset,
            onPick: onPick,
          ),
          const SizedBox(height: AppSize.s16),
          Expanded(
            child: ListView(
              children: [
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.p24),
                    child: AppSearchEmpty(
                      title: 'student_design_no_results'.tr(),
                    ),
                  ),
                for (final student in rows)
                  StudentDirectoryRow(
                    data: student,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StudentProfilePreview(data: student),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
