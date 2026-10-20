import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import 'workspace_actions.dart';
import 'teacher_avatar.dart';
import 'teacher_greeting.dart';

/// Teacher-specific composition of the shared branded header.
class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkspaceAppBar({this.height = AppHeader.height, super.key});
  final double height;
  static double heightFor(BuildContext context) =>
      AppHeader.height + MediaQuery.textScalerOf(context).scale(32) - 32;
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) => AppHeader(
    title: 'workspace_title'.tr(),
    toolbarHeight: height,
    titleContent: const TeacherGreeting(),
    avatar: const TeacherAvatar(),
    actions: const [WorkspaceActions()],
  );
}
