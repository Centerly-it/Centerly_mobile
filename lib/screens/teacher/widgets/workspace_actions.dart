import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/di/di.dart';
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
      IconButton(
        tooltip: 'auth_logout'.tr(),
        icon: const Icon(Icons.logout),
        onPressed: () => getIt<AuthSessionCubit>().logout(),
      ),
    ],
  );
}
