import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

class TeacherBottomNavigation extends StatelessWidget {
  const TeacherBottomNavigation({
    required this.index,
    required this.onSelected,
    super.key,
  });
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBarTheme(
    data: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => Theme.of(context).textTheme.labelMedium!.copyWith(
          color: states.contains(WidgetState.selected)
              ? ColorManager.primary
              : ColorManager.textSecondary,
        ),
      ),
    ),
    child: NavigationBar(
      height:
          AppSize.s80 +
          MediaQuery.textScalerOf(context).scale(AppSize.s24) -
          AppSize.s24,
      selectedIndex: index,
      onDestinationSelected: onSelected,
      backgroundColor: ColorManager.surface,
      indicatorColor: Colors.transparent,
      destinations: [
        for (final (icon, label) in [
          (Icons.home_outlined, 'nav_home'),
          (Icons.calendar_month_outlined, 'nav_sessions'),
          (Icons.groups_2_outlined, 'nav_groups'),
          (Icons.school_outlined, 'live_students'),
          (Icons.account_balance_wallet_outlined, 'nav_finance'),
        ])
          NavigationDestination(
            icon: Icon(icon),
            selectedIcon: Icon(icon, color: ColorManager.primary),
            label: label.tr(),
          ),
      ],
    ),
  );
}
