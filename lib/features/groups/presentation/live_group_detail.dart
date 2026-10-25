import '../../../core/widgets/app_info_row.dart';
import 'live_group_upcoming.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/group_record.dart';
import 'design/group_design.dart';
import 'design/group_section.dart';
import 'design/group_subpage_bar.dart';
import '../../sessions/presentation/live_sessions.dart';
import '../../students/presentation/student_directory.dart';
import '../../students/presentation/student_profile_page.dart';

class LiveGroupDetail extends StatelessWidget {
  const LiveGroupDetail({required this.group, super.key});
  final GroupRecord group;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GroupDesign.background,
    appBar: const GroupSubpageBar(title: 'group_design_details'),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          GroupPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(group.name, style: Theme.of(context).textTheme.titleLarge),
                AppInfoRow(
                  label: 'ui_subject'.tr(),
                  value: [
                    group.gradeName,
                    group.subject,
                  ].where((v) => v.isNotEmpty).join(' · '),
                  icon: Icons.menu_book_outlined,
                ),
                AppInfoRow(
                  label: 'ui_students_count'.tr(),
                  value: '${group.students}',
                  icon: Icons.groups_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s16),
          GroupSection(
            title: 'group_design_upcoming',
            asset: 'f399a.svg',
            child: LiveGroupUpcoming(groupId: group.id),
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(group.name)),
                  body: LiveSessions(groupId: group.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSize.s16),
          GroupSection(
            title: 'group_design_notes',
            asset: '444b3.svg',
            child: Text('group_notes_unavailable'.tr()),
          ),
          const SizedBox(height: AppSize.s16),
          GroupSection(
            title: 'group_design_students',
            asset: 'a57fd.svg',
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    StudentDirectory(groupId: group.id, groupName: group.name),
              ),
            ),
            child: Material(
              child: Column(
                children: [
                  for (final student in group.roster)
                    ListTile(
                      title: Text(student.name),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              StudentProfilePage(studentId: student.id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
