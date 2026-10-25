import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/color_manager.dart';
import '../domain/group_record.dart';
import 'live_group_detail.dart';

class GroupCardHeader extends StatelessWidget {
  const GroupCardHeader({required this.group, super.key});
  final GroupRecord group;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(AppRadius.r12),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LiveGroupDetail(group: group)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              color: ColorManager.primaryBright,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: ColorManager.primary,
              size: AppSize.s20,
            ),
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSize.s4),
                Text(group.subject, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left
                : Icons.chevron_right,
            color: ColorManager.primary,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    ),
  );
}
