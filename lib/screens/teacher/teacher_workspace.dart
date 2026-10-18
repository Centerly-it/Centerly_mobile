import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/di/di.dart';
import '../../core/theme/color_manager.dart';
import '../../core/theme/values_manager.dart';
import '../../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../../features/dashboard/presentation/live_dashboard.dart';

/// Production entry: no prototype mock screens or secretary operations.
class TeacherWorkspace extends StatefulWidget {
  const TeacherWorkspace({super.key});
  @override
  State<TeacherWorkspace> createState() => _TeacherWorkspaceState();
}

class _TeacherWorkspaceState extends State<TeacherWorkspace> {
  int _index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('workspace_title'.tr()),
      actions: [
        IconButton(
          tooltip: 'auth_logout'.tr(),
          icon: const Icon(Icons.logout),
          onPressed: () => getIt<AuthSessionCubit>().logout(),
        ),
      ],
    ),
    body: _index == 0
        ? const LiveDashboard()
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p24),
              child: Text(
                'workspace_pending'.tr(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      backgroundColor: ColorManager.surface,
      indicatorColor: ColorManager.primaryBright,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          label: 'nav_home'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          label: 'nav_sessions'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.groups_2_outlined),
          label: 'nav_groups'.tr(),
        ),
        NavigationDestination(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: 'nav_finance'.tr(),
        ),
      ],
    ),
  );
}
