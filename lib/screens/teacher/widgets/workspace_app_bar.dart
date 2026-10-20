import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import 'workspace_actions.dart';
import 'teacher_avatar.dart';

/// Teacher-specific composition of the shared branded header.
class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkspaceAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(AppHeader.height);
  @override
  Widget build(BuildContext context) => AppHeader(
    title: 'workspace_title'.tr(),
    avatar: const TeacherAvatar(),
    actions: const [WorkspaceActions()],
  );
}
