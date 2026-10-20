import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../presentation/design/group_design.dart';
import '../presentation/design/group_grade_heading.dart';
import '../presentation/design/group_design_card.dart';
import '../presentation/design/group_design_empty.dart';
import 'group_preview_data.dart';
import 'group_design_detail.dart';

class FigmaGroupsPreview extends StatefulWidget {
  const FigmaGroupsPreview({this.groups, super.key});
  final List<GroupPreviewData>? groups;
  @override
  State<FigmaGroupsPreview> createState() => _FigmaGroupsPreviewState();
}

class _FigmaGroupsPreviewState extends State<FigmaGroupsPreview> {
  late final _groups = widget.groups ?? GroupPreviewData.fixtures();
  String _query = '';
  @override
  Widget build(BuildContext context) {
    if (_groups.isEmpty) {
      return const ColoredBox(
        color: GroupDesign.background,
        child: GroupDesignEmpty(),
      );
    }
    final groups = _groups
        .where(
          (g) => '${g.name} ${g.gradeName} ${g.studentName}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return ColoredBox(
      color: GroupDesign.background,
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: 'group_design_search'.tr(),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(AppPadding.p16),
                child: GroupAsset('451d4.svg'),
              ),
              filled: true,
              fillColor: ColorManager.grey200,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                borderSide: BorderSide.none,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppPadding.p24),
              child: Text('group_design_search_empty'.tr()),
            ),
          for (final grade in groups.map((g) => g.grade).toSet()) ...[
            const SizedBox(height: AppSize.s16),
            GroupGradeHeading(grade: grade),
            const SizedBox(height: AppSize.s16),
            for (final group in groups.where((g) => g.grade == grade))
              Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p8),
                child: GroupDesignCard(
                  data: group,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GroupDesignDetail(data: group),
                    ),
                  ),
                ),
              ),
            if (grade != groups.last.grade) const GroupGradeDivider(),
          ],
        ],
      ),
    );
  }
}
