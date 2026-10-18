import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/secretary/secretary_finance_screen.dart';
import 'package:centrally/screens/secretary/secretary_home_screen.dart';
import 'package:centrally/screens/teacher/teacher_groups_screen.dart';
import 'package:centrally/screens/teacher/teacher_home_screen.dart';
import 'package:centrally/screens/teacher/teacher_sessions_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The main shell for Teacher and Secretary roles — shows the 4-tab bottom navigation
/// matching the Figma design: الرئيسية / الحصص / المجموعات / المالية
class MainShellView extends StatefulWidget {
  const MainShellView({required this.role, super.key});

  final UserRole role;

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _index = 3; // default to Home (rightmost tab in RTL)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _buildPages()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: ColorManager.surface,
        indicatorColor: ColorManager.primaryBright,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          _navItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: StringsManager.navFinance.tr(),
          ),
          _navItem(
            icon: Icons.groups_2_outlined,
            selectedIcon: Icons.groups_2,
            label: StringsManager.navGroups.tr(),
          ),
          _navItem(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month,
            label: StringsManager.navSessions.tr(),
          ),
          _navItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: StringsManager.navHome.tr(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    if (widget.role == UserRole.teacher) {
      return [
        const SecretaryFinanceScreen(),
        const TeacherGroupsScreen(role: UserRole.teacher),
        const TeacherSessionsScreen(role: UserRole.teacher),
        const TeacherHomeScreen(),
      ];
    }
    // Secretary role pages
    return [
      const SecretaryFinanceScreen(),
      const TeacherGroupsScreen(role: UserRole.secretary),
      const TeacherSessionsScreen(role: UserRole.secretary),
      const SecretaryHomeScreen(),
    ];
  }
}

NavigationDestination _navItem({
  required IconData icon,
  required IconData selectedIcon,
  required String label,
}) => NavigationDestination(
  icon: Icon(icon),
  selectedIcon: Icon(selectedIcon, color: ColorManager.primary),
  label: label,
);
