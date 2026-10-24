import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/data/completion_contracts.dart';
import '../../core/config/preview_mode.dart';
import '../../core/theme/values_manager.dart';
import '../../features/sessions/preview/figma_sessions_preview.dart';
import '../../features/finances/presentation/live_finance.dart';
import '../../features/finances/preview/finance_preview.dart';
import '../../features/students/presentation/student_directory.dart';
import '../../features/students/preview/figma_students_preview.dart';
import '../../features/students/preview/student_preview_data.dart';
import '../../features/dashboard/presentation/live_dashboard.dart';
import '../../features/sessions/presentation/live_sessions.dart';
import '../../features/groups/presentation/live_groups.dart';
import '../../features/groups/preview/figma_groups_preview.dart';
import '../../features/groups/preview/group_preview_data.dart';

Widget workspacePanel(int index) {
  switch (index) {
    case 0:
      return const LiveDashboard();
    case 1:
      return PreviewMode.enabled
          ? const FigmaSessionsPreview()
          : const LiveSessions();
    case 2:
      return PreviewMode.enabled
          ? FigmaGroupsPreview(groups: GroupPreviewData.fixtures())
          : const LiveGroups();
    case 3:
      return PreviewMode.enabled
          ? FigmaStudentsPreview(students: StudentPreviewData.fixtures())
          : const StudentDirectory(embedded: true);
    default:
      if (PreviewMode.enabled) return const FinancePreview();
      if (CompletionContracts.enabled) return const LiveFinance();
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Text('workspace_pending'.tr(), textAlign: TextAlign.center),
        ),
      );
  }
}
