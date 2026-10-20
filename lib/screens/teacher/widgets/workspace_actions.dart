import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../features/secretaries/presentation/teacher_secretaries_page.dart';
import '../../../features/notifications/presentation/teacher_notifications_page.dart';
import '../../../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../../../features/students/presentation/student_directory.dart';

class WorkspaceActions extends StatelessWidget {
  const WorkspaceActions({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'live_students'.tr(),
        icon: const Icon(Icons.school_outlined),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StudentDirectory()),
        ),
      ),
      PopupMenuButton<String>(
        tooltip: 'completion_more'.tr(),
        itemBuilder: (_) => [
          if (CompletionContracts.enabled) ...[
            PopupMenuItem(
              value: 'secretaries',
              child: Text('completion_secretaries'.tr()),
            ),
            PopupMenuItem(
              value: 'notifications',
              child: Text('completion_notifications'.tr()),
            ),
          ],
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, color: ColorManager.error),
                const SizedBox(width: AppSize.s12),
                Text('auth_logout'.tr()),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'logout') {
            getIt<AuthSessionCubit>().logout();
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => value == 'secretaries'
                  ? const TeacherSecretariesPage()
                  : const TeacherNotificationsPage(),
            ),
          );
        },
      ),
    ],
  );
}
