import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/group_preview_data.dart';
import 'group_design.dart';

class GroupStudentRows extends StatelessWidget {
  const GroupStudentRows({required this.data, this.count = 5, super.key});
  final GroupPreviewData data;
  final int count;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < count; i++)
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(AppPadding.p8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: GroupDesign.stroke)),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/figma/sessions/04ab7.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: AppSize.s8),
              Expanded(
                child: Text(
                  data.studentName,
                  style: AppTextStyles.bodyMedium.copyWith(height: 24 / 14),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
