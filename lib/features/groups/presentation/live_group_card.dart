import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/color_manager.dart';
import 'group_card_header.dart';
import 'group_student_badge.dart';
import 'group_card_schedule.dart';
import '../domain/group_record.dart';
import '../../students/presentation/student_directory.dart';

class LiveGroupCard extends StatelessWidget {
  const LiveGroupCard({required this.group, required this.onGrade, super.key});
  final GroupRecord group;
  final VoidCallback onGrade;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppPadding.p12),
    child: Container(
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: ColorManager.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: AppSize.s4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryLight,
                  ColorManager.primaryBright,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GroupCardHeader(group: group),
                const SizedBox(height: AppSize.s8),
                GroupStudentBadge(group: group),
                const SizedBox(height: AppSize.s8),
                GroupCardSchedule(group: group),
                const SizedBox(height: AppSize.s12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StudentDirectory(
                        groupId: group.id,
                        groupName: group.name,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.people_outline, size: AppSize.s18),
                  label: Text('live_view_students'.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
