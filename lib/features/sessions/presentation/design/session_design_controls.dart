import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/font_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../session_date_controls.dart';
import 'session_period_tabs.dart';
import 'session_period_navigation.dart';

class SessionDesignControls extends StatelessWidget {
  const SessionDesignControls({
    required this.date,
    required this.period,
    required this.onDate,
    required this.onPeriod,
    super.key,
  });
  final DateTime date;
  final SessionPeriod period;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<SessionPeriod> onPeriod;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'nav_sessions'.tr(),
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeightManager.bold,
        ),
      ),
      const SizedBox(height: AppSize.s8),
      if (period == SessionPeriod.day)
        SessionPeriodNavigation(date: date, period: period, onDate: onDate),
      SessionPeriodTabs(period: period, onChanged: onPeriod),
      if (period != SessionPeriod.day)
        SessionPeriodNavigation(date: date, period: period, onDate: onDate),
    ],
  );
}
