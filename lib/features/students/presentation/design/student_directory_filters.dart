import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/student_preview_filters.dart';
import 'student_filter_chip.dart';

class StudentDirectoryFilters extends StatelessWidget {
  const StudentDirectoryFilters({
    required this.filters,
    required this.onClear,
    required this.onPick,
    super.key,
  });
  final StudentPreviewFilters filters;
  final VoidCallback onClear;
  final ValueChanged<String> onPick;
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Wrap(
      spacing: AppSize.s8,
      runSpacing: AppSize.s8,
      children: [
        StudentFilterChip(
          label: 'student_design_all'.tr(),
          selected: filters.values.values.every((s) => s.isEmpty),
          onTap: onClear,
        ),
        for (final kind in filters.values.keys)
          StudentFilterChip(
            label: 'student_design_$kind'.tr(),
            selected: filters.values[kind]!.isNotEmpty,
            onTap: () => onPick(kind),
          ),
      ],
    ),
  );
}
