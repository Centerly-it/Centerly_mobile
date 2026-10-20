import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/student_filter_chip.dart';

class StudentFilterSheet extends StatefulWidget {
  const StudentFilterSheet({
    required this.kind,
    required this.selected,
    super.key,
  });
  final String kind;
  final Set<String> selected;
  @override
  State<StudentFilterSheet> createState() => _StudentFilterSheetState();
}

class _StudentFilterSheetState extends State<StudentFilterSheet> {
  late final _selected = {...widget.selected};
  @override
  Widget build(BuildContext context) {
    final options = switch (widget.kind) {
      'level' => ['excellent', 'good', 'average', 'weak'],
      'group' => ['group_a', 'group_b'],
      _ => ['paid', 'unpaid'],
    };
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          48,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'student_design_${widget.kind}'.tr(),
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSize.s24),
            Wrap(
              spacing: AppSize.s8,
              runSpacing: AppSize.s8,
              children: [
                for (final option in options)
                  StudentFilterChip(
                    label: 'student_design_$option'.tr(),
                    selected: _selected.contains(option),
                    onTap: () => setState(
                      () => _selected.contains(option)
                          ? _selected.remove(option)
                          : _selected.add(option),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSize.s32),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text('student_design_show_results'.tr()),
                  ),
                ),
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: ColorManager.stroke,
                    ),
                    onPressed: _selected.isEmpty
                        ? null
                        : () => setState(_selected.clear),
                    child: Text('student_design_clear_all'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
