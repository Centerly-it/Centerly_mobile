import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/data/completion_contracts.dart';
import '../../core/config/preview_mode.dart';
import '../../features/sessions/preview/figma_sessions_preview.dart';
import '../../features/finances/presentation/live_finance.dart';
import '../../features/finances/preview/finance_preview.dart';
import '../../core/theme/values_manager.dart';
import 'widgets/workspace_app_bar.dart';
import 'widgets/teacher_bottom_navigation.dart';
import '../../features/students/presentation/student_directory.dart';
import '../../features/students/preview/figma_students_preview.dart';
import '../../features/students/preview/student_preview_data.dart';
import '../../features/dashboard/presentation/live_dashboard.dart';
import '../../features/sessions/presentation/live_sessions.dart';
import '../../features/groups/presentation/live_groups.dart';
import '../../features/groups/preview/figma_groups_preview.dart';
import '../../features/groups/preview/group_preview_data.dart';

/// Production entry: no prototype mock screens or secretary operations.
class TeacherWorkspace extends StatefulWidget {
  const TeacherWorkspace({super.key});
  @override
  State<TeacherWorkspace> createState() => _TeacherWorkspaceState();
}

class _TeacherWorkspaceState extends State<TeacherWorkspace> {
  int _index = 0;
  late final _previewStudents = StudentPreviewData.fixtures();
  late final _previewGroups = GroupPreviewData.fixtures();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: WorkspaceAppBar(height: WorkspaceAppBar.heightFor(context)),
    body: SafeArea(
      top: false,
      child: _index == 0
          ? const LiveDashboard()
          : _index == 1
          ? (PreviewMode.enabled
                ? const FigmaSessionsPreview()
                : const LiveSessions())
          : _index == 2
          ? (PreviewMode.enabled
                ? FigmaGroupsPreview(groups: _previewGroups)
                : const LiveGroups())
          : _index == 3
          ? (PreviewMode.enabled
                ? FigmaStudentsPreview(students: _previewStudents)
                : const StudentDirectory(embedded: true))
          : PreviewMode.enabled
          ? const FinancePreview()
          : CompletionContracts.enabled
          ? const LiveFinance()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p24),
                child: Text(
                  'workspace_pending'.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    ),
    bottomNavigationBar: TeacherBottomNavigation(
      index: _index,
      onSelected: (value) => setState(() => _index = value),
    ),
  );
}
