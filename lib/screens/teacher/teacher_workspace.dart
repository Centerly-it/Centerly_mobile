import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/theme/color_manager.dart';
import '../../core/data/completion_contracts.dart';
import '../../core/config/preview_mode.dart';
import '../../features/sessions/preview/figma_sessions_preview.dart';
import '../../features/finances/presentation/live_finance.dart';
import '../../core/theme/values_manager.dart';
import 'widgets/workspace_app_bar.dart';
import '../../features/dashboard/presentation/live_dashboard.dart';
import '../../features/sessions/presentation/live_sessions.dart';
import '../../features/groups/presentation/live_groups.dart';

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
    appBar: const WorkspaceAppBar(),
    body: SafeArea(
      top: false,
      child: _index == 0
          ? const LiveDashboard()
          : _index == 1
          ? (PreviewMode.enabled
                ? const FigmaSessionsPreview()
                : const LiveSessions())
          : _index == 2
          ? const LiveGroups()
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
    bottomNavigationBar: NavigationBar(
      height:
          AppSize.s80 +
          MediaQuery.textScalerOf(context).scale(AppSize.s24) -
          AppSize.s24,
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
