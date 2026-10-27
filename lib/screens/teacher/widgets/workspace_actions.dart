import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../features/secretaries/presentation/teacher_secretaries_page.dart';
import '../../../features/notifications/presentation/notification_bell.dart';
import '../../../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../../../features/auth/presentation/widgets/contact_support_button.dart';

class WorkspaceActions extends StatelessWidget {
  const WorkspaceActions({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (CompletionContracts.enabled) const NotificationBell(),
      PopupMenuButton<String>(
        tooltip: 'completion_more'.tr(),
        itemBuilder: (_) => [
          if (CompletionContracts.enabled) ...[
            PopupMenuItem(
              value: 'secretaries',
              child: Text('completion_secretaries'.tr()),
            ),
          ],
          PopupMenuItem(
            value: 'support',
            child: Row(
              children: [
                const Icon(
                  Icons.support_agent_rounded,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s12),
                Text('auth_contact_support'.tr()),
              ],
            ),
          ),
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
          if (value == 'support') {
            ContactSupportButton.contact(context);
            return;
          }
          if (value == 'logout') {
            getIt<AuthSessionCubit>().logout();
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const TeacherSecretariesPage(),
            ),
          );
        },
      ),
    ],
  );
}
